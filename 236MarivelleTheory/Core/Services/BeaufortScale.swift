import Foundation

struct BeaufortLevel: Equatable {
    let scale: Int
    let name: String
    let description: String

    static func from(kmh: Double) -> BeaufortLevel {
        let levels: [(Int, Double, String, String)] = [
            (0, 1, "Calm", "Smoke rises vertically"),
            (1, 5, "Light Air", "Smoke drifts slowly"),
            (2, 11, "Light Breeze", "Leaves rustle"),
            (3, 19, "Gentle Breeze", "Leaves and twigs move"),
            (4, 28, "Moderate Breeze", "Dust and paper blow"),
            (5, 38, "Fresh Breeze", "Small trees sway"),
            (6, 49, "Strong Breeze", "Large branches move"),
            (7, 61, "Near Gale", "Whole trees in motion"),
            (8, 74, "Gale", "Twigs break off trees"),
            (9, 88, "Strong Gale", "Slight structural damage"),
            (10, 102, "Storm", "Trees uprooted"),
            (11, 117, "Violent Storm", "Widespread damage"),
            (12, Double.greatestFiniteMagnitude, "Hurricane", "Devastating damage")
        ]
        let speed = max(0, kmh)
        for (index, threshold, name, desc) in levels {
            if speed < threshold {
                return BeaufortLevel(scale: index, name: name, description: desc)
            }
        }
        return BeaufortLevel(scale: 12, name: "Hurricane", description: "Devastating damage")
    }
}

enum WindDirectionLabel {
    static func label(degrees: Int) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((Double(degrees) + 11.25) / 22.5) % 16
        return directions[index]
    }

    static func fullLabel(degrees: Int) -> String {
        "\(label(degrees: degrees)) (\(degrees)°)"
    }
}
