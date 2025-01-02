import SwiftUI

struct GradientBackgroundView: View {
  var body: some View {
    ZStack {
      // Gradient Background
      LinearGradient(
        gradient: Gradient(colors: [
          Color.blue,
          Color.purple,
          Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)),
        ]),
        startPoint: .bottomLeading,
        endPoint: .topTrailing
      )
      .edgesIgnoringSafeArea(.all)

      // Vignette Effect
      RadialGradient(gradient: Gradient(colors: [
        Color.clear,
        Color.black.opacity(0.2)  // Darker edges
      ]), center: .center, startRadius: 100, endRadius: 500)
        .blendMode(.multiply)
        .edgesIgnoringSafeArea(.all)

      // Noise Overlay
      Image("noiseTexture")
        .resizable()
        .scaledToFill()
        .blendMode(.overlay)
        .opacity(0.4)
        .edgesIgnoringSafeArea(.all)
        .cornerRadius(30)
    }
  }
}
