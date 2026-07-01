import Foundation
import Combine

@MainActor
final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let weatherService = OpenMeteoService.shared

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let windSpeedRecords = "windSpeedRecords"
        static let windAlerts = "windAlerts"
        static let alertThresholdSpeed = "alertThresholdSpeed"
        static let isAlertEnabled = "isAlertEnabled"
        static let windSpeedUnit = "windSpeedUnit"
        static let weeklyWindData = "weeklyWindData"
        static let itemsCreated = "itemsCreated"
        static let windSpots = "windSpots"
        static let selectedSpotId = "selectedSpotId"
        static let activitySessions = "activitySessions"
        static let preferredActivity = "preferredActivity"
        static let currentWindConditions = "currentWindConditions"
        static let isLiveTrackingEnabled = "isLiveTrackingEnabled"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var windSpeedRecords: [WindRecord] {
        didSet { saveCodable(windSpeedRecords, forKey: Keys.windSpeedRecords) }
    }

    @Published var windAlerts: [WindAlert] {
        didSet {
            saveCodable(windAlerts, forKey: Keys.windAlerts)
            itemsCreated = windAlerts.count
        }
    }

    @Published var alertThresholdSpeed: Double {
        didSet { defaults.set(alertThresholdSpeed, forKey: Keys.alertThresholdSpeed) }
    }

    @Published var isAlertEnabled: Bool {
        didSet { defaults.set(isAlertEnabled, forKey: Keys.isAlertEnabled) }
    }

    @Published var windSpeedUnit: String {
        didSet { defaults.set(windSpeedUnit, forKey: Keys.windSpeedUnit) }
    }

    @Published var weeklyWindData: [WindDay] {
        didSet { saveCodable(weeklyWindData, forKey: Keys.weeklyWindData) }
    }

    @Published var itemsCreated: Int {
        didSet { defaults.set(itemsCreated, forKey: Keys.itemsCreated) }
    }

    @Published var windSpots: [WindSpot] {
        didSet { saveCodable(windSpots, forKey: Keys.windSpots) }
    }

    @Published var selectedSpotId: UUID? {
        didSet {
            if let id = selectedSpotId {
                defaults.set(id.uuidString, forKey: Keys.selectedSpotId)
            } else {
                defaults.removeObject(forKey: Keys.selectedSpotId)
            }
        }
    }

    @Published var activitySessions: [ActivitySession] {
        didSet { saveCodable(activitySessions, forKey: Keys.activitySessions) }
    }

    @Published var preferredActivity: OutdoorActivity {
        didSet { defaults.set(preferredActivity.rawValue, forKey: Keys.preferredActivity) }
    }

    @Published var currentWindConditions: LiveWindConditions? {
        didSet { saveCodable(currentWindConditions, forKey: Keys.currentWindConditions) }
    }

    @Published var isLiveTrackingEnabled: Bool {
        didSet { defaults.set(isLiveTrackingEnabled, forKey: Keys.isLiveTrackingEnabled) }
    }

    @Published var isFetchingWeather = false
    @Published var weatherError: String?

    var selectedSpot: WindSpot? {
        guard let id = selectedSpotId else { return windSpots.first }
        return windSpots.first(where: { $0.id == id }) ?? windSpots.first
    }

    var insights: [AppInsight] {
        InsightsService.computeInsights(
            sessions: activitySessions,
            windRecords: windSpeedRecords,
            weeklyData: weeklyWindData,
            streakDays: streakDays,
            preferredActivity: preferredActivity
        )
    }

    private init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        windSpeedRecords = Self.loadCodable([WindRecord].self, from: defaults, key: Keys.windSpeedRecords) ?? []
        windAlerts = Self.loadCodable([WindAlert].self, from: defaults, key: Keys.windAlerts) ?? []
        alertThresholdSpeed = defaults.object(forKey: Keys.alertThresholdSpeed) as? Double ?? 0
        isAlertEnabled = defaults.object(forKey: Keys.isAlertEnabled) as? Bool ?? false
        windSpeedUnit = defaults.string(forKey: Keys.windSpeedUnit) ?? "kph"
        weeklyWindData = Self.loadCodable([WindDay].self, from: defaults, key: Keys.weeklyWindData) ?? []
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        windSpots = Self.loadCodable([WindSpot].self, from: defaults, key: Keys.windSpots) ?? []
        if let idString = defaults.string(forKey: Keys.selectedSpotId),
           let id = UUID(uuidString: idString) {
            selectedSpotId = id
        } else {
            selectedSpotId = nil
        }
        activitySessions = Self.loadCodable([ActivitySession].self, from: defaults, key: Keys.activitySessions) ?? []
        if let raw = defaults.string(forKey: Keys.preferredActivity),
           let activity = OutdoorActivity(rawValue: raw) {
            preferredActivity = activity
        } else {
            preferredActivity = .sailing
        }
        currentWindConditions = Self.loadCodable(LiveWindConditions.self, from: defaults, key: Keys.currentWindConditions)
        isLiveTrackingEnabled = defaults.bool(forKey: Keys.isLiveTrackingEnabled)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
    }

    // MARK: - Spots

    func addSpot(from result: GeocodingResult) {
        let spot = WindSpot(
            name: result.name,
            latitude: result.latitude,
            longitude: result.longitude,
            country: result.country
        )
        if !windSpots.contains(where: {
            $0.name == spot.name && abs($0.latitude - spot.latitude) < 0.01
        }) {
            windSpots.append(spot)
        }
        selectedSpotId = windSpots.first(where: {
            $0.name == spot.name && abs($0.latitude - spot.latitude) < 0.01
        })?.id ?? spot.id
        recordActivity()
    }

    func removeSpot(id: UUID) {
        windSpots.removeAll { $0.id == id }
        if selectedSpotId == id {
            selectedSpotId = windSpots.first?.id
        }
    }

    func selectSpot(_ spot: WindSpot) {
        selectedSpotId = spot.id
        recordActivity()
    }

    // MARK: - Weather

    func refreshWeather() async {
        guard let spot = selectedSpot else {
            weatherError = "Add a spot to load live wind data."
            return
        }
        isFetchingWeather = true
        weatherError = nil
        defer { isFetchingWeather = false }

        do {
            let conditions = try await weatherService.fetchCurrentWind(
                latitude: spot.latitude,
                longitude: spot.longitude
            )
            currentWindConditions = conditions
            addWindRecord(from: conditions)
            evaluateAlerts(with: conditions)
            let weekly = try await weatherService.fetchWeeklyForecast(
                latitude: spot.latitude,
                longitude: spot.longitude
            )
            weeklyWindData = weekly
            isLiveTrackingEnabled = true
            recordActivity()
        } catch {
            weatherError = error.localizedDescription
        }
    }

    func searchCities(_ query: String) async throws -> [GeocodingResult] {
        try await weatherService.searchLocations(query: query)
    }

    private func addWindRecord(from conditions: LiveWindConditions) {
        let record = WindRecord(
            speed: conditions.speed,
            gusts: conditions.gusts,
            direction: conditions.direction
        )
        windSpeedRecords.append(record)
        if windSpeedRecords.count > 500 {
            windSpeedRecords.removeFirst(windSpeedRecords.count - 500)
        }
    }

    private func evaluateAlerts(with conditions: LiveWindConditions) {
        for alert in windAlerts where alert.isEnabled {
            let speed = convertSpeed(conditions.speed, to: alert.unit)
            let gusts = convertSpeed(conditions.gusts, to: alert.unit)

            if let min = alert.minThreshold, let max = alert.maxThreshold {
                let minConverted = alert.unit == "mph" ? min : min
                let maxConverted = alert.unit == "mph" ? max : max
                if speed < minConverted || gusts > maxConverted {
                    continue
                }
            } else if speed < convertSpeed(alert.threshold, to: alert.unit) {
                continue
            }
            _ = alert
        }
    }

    // MARK: - Sessions

    func logSession(
        activity: OutdoorActivity,
        spotName: String,
        windSpeed: Double,
        windGusts: Double,
        windDirection: Int,
        notes: String
    ) {
        let session = ActivitySession(
            activity: activity,
            spotName: spotName,
            windSpeed: windSpeed,
            windGusts: windGusts,
            windDirection: windDirection,
            notes: notes
        )
        activitySessions.insert(session, at: 0)
        totalSessionsCompleted += 1
        recordActivity()
        FeedbackService.success()
    }

    func deleteSession(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            guard index < activitySessions.count else { continue }
            activitySessions.remove(at: index)
        }
    }

    func deleteSession(id: UUID) {
        activitySessions.removeAll { $0.id == id }
    }

    // MARK: - Alerts

    func addAlert(_ alert: WindAlert) {
        windAlerts.append(alert)
        recordActivity()
    }

    func removeAlert(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            guard index < windAlerts.count else { continue }
            windAlerts.remove(at: index)
        }
    }

    func removeAlert(id: UUID) {
        windAlerts.removeAll { $0.id == id }
    }

    func smartAlert(
        for activity: OutdoorActivity,
        spot: WindSpot?,
        label: String
    ) -> WindAlert {
        WindAlert(
            threshold: activity.optimalRange.upperBound,
            unit: windSpeedUnit,
            isEnabled: true,
            label: label,
            activityType: activity,
            spotId: spot?.id,
            minThreshold: activity.optimalRange.lowerBound,
            maxThreshold: activity.cautionAbove
        )
    }

    // MARK: - Activity Tracking

    func recordActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = Date()
    }

    func convertSpeed(_ speed: Double, to unit: String) -> Double {
        unit == "mph" ? speed * 0.621371 : speed
    }

    func unitLabel(_ unit: String) -> String {
        unit == "mph" ? "mph" : "km/h"
    }

    // MARK: - Reset

    @objc private func handleDataReset() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()

        hasSeenOnboarding = false
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        windSpeedRecords = []
        windAlerts = []
        alertThresholdSpeed = 0
        isAlertEnabled = false
        windSpeedUnit = "kph"
        weeklyWindData = []
        itemsCreated = 0
        windSpots = []
        selectedSpotId = nil
        activitySessions = []
        preferredActivity = .sailing
        currentWindConditions = nil
        isLiveTrackingEnabled = false
        weatherError = nil
    }

    func resetAllData() {
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    // MARK: - Persistence Helpers

    private func saveCodable<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadCodable<T: Decodable>(_ type: T.Type, from defaults: UserDefaults, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
