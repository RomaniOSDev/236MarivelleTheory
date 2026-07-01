import SwiftUI

// MARK: - Onboarding

struct OnboardingView: View {
    @ObservedObject var store: AppDataStore
    @State private var currentPage = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 24

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            headline: "Plan Your Kite Session",
            description: "Check real wind speed, gusts, and direction before you head outdoors.",
            icon: "wind",
            imageName: "HomeHero",
            highlights: ["Live Open-Meteo data", "Wind compass & Beaufort", "Weekly forecast chart"]
        ),
        OnboardingPage(
            headline: "Pick Your Activity",
            description: "Get tailored advice for sailing, kite, cycling, running, and hiking.",
            icon: "figure.outdoor.cycle",
            imageName: "HomeActivities",
            highlights: ["5 outdoor activities", "Good / Caution / No-go", "Ideal wind ranges"]
        ),
        OnboardingPage(
            headline: "Log & Learn",
            description: "Save spots, track sessions, and review patterns over time.",
            icon: "book.fill",
            imageName: "HomeWindWidget",
            highlights: ["Session journal & export", "Smart wind alerts", "Personal insights"]
        )
    ]

    var body: some View {
        ZStack {
            BackgroundPatternView()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                pageIndicator
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                PrimaryButton(
                    title: currentPage < pages.count - 1 ? "Next" : "Get Started",
                    icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark"
                ) {
                    advance()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .onChange(of: currentPage) { _ in
            animateContentIn()
        }
        .onAppear {
            animateContentIn()
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "wind")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppPrimary"))
                Text("Step \(currentPage + 1) of \(pages.count)")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .depth(.flat, radius: 20)

            Spacer()

            if currentPage < pages.count - 1 {
                Button {
                    FeedbackService.lightTap()
                    store.hasSeenOnboarding = true
                } label: {
                    Text("Skip")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
            }
        }
    }

    // MARK: - Page

    private func onboardingPage(page: OnboardingPage, index: Int) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                heroCard(page: page, index: index)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)

                SurfaceCard(elevation: .raised) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            IconOrb(icon: page.icon, size: 48, tint: Color("AppPrimary"))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(page.headline)
                                    .font(.title2.bold())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(page.description)
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(page.highlights, id: \.self) { highlight in
                                highlightRow(highlight)
                            }
                        }
                    }
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset * 0.6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
    }

    private func heroCard(page: OnboardingPage, index: Int) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(page.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [.clear, Color("AppBackground").opacity(0.5), Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [Color("AppTextPrimary").opacity(0.08), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .allowsHitTesting(false)

            heroOverlay(for: index)
                .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.45), Color("AppPrimary").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: .black.opacity(0.30), radius: 12, x: 0, y: 6)
    }

    @ViewBuilder
    private func heroOverlay(for index: Int) -> some View {
        switch index {
        case 0:
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Circle().fill(Color("AppAccent")).frame(width: 7, height: 7)
                        Text("LIVE WIND")
                            .font(.caption2.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AppBackground").opacity(0.55))
                    .clipShape(Capsule())

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("24")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("km/h")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer()
                WindCompassView(direction: 225, size: 80)
            }
        case 1:
            HStack(spacing: 10) {
                ForEach([OutdoorActivity.kite, .sailing, .cycling], id: \.id) { activity in
                    ActivityIllustrationView(activity: activity, size: 52)
                }
                Spacer()
            }
        default:
            HStack(spacing: 12) {
                metricChip(icon: "wind", label: "Wind", value: "18 km/h")
                metricChip(icon: "tornado", label: "Gusts", value: "26 km/h")
                Spacer()
            }
        }
    }

    private func metricChip(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption2.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppAccent"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .depth(.flat, radius: 10)
    }

    private func highlightRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(Color("AppAccent"))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    // MARK: - Page indicator

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(AppGradients.primaryButton())
                            : AnyShapeStyle(Color("AppTextSecondary").opacity(0.25))
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
            }
        }
    }

    // MARK: - Actions

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            store.hasSeenOnboarding = true
            FeedbackService.success()
        }
    }

    private func animateContentIn() {
        contentOpacity = 0
        contentOffset = 24
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            contentOpacity = 1
            contentOffset = 0
        }
    }
}

// MARK: - Page model

private struct OnboardingPage {
    let headline: String
    let description: String
    let icon: String
    let imageName: String
    let highlights: [String]
}
