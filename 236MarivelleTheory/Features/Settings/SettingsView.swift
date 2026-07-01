import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @ObservedObject private var store = AppDataStore.shared
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    VStack(spacing: 16) {
                        insightsPreview
                        unitSection
                        SmartAlertsView()
                        spotsSection
                        appSection
                        versionFooter
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackService.lightTap() }
                Button("Reset", role: .destructive) {
                    FeedbackService.mediumAction()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your data, settings, and progress. This action cannot be undone.")
            }
        }
    }

    private var insightsPreview: some View {
        SurfaceCard(bordered: true) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Insights", subtitle: "Your wind activity at a glance")
                ForEach(store.insights.prefix(2)) { insight in
                    HStack(spacing: 10) {
                        Image(systemName: insight.iconName)
                            .foregroundStyle(Color("AppPrimary"))
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(insight.title)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                            Text(insight.value)
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppAccent"))
                        }
                        Spacer()
                    }
                }
                NavigationLink {
                    InsightsView()
                } label: {
                    HStack {
                        Text("View All Insights")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppPrimary"))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .padding(.top, 4)
                }
                .simultaneousGesture(TapGesture().onEnded { FeedbackService.lightTap() })
            }
        }
    }

    private var unitSection: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeader(title: "Wind Units")
                Picker("Unit", selection: $store.windSpeedUnit) {
                    Text("km/h").tag("kph")
                    Text("mph").tag("mph")
                }
                .pickerStyle(.segmented)
                .onChange(of: store.windSpeedUnit) { _ in FeedbackService.lightTap() }
            }
        }
    }

    private var spotsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Saved Spots", subtitle: "\(store.windSpots.count) locations")
            if store.windSpots.isEmpty {
                SurfaceCard {
                    Text("No spots saved. Add a city on the Tracker tab.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            } else {
                ForEach(store.windSpots) { spot in
                    SpotCell(
                        spot: spot,
                        isSelected: store.selectedSpotId == spot.id,
                        showDelete: true,
                        onTap: {
                            store.selectSpot(spot)
                        },
                        onDelete: {
                            store.removeSpot(id: spot.id)
                        }
                    )
                }
            }
        }
    }

    private var appSection: some View {
        SurfaceCard(padding: 0) {
            VStack(spacing: 0) {
                SettingsRowCell(title: "Rate Us", icon: "star.fill") {
                    FeedbackService.lightTap()
                    rateApp()
                }
                Divider().padding(.leading, 54).background(Color("AppBackground").opacity(0.4))
                SettingsRowCell(title: "Privacy Policy", icon: "hand.raised.fill") {
                    FeedbackService.lightTap()
                    openLink(.privacyPolicy)
                }
                Divider().padding(.leading, 54).background(Color("AppBackground").opacity(0.4))
                SettingsRowCell(title: "Terms of Use", icon: "doc.text.fill") {
                    FeedbackService.lightTap()
                    openLink(.termsOfUse)
                }
                Divider().padding(.leading, 54).background(Color("AppBackground").opacity(0.4))
                SettingsRowCell(title: "Reset All Data", icon: "trash.fill", isDestructive: true) {
                    FeedbackService.lightTap()
                    showResetAlert = true
                }
            }
        }
    }

    private func openLink(_ link: AppLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}
