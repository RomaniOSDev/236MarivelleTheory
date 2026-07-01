import SwiftUI
import Combine

@MainActor
final class WindTrackerViewModel: ObservableObject {
    @Published var selectedRange: TrackerTimeRange = .current
    @Published var showSpotSheet = false
    @Published var showAlertSheet = false
    @Published var cityQuery = ""
    @Published var searchResults: [GeocodingResult] = []
    @Published var isSearching = false
    @Published var searchError = ""
    @Published var alertIconScale: CGFloat = 1.0

    private let store: AppDataStore

    init(store: AppDataStore = .shared) {
        self.store = store
    }

    var hasSpot: Bool {
        store.selectedSpot != nil
    }

    var hasData: Bool {
        store.currentWindConditions != nil
    }

    var currentSpeed: Double {
        store.currentWindConditions?.speed ?? 0
    }

    var currentGusts: Double {
        store.currentWindConditions?.gusts ?? 0
    }

    var currentDirection: Int {
        store.currentWindConditions?.direction ?? 0
    }

    var displaySpeed: String {
        String(format: "%.1f", store.convertSpeed(currentSpeed, to: store.windSpeedUnit))
    }

    var displayGusts: String {
        String(format: "%.1f", store.convertSpeed(currentGusts, to: store.windSpeedUnit))
    }

    var unitLabel: String {
        store.unitLabel(store.windSpeedUnit)
    }

    var spotName: String {
        store.selectedSpot?.displayName ?? "No spot selected"
    }

    var dailyRecords: [WindRecord] {
        let today = Calendar.current.startOfDay(for: Date())
        return store.windSpeedRecords.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: today)
        }
    }

    func refresh() async {
        await store.refreshWeather()
    }

    func searchCity() async {
        let query = cityQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        isSearching = true
        searchError = ""
        defer { isSearching = false }
        do {
            searchResults = try await store.searchCities(query)
        } catch {
            searchError = error.localizedDescription
            searchResults = []
        }
    }

    func selectSearchResult(_ result: GeocodingResult) async {
        store.addSpot(from: result)
        cityQuery = ""
        searchResults = []
        showSpotSheet = false
        await refresh()
    }

    func onAlertSaved() {
        FeedbackService.alertSaved()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            alertIconScale = 1.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.alertIconScale = 1.0
            }
        }
    }
}

enum TrackerTimeRange: String, CaseIterable {
    case current = "Current"
    case daily = "Daily"
    case weekly = "Weekly"
}
