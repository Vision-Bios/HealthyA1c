import SwiftUI

struct PointsView: View {
    @StateObject private var pointsViewModel = PointsViewModel()
    @StateObject private var paletteViewModel = HbA1cViewModel()
    @State private var totalPulse = false

    var body: some View {
        ZStack {
            ThemeBackgroundView(palette: paletteViewModel.selectedPalette)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Points Earned")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goals accomplished")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        Text("\(pointsViewModel.goalPoints)")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.glow)
                            .scaleEffect(totalPulse ? 1.04 : 1.0)
                            .animation(.easeInOut(duration: 0.9), value: totalPulse)

                        Text("Goals you completed in Today's Focus.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(paletteViewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    HStack(spacing: 12) {
                        pointsPill(title: "Total points",
                                   value: pointsViewModel.totalPoints,
                                   symbol: "star.circle")
                        pointsPill(title: "Entries",
                                   value: pointsViewModel.dataEntryPoints,
                                   symbol: "square.and.pencil")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("By category")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

                        categoryRow(title: "Health data",
                                    subtitle: "A1c, Body, Glucose",
                                    points: pointsViewModel.healthDataPoints,
                                    symbol: "waveform.path.ecg")

                        categoryRow(title: "Lifestyle",
                                    subtitle: "Walking",
                                    points: pointsViewModel.lifestylePoints,
                                    symbol: "figure.walk")

                        categoryRow(title: "Diet",
                                    subtitle: "Meals and Fasting",
                                    points: pointsViewModel.dietPoints,
                                    symbol: "leaf")
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(paletteViewModel.selectedPalette.cardBackground,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding()
            }
        }
        .onAppear {
            paletteViewModel.load()
            pointsViewModel.load()
            withAnimation(.easeInOut(duration: 0.9).repeatCount(2, autoreverses: true)) {
                totalPulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                totalPulse = false
            }
        }
    }

    @ViewBuilder
    private func pointsPill(title: String, value: Int, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(paletteViewModel.selectedPalette.textColor)

            Text("\(value)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(paletteViewModel.selectedPalette.glow)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(paletteViewModel.selectedPalette.cardBackground,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private func categoryRow(title: String,
                             subtitle: String,
                             points: Int,
                             symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(paletteViewModel.selectedPalette.glow)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(paletteViewModel.selectedPalette.textColor)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(points)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(paletteViewModel.selectedPalette.glow)
        }
        .padding(12)
        .background(paletteViewModel.selectedPalette.inputBackground,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    PointsView()
}
