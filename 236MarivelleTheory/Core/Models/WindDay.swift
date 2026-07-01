import Foundation

struct WindDay: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    var windSpeeds: [Double]

    init(id: UUID = UUID(), date: Date, windSpeeds: [Double]) {
        self.id = id
        self.date = date
        self.windSpeeds = windSpeeds
    }

    var averageSpeed: Double {
        guard !windSpeeds.isEmpty else { return 0 }
        return windSpeeds.reduce(0, +) / Double(windSpeeds.count)
    }

    var maxSpeed: Double {
        windSpeeds.max() ?? 0
    }

    var minSpeed: Double {
        windSpeeds.min() ?? 0
    }
}
