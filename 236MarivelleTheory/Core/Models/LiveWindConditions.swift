import Foundation

struct LiveWindConditions: Codable, Equatable {
    var speed: Double
    var gusts: Double
    var direction: Int
    var fetchedAt: Date

    init(speed: Double, gusts: Double, direction: Int, fetchedAt: Date = Date()) {
        self.speed = speed
        self.gusts = gusts
        self.direction = direction
        self.fetchedAt = fetchedAt
    }
}

struct GeocodingResult: Identifiable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
}
