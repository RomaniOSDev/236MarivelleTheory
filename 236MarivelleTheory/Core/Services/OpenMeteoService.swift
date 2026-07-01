import Foundation

enum OpenMeteoError: LocalizedError {
    case invalidURL
    case noResults
    case decodingFailed
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request."
        case .noResults: return "No locations found. Try a different city name."
        case .decodingFailed: return "Could not read weather data."
        case .networkError(let message): return message
        }
    }
}

final class OpenMeteoService {
    static let shared = OpenMeteoService()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchLocations(query: String) async throws -> [GeocodingResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: trimmed),
            URLQueryItem(name: "count", value: "8"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components?.url else { throw OpenMeteoError.invalidURL }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        struct Response: Decodable {
            struct Result: Decodable {
                let id: Int?
                let name: String
                let latitude: Double
                let longitude: Double
                let country: String?
            }
            let results: [Result]?
        }

        guard let decoded = try? JSONDecoder().decode(Response.self, from: data),
              let results = decoded.results, !results.isEmpty else {
            throw OpenMeteoError.noResults
        }

        return results.map { item in
            GeocodingResult(
                id: "\(item.name)-\(item.latitude)-\(item.longitude)",
                name: item.name,
                latitude: item.latitude,
                longitude: item.longitude,
                country: item.country ?? ""
            )
        }
    }

    func fetchCurrentWind(latitude: Double, longitude: Double) async throws -> LiveWindConditions {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "wind_speed_10m,wind_direction_10m,wind_gusts_10m"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh")
        ]
        guard let url = components?.url else { throw OpenMeteoError.invalidURL }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        struct Response: Decodable {
            struct Current: Decodable {
                let wind_speed_10m: Double?
                let wind_direction_10m: Double?
                let wind_gusts_10m: Double?
            }
            let current: Current?
        }

        guard let decoded = try? JSONDecoder().decode(Response.self, from: data),
              let current = decoded.current else {
            throw OpenMeteoError.decodingFailed
        }

        return LiveWindConditions(
            speed: current.wind_speed_10m ?? 0,
            gusts: current.wind_gusts_10m ?? current.wind_speed_10m ?? 0,
            direction: Int(current.wind_direction_10m ?? 0)
        )
    }

    func fetchWeeklyForecast(latitude: Double, longitude: Double) async throws -> [WindDay] {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "wind_speed_10m"),
            URLQueryItem(name: "wind_speed_unit", value: "kmh"),
            URLQueryItem(name: "forecast_days", value: "7")
        ]
        guard let url = components?.url else { throw OpenMeteoError.invalidURL }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        struct Response: Decodable {
            struct Hourly: Decodable {
                let time: [String]
                let wind_speed_10m: [Double]
            }
            let hourly: Hourly?
        }

        guard let decoded = try? JSONDecoder().decode(Response.self, from: data),
              let hourly = decoded.hourly,
              hourly.time.count == hourly.wind_speed_10m.count else {
            throw OpenMeteoError.decodingFailed
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackFormatter = ISO8601DateFormatter()

        var dayMap: [Date: [Double]] = [:]
        let calendar = Calendar.current

        for (index, timeString) in hourly.time.enumerated() {
            let date = formatter.date(from: timeString) ?? fallbackFormatter.date(from: timeString)
            guard let date else { continue }
            let day = calendar.startOfDay(for: date)
            dayMap[day, default: []].append(hourly.wind_speed_10m[index])
        }

        return dayMap.keys.sorted().map { day in
            WindDay(date: day, windSpeeds: dayMap[day] ?? [])
        }
    }

    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            throw OpenMeteoError.networkError("Server returned status \(http.statusCode).")
        }
    }
}
