import SwiftUI

// MARK: - Hero banner

struct HomeHeroWidget: View {
    let greeting: String
    let spotName: String
    let windText: String
    let unitLabel: String
    let isLive: Bool
    var onTapSpot: () -> Void

    var body: some View {
        Button(action: onTapSpot) {
            ZStack(alignment: .bottomLeading) {
                Image("HomeHero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
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

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if isLive {
                            HStack(spacing: 5) {
                                Circle().fill(Color("AppAccent")).frame(width: 7, height: 7)
                                Text("LIVE")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color("AppAccent"))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("AppBackground").opacity(0.5))
                            .clipShape(Capsule())
                        }
                        Spacer()
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    Text(greeting)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(spotName)
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(windText)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(unitLabel)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextSecondary"))
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
        .buttonStyle(.plain)
    }
}

// MARK: - Wind live widget

struct HomeWindWidget: View {
    let speed: String
    let gusts: String
    let direction: String
    let unitLabel: String
    var onRefresh: () -> Void

    var body: some View {
        SurfaceCard(padding: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Wind Now", subtitle: "Real-time conditions")
                    HStack(spacing: 12) {
                        windStat("Speed", speed, unitLabel)
                        windStat("Gusts", gusts, unitLabel)
                    }
                    Label(direction, systemImage: "location.north.fill")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Button {
                        onRefresh()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                Spacer(minLength: 0)
                Image("HomeWindWidget")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 110, height: 140)
                    .clipped()
            }
        }
    }

    private func windStat(_ label: String, _ value: String, _ unit: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(unit)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }
}

// MARK: - Activity widget

struct HomeActivityWidget: View {
    let activity: OutdoorActivity
    let recommendation: WindRecommendation
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SurfaceCard(padding: 0) {
                HStack(spacing: 0) {
                    Image("HomeActivities")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 130)
                        .clipped()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity Planner")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                        HStack(spacing: 8) {
                            ActivityIllustrationView(activity: activity, size: 36)
                            Text(activity.title)
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        StatusBadge(level: recommendation.level)
                        Text(recommendation.message)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                    }
                    .padding(12)
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick actions

struct HomeQuickActionsWidget: View {
    var onTracker: () -> Void
    var onLog: () -> Void
    var onAlerts: () -> Void
    var onPlanner: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Quick Actions")
            LazyVGrid(columns: columns, spacing: 10) {
                QuickActionTile(icon: "wind", title: "Tracker", tint: Color("AppPrimary"), action: onTracker)
                QuickActionTile(icon: "book.fill", title: "Log Session", tint: Color("AppAccent"), action: onLog)
                QuickActionTile(icon: "bell.badge", title: "Alerts", tint: Color("AppPrimary"), action: onAlerts)
                QuickActionTile(icon: "figure.outdoor.cycle", title: "Planner", tint: Color("AppAccent"), action: onPlanner)
            }
        }
    }
}

// MARK: - Beaufort + Compass row

struct HomeConditionsRowWidget: View {
    let speedKmh: Double
    let direction: Int
    let unit: String

    var body: some View {
        HStack(spacing: 10) {
            BeaufortCardView(speedKmh: speedKmh, unit: unit)
            WindCompassView(direction: direction, size: 130)
        }
    }
}

// MARK: - Insights strip

struct HomeInsightsStripWidget: View {
    let insights: [AppInsight]
    var onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Insights", actionTitle: "See All", action: onSeeAll)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(insights.prefix(4)) { insight in
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: insight.iconName)
                                .foregroundStyle(Color("AppPrimary"))
                            Text(insight.value)
                                .font(.headline.bold())
                                .foregroundStyle(Color("AppAccent"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text(insight.title)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(2)
                        }
                        .padding(14)
                        .frame(width: 130, alignment: .leading)
                        .depth(.flat, radius: 14)
                    }
                }
            }
        }
    }
}

// MARK: - Recent sessions

struct HomeRecentSessionsWidget: View {
    let sessions: [ActivitySession]
    var onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(
                title: "Recent Sessions",
                subtitle: sessions.isEmpty ? "No logs yet" : nil,
                actionTitle: sessions.isEmpty ? nil : "See All",
                action: onSeeAll
            )
            if sessions.isEmpty {
                SurfaceCard {
                    Text("Log your first outdoor session from Quick Actions.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            } else {
                ForEach(sessions) { session in
                    HStack(spacing: 10) {
                        ActivityIllustrationView(activity: session.activity, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.activity.title)
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text(session.date, style: .date)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                        Text(String(format: "%.0f km/h", session.windSpeed))
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .padding(12)
                    .depth(.flat, radius: 12)
                }
            }
        }
    }
}

// MARK: - Alerts summary

struct HomeAlertsSummaryWidget: View {
    let alertCount: Int
    let enabledCount: Int
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            SurfaceCard(bordered: true) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color("AppPrimary").opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Smart Alerts")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(enabledCount) active · \(alertCount) total")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
