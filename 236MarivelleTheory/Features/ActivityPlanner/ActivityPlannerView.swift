import SwiftUI

struct ActivityPlannerView: View {
    @StateObject private var viewModel = ActivityPlannerViewModel()
    @ObservedObject private var store = AppDataStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    VStack(spacing: 16) {
                        heroCard
                        activitySection
                        recommendationHero
                        if store.currentWindConditions != nil {
                            HStack(alignment: .top, spacing: 12) {
                                BeaufortCardView(speedKmh: viewModel.currentWindKmh, unit: store.windSpeedUnit)
                                WindCompassView(
                                    direction: store.currentWindConditions?.direction ?? 0,
                                    size: 130
                                )
                            }
                        }
                        overviewSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Activity Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var heroCard: some View {
        SurfaceCard(bordered: true) {
            HStack(spacing: 14) {
                ActivityIllustrationView(activity: viewModel.selectedActivity, size: 64)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Outdoor Wind Planner")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Real-time advice for sailing, kite, cycling, running & hiking.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if store.selectedSpot == nil {
                        Label("Add a spot on Tracker", systemImage: "exclamationmark.circle")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppPrimary"))
                    } else if let spot = store.selectedSpot {
                        Label(spot.displayName, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Your Activity", subtitle: "Tap to get a recommendation")
            ForEach(OutdoorActivity.allCases) { activity in
                ActivityCell(
                    activity: activity,
                    isSelected: viewModel.selectedActivity == activity,
                    recommendation: store.currentWindConditions != nil
                        ? ActivityRecommendationService.recommend(activity: activity, windSpeedKmh: viewModel.currentWindKmh).level
                        : nil,
                    onTap: { viewModel.selectActivity(activity) }
                )
            }
        }
    }

    private var recommendationHero: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Today's Verdict")
            if store.currentWindConditions == nil {
                EmptyStateView(
                    icon: "wind",
                    title: "No Wind Data",
                    message: "Load live wind on the Tracker tab to see activity recommendations."
                )
            } else {
                SurfaceCard(padding: 0, bordered: true) {
                    VStack(spacing: 0) {
                        RecommendationBadge(recommendation: viewModel.recommendation)
                            .padding(14)
                        Divider().background(Color("AppBackground").opacity(0.4))
                        HStack(spacing: 0) {
                            verdictStat("Wind", String(format: "%.1f km/h", viewModel.currentWindKmh))
                            Divider().frame(height: 40)
                            verdictStat("Ideal", viewModel.selectedActivity.rangeDescription)
                            Divider().frame(height: 40)
                            verdictStat("Status", viewModel.recommendation.level.rawValue)
                        }
                        .padding(.vertical, 12)
                    }
                }
            }
        }
    }

    private func verdictStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "All Activities", subtitle: "Quick overview")
            if store.currentWindConditions == nil {
                Text("Load wind data to see overview.")
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                ForEach(viewModel.allRecommendations, id: \.activity.id) { item in
                    ActivityCell(
                        activity: item.activity,
                        recommendation: item.level,
                        onTap: { viewModel.selectActivity(item.activity) }
                    )
                }
            }
        }
    }
}
