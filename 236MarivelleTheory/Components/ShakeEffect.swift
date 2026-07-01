import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 0
    var shakes: CGFloat = 3

    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(amount * .pi * shakes), y: 0)
        )
    }
}

struct ShakeModifier: ViewModifier {
    @Binding var shake: Bool

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(amount: shake ? 1 : 0))
            .animation(shake ? .default : nil, value: shake)
            .onChange(of: shake) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        shake = false
                    }
                }
            }
    }
}

extension View {
    func shake(_ shake: Binding<Bool>) -> some View {
        modifier(ShakeModifier(shake: shake))
    }
}
