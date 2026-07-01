import SwiftUI

struct ActivityIllustrationView: View {
    let activity: OutdoorActivity
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppPrimary").opacity(0.22),
                            Color("AppAccent").opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .strokeBorder(Color("AppPrimary").opacity(0.2), lineWidth: 1)
                .frame(width: size, height: size)
            illustration
                .frame(width: size * 0.7, height: size * 0.7)
        }
    }

    @ViewBuilder
    private var illustration: some View {
        switch activity {
        case .sailing:
            SailingShape()
                .stroke(Color("AppPrimary"), lineWidth: 2.5)
        case .kite:
            KiteShape()
                .fill(Color("AppAccent"))
        case .cycling:
            CyclingShape()
                .stroke(Color("AppPrimary"), lineWidth: 2.5)
        case .running:
            RunningShape()
                .fill(Color("AppAccent"))
        case .hiking:
            HikingShape()
                .stroke(Color("AppPrimary"), lineWidth: 2.5)
        }
    }
}

private struct SailingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 4))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 8))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 8))
        path.addLine(to: CGPoint(x: rect.maxX - 6, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 10))
        path.closeSubpath()
        path.addEllipse(in: CGRect(x: rect.midX - 18, y: rect.maxY - 14, width: 36, height: 10))
        return path
    }
}

private struct KiteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 4))
        path.addLine(to: CGPoint(x: rect.maxX - 6, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 4))
        path.addLine(to: CGPoint(x: rect.minX + 6, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct CyclingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.minX + 4, y: rect.midY, width: 18, height: 18))
        path.addEllipse(in: CGRect(x: rect.maxX - 22, y: rect.midY, width: 18, height: 18))
        path.move(to: CGPoint(x: rect.minX + 13, y: rect.midY + 6))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + 10))
        path.addLine(to: CGPoint(x: rect.maxX - 13, y: rect.midY + 6))
        return path
    }
}

private struct RunningShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.midX - 6, y: rect.minY + 4, width: 12, height: 12))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 16))
        path.addLine(to: CGPoint(x: rect.midX - 8, y: rect.maxY - 6))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 20))
        path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY - 4))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY + 24))
        path.addLine(to: CGPoint(x: rect.midX - 12, y: rect.midY))
        return path
    }
}

private struct HikingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 8, y: rect.maxY - 6))
        path.addLine(to: CGPoint(x: rect.midX - 4, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX + 6, y: rect.minY + 8))
        path.addLine(to: CGPoint(x: rect.maxX - 8, y: rect.maxY - 6))
        return path
    }
}

struct RecommendationBadge: View {
    let recommendation: WindRecommendation

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(levelColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: recommendation.level.iconName)
                    .font(.title2)
                    .foregroundStyle(levelColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                StatusBadge(level: recommendation.level)
                Text(recommendation.message)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private var levelColor: Color {
        switch recommendation.level {
        case .good: return Color("AppAccent")
        case .caution: return Color("AppPrimary")
        case .notRecommended: return Color.red.opacity(0.85)
        }
    }
}
