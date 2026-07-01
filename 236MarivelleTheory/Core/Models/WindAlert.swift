import Foundation

struct WindAlert: Codable, Identifiable, Equatable {
    let id: UUID
    var threshold: Double
    var unit: String
    var isEnabled: Bool
    var label: String
    var activityType: OutdoorActivity?
    var spotId: UUID?
    var minThreshold: Double?
    var maxThreshold: Double?

    init(
        id: UUID = UUID(),
        threshold: Double,
        unit: String = "kph",
        isEnabled: Bool = true,
        label: String = "",
        activityType: OutdoorActivity? = nil,
        spotId: UUID? = nil,
        minThreshold: Double? = nil,
        maxThreshold: Double? = nil
    ) {
        self.id = id
        self.threshold = threshold
        self.unit = unit
        self.isEnabled = isEnabled
        self.label = label
        self.activityType = activityType
        self.spotId = spotId
        self.minThreshold = minThreshold
        self.maxThreshold = maxThreshold
    }

    var rangeDescription: String {
        if let min = minThreshold, let max = maxThreshold {
            return String(format: "%.0f–%.0f %@", min, max, unit == "mph" ? "mph" : "km/h")
        }
        return String(format: "≥ %.0f %@", threshold, unit == "mph" ? "mph" : "km/h")
    }
}
