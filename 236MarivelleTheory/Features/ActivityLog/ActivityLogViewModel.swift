import SwiftUI
import Combine

@MainActor
final class ActivityLogViewModel: ObservableObject {
    @Published var selectedActivity: OutdoorActivity = .sailing
    @Published var notes = ""
    @Published var showAddSheet = false
    @Published var validationError = ""
    @Published var shakeField = false
    @Published var filterActivity: OutdoorActivity?

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
        selectedActivity = store.preferredActivity
    }

    var sessions: [ActivitySession] {
        guard let filter = filterActivity else { return store.activitySessions }
        return store.activitySessions.filter { $0.activity == filter }
    }

    var totalSessions: Int { store.activitySessions.count }

    var averageWind: Double {
        guard !store.activitySessions.isEmpty else { return 0 }
        let total = store.activitySessions.map(\.windSpeed).reduce(0, +)
        return total / Double(store.activitySessions.count)
    }

    func saveSession() -> Bool {
        guard store.selectedSpot != nil || store.currentWindConditions != nil else {
            validationError = "Add a spot and refresh wind data first."
            shakeField = true
            FeedbackService.warning()
            return false
        }
        let spotName = store.selectedSpot?.displayName ?? "Unknown spot"
        let wind = store.currentWindConditions
        store.logSession(
            activity: selectedActivity,
            spotName: spotName,
            windSpeed: wind?.speed ?? 0,
            windGusts: wind?.gusts ?? 0,
            windDirection: wind?.direction ?? 0,
            notes: notes
        )
        notes = ""
        validationError = ""
        showAddSheet = false
        return true
    }

    func exportCSV() -> String {
        SessionExportService.csv(from: store.activitySessions)
    }
}
