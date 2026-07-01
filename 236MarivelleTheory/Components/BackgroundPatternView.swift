import SwiftUI

struct BackgroundPatternView: View {
    var body: some View {
        ZStack {
            AppGradients.screenBackground()

            // Ambient orbs — no blur, GPU-friendly solid gradients
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppPrimary").opacity(0.14), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -120, y: -220)
                .allowsHitTesting(false)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppAccent").opacity(0.10), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: 140, y: 320)
                .allowsHitTesting(false)

            // Dot pattern — cached via drawingGroup, wider spacing = fewer draws
            Canvas { context, size in
                let spacing: CGFloat = 40
                var x: CGFloat = spacing / 2
                while x < size.width {
                    var y: CGFloat = spacing / 2
                    while y < size.height {
                        let rect = CGRect(x: x, y: y, width: 2, height: 2)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color("AppTextPrimary").opacity(0.05))
                        )
                        y += spacing
                    }
                    x += spacing
                }
            }
            .drawingGroup(opaque: false)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
