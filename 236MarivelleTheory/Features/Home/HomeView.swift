import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var store = AppDataStore.shared
    @State private var showTracker = false
    @State private var showSpotSheet = false
    @State private var cityQuery = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.hasWindData {
                            HomeHeroWidget(
                                greeting: viewModel.greeting,
                                spotName: viewModel.spotName,
                                windText: viewModel.displaySpeed,
                                unitLabel: viewModel.unitLabel,
                                isLive: store.isLiveTrackingEnabled,
                                onTapSpot: { showSpotSheet = true }
                            )
                        } else {
                            noDataHero
                        }

                        if viewModel.hasWindData {
                            HomeWindWidget(
                                speed: viewModel.displaySpeed,
                                gusts: String(format: "%.1f", store.convertSpeed(viewModel.windGusts, to: store.windSpeedUnit)),
                                direction: WindDirectionLabel.fullLabel(degrees: viewModel.windDirection),
                                unitLabel: viewModel.unitLabel,
                                onRefresh: {
                                    FeedbackService.lightTap()
                                    Task { await viewModel.refresh() }
                                }
                            )
                            HomeConditionsRowWidget(
                                speedKmh: viewModel.windSpeed,
                                direction: viewModel.windDirection,
                                unit: store.windSpeedUnit
                            )
                        }

                        HomeActivityWidget(
                            activity: store.preferredActivity,
                            recommendation: viewModel.recommendation,
                            onTap: {
                                FeedbackService.lightTap()
                                selectedTab = .planner
                            }
                        )

                        HomeQuickActionsWidget(
                            onTracker: { showTracker = true },
                            onLog: { selectedTab = .log },
                            onAlerts: { selectedTab = .settings },
                            onPlanner: { selectedTab = .planner }
                        )

                        if !store.weeklyWindData.isEmpty {
                            WeeklyMiniChart(data: store.weeklyWindData, unit: store.windSpeedUnit)
                        }

                        HomeInsightsStripWidget(insights: store.insights) {
                            FeedbackService.lightTap()
                            selectedTab = .settings
                        }

                        HomeRecentSessionsWidget(sessions: viewModel.recentSessions) {
                            FeedbackService.lightTap()
                            selectedTab = .log
                        }

                        if !store.windAlerts.isEmpty {
                            HomeAlertsSummaryWidget(
                                alertCount: store.windAlerts.count,
                                enabledCount: store.windAlerts.filter(\.isEnabled).count,
                                onTap: { selectedTab = .settings }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        Task { await viewModel.refresh() }
                    } label: {
                        if viewModel.isRefreshing || store.isFetchingWeather {
                            ProgressView().tint(Color("AppPrimary"))
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showTracker) {
                WindTrackerView()
            }
            .sheet(isPresented: $showSpotSheet) {
                spotSearchSheet
            }
            .task {
                if store.selectedSpot != nil {
                    await viewModel.refresh()
                }
            }
        }
    }

    private var noDataHero: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()
            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.55), Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            LinearGradient(
                colors: [Color("AppTextPrimary").opacity(0.08), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .allowsHitTesting(false)
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Add a spot to see live wind conditions on your dashboard.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                PrimaryButton(title: "Add Your Spot", icon: "mappin.and.ellipse") {
                    showSpotSheet = true
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.45), Color("AppPrimary").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: .black.opacity(0.30), radius: 12, x: 0, y: 6)
    }

    private var spotSearchSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        SurfaceCard {
                            VStack(spacing: 10) {
                                TextField("Enter city name", text: $cityQuery)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .submitLabel(.search)
                                PrimaryButton(title: "Search", icon: "magnifyingglass") {
                                    Task { await searchCity() }
                                }
                            }
                        }
                        ForEach(store.windSpots) { spot in
                            SpotCell(
                                spot: spot,
                                isSelected: store.selectedSpotId == spot.id,
                                onTap: {
                                    store.selectSpot(spot)
                                    showSpotSheet = false
                                    Task { await viewModel.refresh() }
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        showSpotSheet = false
                    }
                }
            }
        }
    }

    private func searchCity() async {
        let query = cityQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        do {
            let results = try await store.searchCities(query)
            if let first = results.first {
                store.addSpot(from: first)
                cityQuery = ""
                showSpotSheet = false
                await viewModel.refresh()
            }
        } catch {
            FeedbackService.warning()
        }
    }
}
