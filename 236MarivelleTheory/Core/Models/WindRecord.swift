import Foundation

struct WindRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let speed: Double
    let gusts: Double
    let direction: Int

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        speed: Double,
        gusts: Double = 0,
        direction: Int = 0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.speed = speed
        self.gusts = gusts
        self.direction = direction
    }
}
