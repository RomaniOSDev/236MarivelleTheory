import SwiftUI

struct SuccessCheckmark: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                    }
                }
        }
    }
}

struct PulseModifier: ViewModifier {
    @Binding var isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .background(isPulsing ? Color("AppAccent").opacity(0.35) : Color.clear)
            .animation(.easeInOut(duration: 0.4), value: isPulsing)
            .onChange(of: isPulsing) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isPulsing = false
                    }
                }
            }
    }
}

extension View {
    func successPulse(_ isPulsing: Binding<Bool>) -> some View {
        modifier(PulseModifier(isPulsing: isPulsing))
    }
}
