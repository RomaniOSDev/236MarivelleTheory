import SwiftUI

// MARK: - Metric pill

struct MetricPillCell: View {
    let icon: String
    let title: String
    let value: String
    var accent: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppPrimary"))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(accent ? Color("AppAccent") : Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .depth(.raised, radius: 14)
    }
}

// MARK: - Spot cell

struct SpotCell: View {
    let spot: WindSpot
    var isSelected: Bool = false
    var showDelete: Bool = false
    var onTap: () -> Void
    var onDelete: (() -> Void)?

    var body: some View {
        Button {
            FeedbackService.lightTap()
            onTap()
        } label: {
            HStack(spacing: 12) {
                IconOrb(
                    icon: isSelected ? "location.fill" : "mappin",
                    size: 44,
                    tint: isSelected ? Color("AppPrimary") : Color("AppTextSecondary")
                )
                VStack(alignment: .leading, spacing: 3) {
                    Text(spot.displayName)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if isSelected {
                        Text("Active spot")
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppAccent"))
                    } else if !spot.country.isEmpty {
                        Text(spot.country)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer()
                if showDelete, let onDelete {
                    Button {
                        FeedbackService.lightTap()
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red.opacity(0.85))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("AppAccent"))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(12)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .depth(.flat, radius: 14, highlighted: isSelected)
    }
}

// MARK: - Activity cell

struct ActivityCell: View {
    let activity: OutdoorActivity
    var isSelected: Bool = false
    var recommendation: WindRecommendationLevel?
    var onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {
                ActivityIllustrationView(activity: activity, size: 50)
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(activity.rangeDescription)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                if let recommendation {
                    StatusBadge(level: recommendation)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            .padding(12)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .depth(.flat, radius: 14, highlighted: isSelected)
    }
}

// MARK: - Status badge

struct StatusBadge: View {
    let level: WindRecommendationLevel

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.iconName)
                .font(.caption2.bold())
            Text(shortLabel)
                .font(.caption2.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(badgeGradient)
        .clipShape(Capsule())
        .overlay {
            Capsule().strokeBorder(Color("AppTextPrimary").opacity(0.12), lineWidth: 0.5)
        }
    }

    private var shortLabel: String {
        switch level {
        case .good: return "Go"
        case .caution: return "Care"
        case .notRecommended: return "No"
        }
    }

    private var foregroundColor: Color {
        switch level {
        case .good: return Color("AppBackground")
        case .caution, .notRecommended: return Color("AppTextPrimary")
        }
    }

    private var badgeGradient: LinearGradient {
        switch level {
        case .good:
            LinearGradient(
                colors: [Color("AppAccent"), Color("AppPrimary").opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .caution:
            LinearGradient(
                colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .notRecommended:
            LinearGradient(
                colors: [Color.red.opacity(0.55), Color.red.opacity(0.30)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Session log cell

struct SessionLogCell: View {
    let session: ActivitySession
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ActivityIllustrationView(activity: session.activity, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.activity.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(session.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Label(session.spotName, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.0f", session.windSpeed))
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppAccent"))
                    Text("km/h")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            HStack(spacing: 8) {
                miniChip(icon: "wind", text: "Gusts \(Int(session.windGusts))")
                miniChip(icon: "location.north.fill", text: WindDirectionLabel.label(degrees: session.windDirection))
            }
            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("AppBackground").opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(14)
        .depth(.flat, radius: 16)
    }

    private func miniChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2.bold())
        }
        .foregroundStyle(Color("AppTextSecondary"))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color("AppBackground").opacity(0.35))
        .clipShape(Capsule())
    }
}

// MARK: - Insight cell

struct InsightCell: View {
    let insight: AppInsight

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            IconOrb(icon: insight.iconName, size: 48, tint: Color("AppPrimary"))
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(insight.value)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(insight.detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .depth(.flat, radius: 16)
    }
}

// MARK: - Alert cell

struct AlertCell: View {
    let alert: WindAlert
    let spotName: String?
    @Binding var isEnabled: Bool
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                IconOrb(icon: alert.isEnabled ? "bell.fill" : "bell.slash", size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.label.isEmpty ? "Wind Alert" : alert.label)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let activity = alert.activityType {
                        Text(activity.title)
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(Color("AppPrimary"))
                    .onChange(of: isEnabled) { _ in FeedbackService.lightTap() }
            }
            HStack(spacing: 8) {
                Label(alert.rangeDescription, systemImage: "wind")
                if let spotName {
                    Label(spotName, systemImage: "mappin")
                }
            }
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .padding(14)
        .depth(.flat, radius: 14)
        .opacity(alert.isEnabled ? 1 : 0.65)
    }
}

// MARK: - Settings row

struct SettingsRowCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                IconOrb(
                    icon: icon,
                    size: 32,
                    tint: isDestructive ? .red : Color("AppPrimary")
                )
                Text(title)
                    .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat grid cell

struct StatGridCell: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.caption.bold())
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .depth(.raised, radius: 14)
    }
}

// MARK: - Filter chip

struct FilterChip: View {
    let title: String
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            Text(title)
                .font(.caption.bold())
                .lineLimit(1)
                .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        AppGradients.primaryButton()
                    } else {
                        AppGradients.surfaceDeep()
                    }
                }
                .clipShape(Capsule())
                .overlay {
                    Capsule().strokeBorder(
                        isSelected ? Color.clear : Color("AppPrimary").opacity(0.25),
                        lineWidth: 1
                    )
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wind gauge hero

struct WindGaugeHero: View {
    let speed: Double
    let unit: String
    let unitLabel: String
    var gusts: Double?
    var subtitle: String?

    var body: some View {
        SurfaceCard(padding: 20, bordered: true) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color("AppBackground").opacity(0.6), lineWidth: 14)
                        .frame(width: 200, height: 200)
                    Circle()
                        .trim(from: 0, to: min(speed / 60.0, 1.0))
                        .stroke(
                            AppGradients.accentRing(),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: speed)
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", displaySpeed))
                            .font(.system(size: 46, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(unitLabel)
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                        if let gusts {
                            Text("Gusts \(String(format: "%.0f", unit == "mph" ? gusts * 0.621371 : gusts))")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var displaySpeed: Double {
        unit == "mph" ? speed * 0.621371 : speed
    }
}

// MARK: - Weekly mini chart

struct WeeklyMiniChart: View {
    let data: [WindDay]
    var unit: String = "kph"
    var selectedIndex: Int?
    var onSelect: ((Int) -> Void)?

    private var maxVal: Double {
        max(data.map(\.averageSpeed).max() ?? 30, 10)
    }

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "7-Day Forecast", subtitle: "Tap a day for details")
                GeometryReader { geo in
                    let h = geo.size.height
                    let w = geo.size.width
                    let step = w / CGFloat(max(data.count - 1, 1))
                    ZStack(alignment: .bottom) {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, day in
                            let barH = CGFloat(day.averageSpeed / maxVal) * (h - 24)
                            let x = CGFloat(index) * step
                            VStack(spacing: 4) {
                                Spacer()
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(barGradient(selected: selectedIndex == index))
                                    .frame(width: max(step * 0.55, 12), height: max(barH, 4))
                                Text(dayLabel(day.date))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(
                                        selectedIndex == index ? Color("AppPrimary") : Color("AppTextSecondary")
                                    )
                            }
                            .frame(width: step, height: h)
                            .position(x: x + step / 2, y: h / 2)
                            .onTapGesture {
                                FeedbackService.lightTap()
                                onSelect?(index)
                            }
                        }
                    }
                }
                .frame(height: 120)
            }
        }
    }

    private func barGradient(selected: Bool) -> LinearGradient {
        if selected {
            return LinearGradient(
                colors: [Color("AppPrimary"), Color("AppAccent")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        return LinearGradient(
            colors: [Color("AppAccent").opacity(0.85), Color("AppAccent").opacity(0.45)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }
}

// MARK: - Reading row

struct WindReadingRow: View {
    let time: Date
    let speed: String

    var body: some View {
        HStack {
            Text(time, style: .time)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Image(systemName: "wind")
                .font(.caption)
                .foregroundStyle(Color("AppPrimary"))
            Text(speed)
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Quick action tile

struct QuickActionTile: View {
    let icon: String
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 10) {
                IconOrb(icon: icon, size: 36, tint: tint)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            .padding(12)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .depth(.raised, radius: 14)
    }
}
