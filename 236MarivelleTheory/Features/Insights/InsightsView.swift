import SwiftUI

struct InsightsView: View {
    @ObservedObject private var store = AppDataStore.shared

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ZStack {
            BackgroundPatternView()
            ScrollView {
                VStack(spacing: 16) {
                    statsGrid
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "Wind Insights", subtitle: "Based on your local data")
                        ForEach(store.insights) { insight in
                            InsightCell(insight: insight)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            StatGridCell(label: "Spots", value: "\(store.windSpots.count)", icon: "mappin.and.ellipse")
            StatGridCell(label: "Alerts", value: "\(store.windAlerts.count)", icon: "bell.fill")
            StatGridCell(label: "Sessions", value: "\(store.activitySessions.count)", icon: "book.fill")
            StatGridCell(label: "Streak", value: "\(store.streakDays)d", icon: "flame.fill")
            StatGridCell(label: "Readings", value: "\(store.windSpeedRecords.count)", icon: "wind")
            StatGridCell(
                label: "Minutes",
                value: "\(store.totalMinutesUsed)",
                icon: "clock.fill"
            )
        }
    }
}
