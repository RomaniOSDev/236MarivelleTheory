import Foundation

enum ActivityRecommendationService {
    static func recommend(activity: OutdoorActivity, windSpeedKmh: Double) -> WindRecommendation {
        let speed = max(0, windSpeedKmh)
        let optimal = activity.optimalRange

        if optimal.contains(speed) {
            return WindRecommendation(
                activity: activity,
                level: .good,
                message: "Wind is within the ideal range for \(activity.title.lowercased())."
            )
        }

        if speed > activity.cautionAbove {
            return WindRecommendation(
                activity: activity,
                level: .notRecommended,
                message: "Wind is too strong for safe \(activity.title.lowercased())."
            )
        }

        if speed < activity.tooLowThreshold {
            return WindRecommendation(
                activity: activity,
                level: .caution,
                message: "Wind may be too light for \(activity.title.lowercased())."
            )
        }

        if speed < optimal.lowerBound {
            return WindRecommendation(
                activity: activity,
                level: .caution,
                message: "Wind is below the ideal range. Proceed with care."
            )
        }

        return WindRecommendation(
            activity: activity,
            level: .caution,
            message: "Wind is above ideal but still manageable."
        )
    }

    static func recommendAll(windSpeedKmh: Double) -> [WindRecommendation] {
        OutdoorActivity.allCases.map { recommend(activity: $0, windSpeedKmh: windSpeedKmh) }
    }
}
