import SwiftUI

struct WindTrackerView: View {
    @StateObject private var viewModel = WindTrackerViewModel()
    @ObservedObject private var store = AppDataStore.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var newAlertLabel = ""
    @State private var selectedAlertActivity: OutdoorActivity = .kite
    @State private var selectedChartDay: Int?
    @State private var validationError = ""
    @State private var shakeField = false

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 300)) { _ in
                ZStack {
                    BackgroundPatternView()
                    ScrollView {
                        VStack(spacing: 16) {
                            spotHeader
                            if viewModel.hasData {
                                WindGaugeHero(
                                    speed: viewModel.currentSpeed,
                                    unit: store.windSpeedUnit,
                                    unitLabel: viewModel.unitLabel,
                                    gusts: viewModel.currentGusts,
                                    subtitle: "Live from Open-Meteo"
                                )
                                metricsRow
                                HStack(alignment: .top, spacing: 12) {
                                    WindCompassView(direction: viewModel.currentDirection, size: 140)
                                    BeaufortCardView(speedKmh: viewModel.currentSpeed, unit: store.windSpeedUnit)
                                }
                                rangePicker
                                rangeContent
                                if !store.weeklyWindData.isEmpty {
                                    WeeklyMiniChart(
                                        data: store.weeklyWindData,
                                        unit: store.windSpeedUnit,
                                        selectedIndex: selectedChartDay,
                                        onSelect: { selectedChartDay = $0 }
                                    )
                                    if let idx = selectedChartDay, idx < store.weeklyWindData.count {
                                        dayDetailCard(store.weeklyWindData[idx])
                                    }
                                }
                            } else {
                                EmptyStateView(
                                    icon: "wind",
                                    title: "No Wind Data",
                                    message: "Add a city spot to load real-time wind speed, gusts, and direction.",
                                    buttonTitle: "Add Spot"
                                ) {
                                    viewModel.showSpotSheet = true
                                }
                                if let error = store.weatherError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            actionButtons
                            if !store.windAlerts.isEmpty {
                                alertsSection
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Live Wind")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        Task { await viewModel.refresh() }
                    } label: {
                        if store.isFetchingWeather {
                            ProgressView().tint(Color("AppPrimary"))
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(store.selectedSpot == nil)
                }
            }
            .sheet(isPresented: $viewModel.showSpotSheet) { spotSheet }
            .sheet(isPresented: $viewModel.showAlertSheet) { alertSheet }
            .onChange(of: scenePhase) { phase in
                if phase == .active, store.selectedSpot != nil {
                    Task { await viewModel.refresh() }
                }
            }
            .task {
                if store.selectedSpot != nil {
                    await viewModel.refresh()
                }
            }
        }
    }

    private var spotHeader: some View {
        Button {
            FeedbackService.lightTap()
            viewModel.showSpotSheet = true
        } label: {
            HStack(spacing: 12) {
                IconOrb(icon: "mappin.and.ellipse", size: 44, tint: Color("AppPrimary"))
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.spotName)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    HStack(spacing: 6) {
                        if store.isLiveTrackingEnabled {
                            Circle().fill(Color("AppAccent")).frame(width: 6, height: 6)
                            Text("Live")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppAccent"))
                        }
                        if let updated = store.currentWindConditions?.fetchedAt {
                            Text("· \(updated, style: .time)")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(14)
            .depth(.raised, radius: 16)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }

    private var metricsRow: some View {
        HStack(spacing: 10) {
            MetricPillCell(icon: "wind", title: "Wind", value: "\(viewModel.displaySpeed) \(viewModel.unitLabel)", accent: true)
            MetricPillCell(icon: "tornado", title: "Gusts", value: "\(viewModel.displayGusts) \(viewModel.unitLabel)")
        }
    }

    private var rangePicker: some View {
        Picker("Range", selection: $viewModel.selectedRange) {
            ForEach(TrackerTimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedRange) { _ in FeedbackService.lightTap() }
    }

    @ViewBuilder
    private var rangeContent: some View {
        switch viewModel.selectedRange {
        case .current: currentDetail
        case .daily: dailyDetail
        case .weekly: weeklyDetail
        }
    }

    private var currentDetail: some View {
        SurfaceCard {
            VStack(spacing: 0) {
                WindReadingRow(time: Date(), speed: "\(viewModel.displaySpeed) \(viewModel.unitLabel)")
                Divider().background(Color("AppBackground").opacity(0.4))
                WindReadingRow(time: Date(), speed: "Gusts \(viewModel.displayGusts)")
                Divider().background(Color("AppBackground").opacity(0.4))
                WindReadingRow(time: Date(), speed: WindDirectionLabel.fullLabel(degrees: viewModel.currentDirection))
            }
        }
    }

    private var dailyDetail: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 4) {
                SectionHeader(title: "Today's Readings", subtitle: "\(viewModel.dailyRecords.count) samples")
                if viewModel.dailyRecords.isEmpty {
                    Text("No readings yet today.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(viewModel.dailyRecords.suffix(8).reversed()) { record in
                        WindReadingRow(
                            time: record.timestamp,
                            speed: String(format: "%.1f %@", store.convertSpeed(record.speed, to: store.windSpeedUnit), viewModel.unitLabel)
                        )
                        if record.id != viewModel.dailyRecords.suffix(8).reversed().last?.id {
                            Divider().background(Color("AppBackground").opacity(0.3))
                        }
                    }
                }
            }
        }
    }

    private var weeklyDetail: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Weekly Summary")
                if store.weeklyWindData.isEmpty {
                    Text("No forecast data yet.").foregroundStyle(Color("AppTextSecondary"))
                } else {
                    let avg = store.weeklyWindData.map(\.averageSpeed).reduce(0, +) / Double(store.weeklyWindData.count)
                    HStack {
                        Text("Average")
                        Spacer()
                        Text(String(format: "%.1f %@", store.convertSpeed(avg, to: store.windSpeedUnit), viewModel.unitLabel))
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }

    private func dayDetailCard(_ day: WindDay) -> some View {
        SurfaceCard(bordered: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text(day.date, style: .date)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack {
                    detailPill("Max", String(format: "%.1f", day.maxSpeed))
                    detailPill("Min", String(format: "%.1f", day.minSpeed))
                    detailPill("Avg", String(format: "%.1f", day.averageSpeed))
                }
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func detailPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(Color("AppTextSecondary"))
            Text(value).font(.subheadline.bold()).foregroundStyle(Color("AppAccent"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .depth(.flat, radius: 10)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            SecondaryButton(title: viewModel.hasSpot ? "Change Spot" : "Add Spot", icon: "mappin") {
                viewModel.showSpotSheet = true
            }
            PrimaryButton(title: "Set Wind Alerts", icon: "bell.badge.fill") {
                viewModel.showAlertSheet = true
            }
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Active Alerts", subtitle: "\(store.windAlerts.count) configured")
            ForEach(store.windAlerts) { alert in
                AlertCell(
                    alert: alert,
                    spotName: alert.spotId.flatMap { id in store.windSpots.first(where: { $0.id == id })?.displayName },
                    isEnabled: bindingForAlert(alert)
                )
            }
        }
    }

    private func bindingForAlert(_ alert: WindAlert) -> Binding<Bool> {
        Binding(
            get: { store.windAlerts.first(where: { $0.id == alert.id })?.isEnabled ?? false },
            set: { newValue in
                if let index = store.windAlerts.firstIndex(where: { $0.id == alert.id }) {
                    store.windAlerts[index].isEnabled = newValue
                }
            }
        )
    }

    private var spotSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 12) {
                        SurfaceCard {
                            VStack(spacing: 10) {
                                TextField("Enter city name", text: $viewModel.cityQuery)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .submitLabel(.search)
                                    .onSubmit { Task { await viewModel.searchCity() } }
                                PrimaryButton(title: "Search", icon: "magnifyingglass") {
                                    Task { await viewModel.searchCity() }
                                }
                                if !viewModel.searchError.isEmpty {
                                    Text(viewModel.searchError).font(.caption).foregroundStyle(.red)
                                }
                            }
                        }
                        if !store.windSpots.isEmpty {
                            SectionHeader(title: "Saved Spots")
                            ForEach(store.windSpots) { spot in
                                SpotCell(
                                    spot: spot,
                                    isSelected: store.selectedSpotId == spot.id,
                                    onTap: {
                                        store.selectSpot(spot)
                                        viewModel.showSpotSheet = false
                                        Task { await viewModel.refresh() }
                                    }
                                )
                            }
                        }
                        if !viewModel.searchResults.isEmpty {
                            SectionHeader(title: "Search Results")
                            ForEach(viewModel.searchResults) { result in
                                Button {
                                    Task { await viewModel.selectSearchResult(result) }
                                } label: {
                                    HStack {
                                        Text(result.country.isEmpty ? result.name : "\(result.name), \(result.country)")
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(Color("AppPrimary"))
                                    }
                                    .padding(14)
                                    .depth(.flat, radius: 14)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Wind Spots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        viewModel.showSpotSheet = false
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var alertSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Alert label", text: $newAlertLabel)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                ForEach(OutdoorActivity.allCases) { activity in
                                    ActivityCell(
                                        activity: activity,
                                        isSelected: selectedAlertActivity == activity,
                                        onTap: {
                                            selectedAlertActivity = activity
                                            FeedbackService.lightTap()
                                        }
                                    )
                                }
                                if !validationError.isEmpty {
                                    Text(validationError).font(.caption).foregroundStyle(.red)
                                }
                            }
                        }
                        PrimaryButton(title: "Save Alert", icon: "checkmark") {
                            saveSmartAlert()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Smart Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        viewModel.showAlertSheet = false
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func saveSmartAlert() {
        let label = newAlertLabel.isEmpty ? "\(selectedAlertActivity.title) Alert" : newAlertLabel
        store.addAlert(store.smartAlert(for: selectedAlertActivity, spot: store.selectedSpot, label: label))
        FeedbackService.success()
        viewModel.onAlertSaved()
        viewModel.showAlertSheet = false
        newAlertLabel = ""
    }
}
