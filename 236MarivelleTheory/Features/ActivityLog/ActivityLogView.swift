import SwiftUI
import UIKit

struct ActivityLogView: View {
    @StateObject private var viewModel = ActivityLogViewModel()
    @ObservedObject private var store = AppDataStore.shared
    @State private var shareCSV: ShareCSVItem?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundPatternView()
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.sessions.isEmpty && viewModel.filterActivity == nil && store.activitySessions.isEmpty {
                            EmptyStateView(
                                icon: "book.fill",
                                title: "No Sessions Yet",
                                message: "Record outdoor plans and how wind affected your session.",
                                buttonTitle: "Log Session"
                            ) {
                                viewModel.showAddSheet = true
                            }
                        } else {
                            statsHeader
                            filterChips
                            if !viewModel.sessions.isEmpty {
                                exportButton
                                sessionsList
                            } else {
                                EmptyStateView(
                                    icon: "line.3.horizontal.decrease.circle",
                                    title: "No Matching Sessions",
                                    message: "Try a different activity filter or log a new session."
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Activity Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        viewModel.showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) { addSessionSheet }
            .sheet(item: $shareCSV) { item in ShareSheet(items: [item.url]) }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 10) {
            StatGridCell(label: "Total", value: "\(viewModel.totalSessions)", icon: "book.fill")
            StatGridCell(
                label: "Avg Wind",
                value: viewModel.averageWind > 0 ? String(format: "%.0f", viewModel.averageWind) : "—",
                icon: "wind"
            )
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: viewModel.filterActivity == nil) {
                    viewModel.filterActivity = nil
                }
                ForEach(OutdoorActivity.allCases) { activity in
                    FilterChip(title: activity.title, isSelected: viewModel.filterActivity == activity) {
                        viewModel.filterActivity = activity
                    }
                }
            }
        }
    }

    private var exportButton: some View {
        SecondaryButton(title: "Export CSV", icon: "square.and.arrow.up") {
            let url = writeTempCSV(viewModel.exportCSV())
            shareCSV = ShareCSVItem(url: url)
        }
    }

    private var sessionsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.sessions) { session in
                SessionLogCell(session: session)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            FeedbackService.lightTap()
                            store.deleteSession(id: session.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private var addSessionSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        if let wind = store.currentWindConditions, let spot = store.selectedSpot {
                            SurfaceCard(bordered: true) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label(spot.displayName, systemImage: "mappin")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    HStack {
                                        MetricPillCell(icon: "wind", title: "Wind", value: String(format: "%.1f km/h", wind.speed), accent: true)
                                        MetricPillCell(icon: "tornado", title: "Gusts", value: String(format: "%.1f km/h", wind.gusts))
                                    }
                                    Text(WindDirectionLabel.fullLabel(degrees: wind.direction))
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                        SurfaceCard {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(title: "Session Details")
                                ForEach(OutdoorActivity.allCases) { activity in
                                    ActivityCell(
                                        activity: activity,
                                        isSelected: viewModel.selectedActivity == activity,
                                        onTap: {
                                            viewModel.selectedActivity = activity
                                            FeedbackService.lightTap()
                                        }
                                    )
                                }
                                TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                                    .lineLimit(3...6)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .shake($viewModel.shakeField)
                                if !viewModel.validationError.isEmpty {
                                    Text(viewModel.validationError)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        PrimaryButton(title: "Save Session", icon: "checkmark") {
                            FeedbackService.mediumAction()
                            _ = viewModel.saveSession()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        viewModel.showAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func writeTempCSV(_ csv: String) -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("activity_log_\(Int(Date().timeIntervalSince1970)).csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}

struct ShareCSVItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
