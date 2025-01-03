import SwiftUI

struct AppWidget: View {
  let window: WindowInfo
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        AppIconView(windowInfo: window, iconSize: 64)
        
        Text(window.ownerName)
          .font(.headline)
          .foregroundColor(.white)
      }
      .frame(width: geometry.size.width * window.widthPercent,
        height: geometry.size.height * window.heightPercent)
      .background(GradientBackgroundView())
      .cornerRadius(20)
      .position(x: geometry.size.width * window.xPercent,
                y: geometry.size.height * window.yPercent)
    }
  }
}
