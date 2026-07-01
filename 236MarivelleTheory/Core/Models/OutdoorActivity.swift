import Foundation

enum OutdoorActivity: String, Codable, CaseIterable, Identifiable {
    case sailing
    case kite
    case cycling
    case running
    case hiking

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sailing: return "Sailing"
        case .kite: return "Kite"
        case .cycling: return "Cycling"
        case .running: return "Running"
        case .hiking: return "Hiking"
        }
    }

    var iconName: String {
        switch self {
        case .sailing: return "sailboat.fill"
        case .kite: return "wind"
        case .cycling: return "bicycle"
        case .running: return "figure.run"
        case .hiking: return "figure.hiking"
        }
    }

    /// Optimal wind range in km/h
    var optimalRange: ClosedRange<Double> {
        switch self {
        case .sailing: return 11...27
        case .kite: return 15...25
        case .cycling: return 5...20
        case .running: return 0...15
        case .hiking: return 0...20
        }
    }

    var cautionAbove: Double {
        switch self {
        case .sailing: return 35
        case .kite: return 30
        case .cycling: return 30
        case .running: return 25
        case .hiking: return 40
        }
    }

    var tooLowThreshold: Double {
        switch self {
        case .sailing: return 8
        case .kite: return 10
        case .cycling: return 0
        case .running: return 0
        case .hiking: return 0
        }
    }

    var rangeDescription: String {
        let min = Int(optimalRange.lowerBound)
        let max = Int(optimalRange.upperBound)
        return "Optimal \(min)–\(max) km/h"
    }
}

enum WindRecommendationLevel: String, Codable {
    case good = "Good to go"
    case caution = "Caution"
    case notRecommended = "Not recommended"

    var iconName: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .notRecommended: return "xmark.circle.fill"
        }
    }
}

struct WindRecommendation: Equatable {
    let activity: OutdoorActivity
    let level: WindRecommendationLevel
    let message: String
}
