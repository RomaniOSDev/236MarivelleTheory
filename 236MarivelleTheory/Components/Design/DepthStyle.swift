import SwiftUI

// MARK: - Elevation (performance: shadow only on .floating)

enum CardElevation {
    /// Lists & scroll rows — gradient + border, zero shadow
    case flat
    /// Section cards — gradient + gloss highlight, zero shadow
    case raised
    /// Hero / tab bar — single clipped shadow (max few per screen)
    case floating
}

enum AppGradients {
    static func screenBackground() -> LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface").opacity(0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func surface() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func surfaceDeep() -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(0.95),
                Color("AppBackground").opacity(0.55)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func primaryButton() -> LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func accentRing() -> AngularGradient {
        AngularGradient(
            colors: [Color("AppAccent"), Color("AppPrimary"), Color("AppAccent")],
            center: .center
        )
    }

    static func gloss() -> LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.10), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }
}

// MARK: - Depth modifier

struct DepthModifier: ViewModifier {
    let elevation: CardElevation
    let cornerRadius: CGFloat
    var highlighted: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let layered = content
            .background {
                shape.fill(fillGradient)
            }
            .overlay {
                shape.fill(AppGradients.gloss())
                    .allowsHitTesting(false)
            }
            .overlay {
                shape.strokeBorder(borderColor, lineWidth: borderWidth)
                    .allowsHitTesting(false)
            }
            .clipShape(shape)

        switch elevation {
        case .floating:
            layered.shadow(color: .black.opacity(0.28), radius: 10, x: 0, y: 5)
        case .raised, .flat:
            layered
        }
    }

    private var fillGradient: LinearGradient {
        if highlighted {
            return LinearGradient(
                colors: [
                    Color("AppPrimary").opacity(0.20),
                    Color("AppPrimary").opacity(0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return elevation == .flat ? AppGradients.surfaceDeep() : AppGradients.surface()
    }

    private var borderColor: Color {
        if highlighted {
            return Color("AppPrimary").opacity(0.45)
        }
        switch elevation {
        case .floating: return Color("AppPrimary").opacity(0.30)
        case .raised: return Color("AppTextPrimary").opacity(0.08)
        case .flat: return Color("AppBackground").opacity(0.45)
        }
    }

    private var borderWidth: CGFloat {
        highlighted ? 1.5 : 1
    }
}

extension View {
    func depth(
        _ elevation: CardElevation = .raised,
        radius: CGFloat = 16,
        highlighted: Bool = false
    ) -> some View {
        modifier(DepthModifier(elevation: elevation, cornerRadius: radius, highlighted: highlighted))
    }
}

// MARK: - Icon orb (cheap volume, no blur)

struct IconOrb: View {
    let icon: String
    var size: CGFloat = 44
    var tint: Color = Color("AppPrimary")

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tint.opacity(0.28), tint.opacity(0.06)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
            Circle()
                .strokeBorder(tint.opacity(0.25), lineWidth: 1)
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(tint)
        }
    }
}
