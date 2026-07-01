import SwiftUI

struct SmartAlertsView: View {
    @ObservedObject private var store = AppDataStore.shared
    @State private var showAddSheet = false
    @State private var labelText = ""
    @State private var selectedActivity: OutdoorActivity = .kite
    @State private var selectedSpotId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(
                title: "Smart Alerts",
                subtitle: "Activity-based wind thresholds",
                actionTitle: store.windAlerts.isEmpty ? nil : "Add",
                action: store.windAlerts.isEmpty ? nil : { showAddSheet = true }
            )
            if store.windAlerts.isEmpty {
                EmptyStateView(
                    icon: "bell.badge",
                    title: "No Alerts Yet",
                    message: "Create activity-based alerts with optimal wind ranges per spot.",
                    buttonTitle: "Add Smart Alert"
                ) {
                    openAddSheet()
                }
            } else {
                ForEach(store.windAlerts) { alert in
                    AlertCell(
                        alert: alert,
                        spotName: alert.spotId.flatMap { id in
                            store.windSpots.first(where: { $0.id == id })?.displayName
                        },
                        isEnabled: bindingForAlert(alert)
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            FeedbackService.lightTap()
                            store.removeAlert(id: alert.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                PrimaryButton(title: "Add Smart Alert", icon: "plus") {
                    openAddSheet()
                }
            }
        }
        .sheet(isPresented: $showAddSheet) { addAlertSheet }
    }

    private func openAddSheet() {
        FeedbackService.lightTap()
        selectedActivity = store.preferredActivity
        selectedSpotId = store.selectedSpotId
        showAddSheet = true
    }

    private var addAlertSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Label", text: $labelText)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                ForEach(OutdoorActivity.allCases) { activity in
                                    ActivityCell(
                                        activity: activity,
                                        isSelected: selectedActivity == activity,
                                        onTap: {
                                            selectedActivity = activity
                                            FeedbackService.lightTap()
                                        }
                                    )
                                }
                            }
                        }
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "Spot", subtitle: "Optional — any spot if not set")
                                ForEach(store.windSpots) { spot in
                                    SpotCell(
                                        spot: spot,
                                        isSelected: selectedSpotId == spot.id,
                                        onTap: {
                                            selectedSpotId = selectedSpotId == spot.id ? nil : spot.id
                                        }
                                    )
                                }
                                if store.windSpots.isEmpty {
                                    Text("Add spots on the Tracker tab.")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(selectedActivity.rangeDescription)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color("AppAccent"))
                                Text("You'll be notified when wind falls outside the optimal range.")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                        PrimaryButton(title: "Save Alert", icon: "checkmark") { saveAlert() }
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
                        showAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func saveAlert() {
        let spot = selectedSpotId.flatMap { id in store.windSpots.first(where: { $0.id == id }) }
        let label = labelText.isEmpty ? "\(selectedActivity.title) Alert" : labelText
        store.addAlert(store.smartAlert(for: selectedActivity, spot: spot, label: label))
        FeedbackService.alertSetupSaved()
        FeedbackService.success()
        labelText = ""
        showAddSheet = false
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
}
