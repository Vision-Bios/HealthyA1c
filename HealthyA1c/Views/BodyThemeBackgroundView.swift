import SwiftUI

struct BodyThemeBackgroundView: View {
    let palette: BodyPalette

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            Circle()
                .fill(palette.gradient)
                .frame(width: 320, height: 320)
                .blur(radius: 110)
                .opacity(0.40)
                .offset(x: -120, y: -240)

            Circle()
                .fill(palette.gradient)
                .frame(width: 280, height: 280)
                .blur(radius: 110)
                .opacity(0.30)
                .offset(x: 140, y: 240)
        }
        .colorScheme(palette.preferredScheme)
    }
}
