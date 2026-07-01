import SwiftUI

struct WindCompassView: View {
    let direction: Int
    var size: CGFloat = 160

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.4), Color("AppSurface")],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 3
                )
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * 45.0
                Text(cardinalLabel(for: index))
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .offset(y: -(size / 2 - 16))
                    .rotationEffect(.degrees(angle))
                    .rotationEffect(.degrees(-angle))
            }
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppPrimary").opacity(0.25), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.35, height: size * 0.35)
            Image(systemName: "location.north.fill")
                .font(.system(size: size * 0.28))
                .foregroundStyle(Color("AppPrimary"))
                .rotationEffect(.degrees(Double(direction)))
                .animation(.easeInOut(duration: 0.3), value: direction)
            VStack(spacing: 2) {
                Spacer()
                Text(WindDirectionLabel.fullLabel(degrees: direction))
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .frame(height: size - 10)
        }
        .frame(width: size, height: size)
        .padding(12)
        .depth(.raised, radius: 16)
    }

    private func cardinalLabel(for index: Int) -> String {
        ["N", "NE", "E", "SE", "S", "SW", "W", "NW"][index]
    }
}

struct BeaufortCardView: View {
    let speedKmh: Double
    var unit: String = "kph"

    private var displaySpeed: Double {
        unit == "mph" ? speedKmh * 0.621371 : speedKmh
    }

    private var unitText: String {
        unit == "mph" ? "mph" : "km/h"
    }

    private var beaufort: BeaufortLevel {
        BeaufortLevel.from(kmh: speedKmh)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Beaufort Scale")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text("Force \(beaufort.scale)")
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppAccent"))
            }
            Text(beaufort.name)
                .font(.title2.bold())
                .foregroundStyle(Color("AppPrimary"))
            Text(beaufort.description)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(String(format: "%.1f %@", displaySpeed, unitText))
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .depth(.raised, radius: 14)
    }
}
