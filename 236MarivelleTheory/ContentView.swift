import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = AppDataStore.shared

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView(store: store)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            UIAppearanceService.configure()
        }
    }
}

#Preview {
    ContentView()
}
