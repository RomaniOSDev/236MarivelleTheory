import Foundation

struct ActivitySession: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var activity: OutdoorActivity
    var spotName: String
    var windSpeed: Double
    var windGusts: Double
    var windDirection: Int
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        activity: OutdoorActivity,
        spotName: String,
        windSpeed: Double,
        windGusts: Double = 0,
        windDirection: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.activity = activity
        self.spotName = spotName
        self.windSpeed = windSpeed
        self.windGusts = windGusts
        self.windDirection = windDirection
        self.notes = notes
    }
}
