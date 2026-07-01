import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case tracker = 1
    case planner = 2
    case log = 3
    case settings = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .tracker: return "Tracker"
        case .planner: return "Planner"
        case .log: return "Log"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tracker: return "wind"
        case .planner: return "figure.outdoor.cycle"
        case .log: return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @State private var pressedTab: AppTab?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .depth(.floating, radius: 22)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            FeedbackService.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 44, height: 30)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                }
                .frame(height: 30)
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .scaleEffect(pressedTab == tab ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTab = tab }
                .onEnded { _ in pressedTab = nil }
        )
    }
}
