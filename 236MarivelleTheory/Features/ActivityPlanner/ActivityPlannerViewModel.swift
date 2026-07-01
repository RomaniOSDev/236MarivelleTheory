import SwiftUI
import Combine

@MainActor
final class ActivityPlannerViewModel: ObservableObject {
    @Published var selectedActivity: OutdoorActivity

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
        selectedActivity = store.preferredActivity
    }

    var currentWindKmh: Double {
        store.currentWindConditions?.speed ?? 0
    }

    var recommendation: WindRecommendation {
        ActivityRecommendationService.recommend(
            activity: selectedActivity,
            windSpeedKmh: currentWindKmh
        )
    }

    var allRecommendations: [WindRecommendation] {
        ActivityRecommendationService.recommendAll(windSpeedKmh: currentWindKmh)
    }

    func selectActivity(_ activity: OutdoorActivity) {
        selectedActivity = activity
        store.preferredActivity = activity
        FeedbackService.lightTap()
    }
}
