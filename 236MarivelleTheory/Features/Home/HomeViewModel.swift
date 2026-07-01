import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isRefreshing = false

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    var hasWindData: Bool {
        store.currentWindConditions != nil
    }

    var windSpeed: Double {
        store.currentWindConditions?.speed ?? 0
    }

    var windGusts: Double {
        store.currentWindConditions?.gusts ?? 0
    }

    var windDirection: Int {
        store.currentWindConditions?.direction ?? 0
    }

    var spotName: String {
        store.selectedSpot?.displayName ?? "No spot selected"
    }

    var recommendation: WindRecommendation {
        ActivityRecommendationService.recommend(
            activity: store.preferredActivity,
            windSpeedKmh: windSpeed
        )
    }

    var beaufort: BeaufortLevel {
        BeaufortLevel.from(kmh: windSpeed)
    }

    var displaySpeed: String {
        String(format: "%.1f", store.convertSpeed(windSpeed, to: store.windSpeedUnit))
    }

    var unitLabel: String {
        store.unitLabel(store.windSpeedUnit)
    }

    var recentSessions: [ActivitySession] {
        Array(store.activitySessions.prefix(3))
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    func refresh() async {
        isRefreshing = true
        await store.refreshWeather()
        isRefreshing = false
    }
}
