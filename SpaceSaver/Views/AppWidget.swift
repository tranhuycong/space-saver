import SwiftUI

struct AppWidget: View {
  let window: WindowInfo
  
  var body: some View {
    GeometryReader { geometry in
      let windowWidth = geometry.size.width * window.widthPercent
      let windowHeight = geometry.size.height * window.heightPercent
      VStack {
        AppIconView(windowInfo: window, iconSize: 64)
        
        Text(window.ownerName)
          .font(.headline)
          .foregroundColor(.white)
      }
      .frame(width: windowWidth,
        height: windowHeight)
      .background(GradientBackgroundView())
      .cornerRadius(20)
      .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
      .position(
        x: geometry.size.width * window.xPercent + (windowWidth) / 2,
        y: geometry.size.height * window.yPercent + (windowHeight) / 2
      )
    }
  }
}
