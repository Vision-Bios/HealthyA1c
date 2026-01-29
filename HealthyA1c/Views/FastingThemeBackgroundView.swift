import SwiftUI

struct FastingThemeBackgroundView: View {
    let palette: FastingPalette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            Circle()
                .fill(palette.gradient)
                .frame(width: 320, height: 320)
                .blur(radius: 120)
                .opacity(0.40)
                .offset(x: -120, y: -240)

            Circle()
                .fill(palette.gradient)
                .frame(width: 280, height: 280)
                .blur(radius: 120)
                .opacity(0.30)
                .offset(x: 150, y: 260)
        }
        .colorScheme(palette.preferredScheme)
    }
}
