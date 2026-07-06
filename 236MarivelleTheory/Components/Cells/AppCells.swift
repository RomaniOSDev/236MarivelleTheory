import SwiftUI

// MARK: - Card shell

struct SurfaceCard<Content: View>: View {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    var elevation: CardElevation = .raised
    var bordered: Bool = false
    var highlighted: Bool = false
    @ViewBuilder var content: () -> Content

    private var effectiveElevation: CardElevation {
        bordered ? .floating : elevation
    }

    var body: some View {
        content()
            .padding(padding)
            .depth(effectiveElevation, radius: cornerRadius, highlighted: highlighted)
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button {
                    FeedbackService.lightTap()
                    action()
                } label: {
                    Text(actionTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppPrimary"))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Buttons

struct PrimaryButton: View {
    let title: String
    var icon: String?
    var action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.headline)
            .foregroundStyle(Color("AppBackground"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(AppGradients.primaryButton())
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppGradients.gloss())
                    .allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.20), radius: 6, y: 3)
            .scaleEffect(pressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

struct SecondaryButton: View {
    let title: String
    var icon: String?
    var action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.headline)
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .depth(.raised, radius: 14)
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?

    var body: some View {
        SurfaceCard(elevation: .raised) {
            VStack(spacing: 14) {
                IconOrb(icon: icon, size: 72, tint: Color("AppPrimary"))
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                if let buttonTitle, let buttonAction {
                    PrimaryButton(title: buttonTitle, action: buttonAction)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
