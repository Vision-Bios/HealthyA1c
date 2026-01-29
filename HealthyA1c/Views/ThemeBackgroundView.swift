import SwiftUI

struct ThemeBackgroundView: View {
    let palette: GraphPalette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            Circle()
                .fill(palette.gradient)
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .opacity(0.35)
                .offset(x: -120, y: -220)

            Circle()
                .fill(palette.gradient)
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .opacity(0.28)
                .offset(x: 160, y: 260)
        }
        .colorScheme(palette.preferredScheme)
    }
}
