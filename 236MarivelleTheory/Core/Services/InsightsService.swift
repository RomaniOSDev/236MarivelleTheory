import Foundation

enum InsightsService {
    static func computeInsights(
        sessions: [ActivitySession],
        windRecords: [WindRecord],
        weeklyData: [WindDay],
        streakDays: Int,
        preferredActivity: OutdoorActivity?
    ) -> [AppInsight] {
        var insights: [AppInsight] = []

        if let windiest = mostWindyDay(from: weeklyData, records: windRecords) {
            insights.append(AppInsight(
                id: "most_windy",
                title: "Most Windy Day",
                value: windiest.value,
                iconName: "wind",
                detail: windiest.detail
            ))
        }

        if let bestWeek = bestWeekForActivity(
            activity: preferredActivity ?? .sailing,
            weeklyData: weeklyData,
            sessions: sessions
        ) {
            insights.append(AppInsight(
                id: "best_week",
                title: "Best Week for \(bestWeek.activity)",
                value: bestWeek.value,
                iconName: "calendar",
                detail: bestWeek.detail
            ))
        }

        insights.append(AppInsight(
            id: "streak",
            title: "Longest Monitoring Streak",
            value: "\(streakDays) days",
            iconName: "flame.fill",
            detail: streakDays > 0
                ? "You've checked conditions \(streakDays) day\(streakDays == 1 ? "" : "s") in a row."
                : "Start logging sessions to build a streak."
        ))

        insights.append(AppInsight(
            id: "sessions_logged",
            title: "Sessions Logged",
            value: "\(sessions.count)",
            iconName: "book.fill",
            detail: sessions.isEmpty
                ? "Log your first outdoor session from the Log tab."
                : "Total activity journal entries saved locally."
        ))

        if let avg = averageWind(records: windRecords) {
            insights.append(AppInsight(
                id: "avg_wind",
                title: "Average Tracked Wind",
                value: String(format: "%.1f km/h", avg),
                iconName: "gauge.with.dots.needle.33percent",
                detail: "Based on \(windRecords.count) live readings."
            ))
        }

        return insights
    }

    private static func mostWindyDay(
        from weeklyData: [WindDay],
        records: [WindRecord]
    ) -> (value: String, detail: String)? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"

        if let day = weeklyData.max(by: { $0.averageSpeed < $1.averageSpeed }),
           day.averageSpeed > 0 {
            return (
                String(format: "%.1f km/h", day.averageSpeed),
                "Peak average on \(formatter.string(from: day.date))."
            )
        }

        let grouped = Dictionary(grouping: records) {
            Calendar.current.startOfDay(for: $0.timestamp)
        }
        guard let (date, dayRecords) = grouped.max(by: {
            average(of: $0.value) < average(of: $1.value)
        }), !dayRecords.isEmpty else { return nil }

        return (
            String(format: "%.1f km/h", average(of: dayRecords)),
            "Peak average on \(formatter.string(from: date))."
        )
    }

    private static func bestWeekForActivity(
        activity: OutdoorActivity,
        weeklyData: [WindDay],
        sessions: [ActivitySession]
    ) -> (activity: String, value: String, detail: String)? {
        let activitySessions = sessions.filter { $0.activity == activity }
        if !activitySessions.isEmpty {
            let grouped = Dictionary(grouping: activitySessions) { session -> Date in
                let cal = Calendar.current
                let week = cal.component(.weekOfYear, from: session.date)
                let year = cal.component(.yearForWeekOfYear, from: session.date)
                return cal.date(from: DateComponents(year: year, weekOfYear: week)) ?? session.date
            }
            if let (week, weekSessions) = grouped.max(by: { $0.value.count < $1.value.count }) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return (
                    activity.title,
                    "\(weekSessions.count) sessions",
                    "Week of \(formatter.string(from: week)) had the most \(activity.title.lowercased()) logs."
                )
            }
        }

        guard let bestDay = weeklyData.max(by: { dayA, dayB in
            score(dayA.averageSpeed, for: activity) < score(dayB.averageSpeed, for: activity)
        }), bestDay.averageSpeed > 0 else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return (
            activity.title,
            formatter.string(from: bestDay.date),
            "Favorable wind near \(Int(bestDay.averageSpeed)) km/h for \(activity.title.lowercased())."
        )
    }

    private static func score(_ speed: Double, for activity: OutdoorActivity) -> Double {
        let optimal = activity.optimalRange
        if optimal.contains(speed) { return 100 }
        let distance = min(abs(speed - optimal.lowerBound), abs(speed - optimal.upperBound))
        return max(0, 100 - distance * 3)
    }

    private static func average(of records: [WindRecord]) -> Double {
        guard !records.isEmpty else { return 0 }
        return records.map(\.speed).reduce(0, +) / Double(records.count)
    }

    private static func averageWind(records: [WindRecord]) -> Double? {
        guard !records.isEmpty else { return nil }
        return average(of: records)
    }
}
