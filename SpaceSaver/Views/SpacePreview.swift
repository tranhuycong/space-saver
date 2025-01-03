import SwiftUI
import AppKit

struct AppPreviewWidget: View {
  let window: WindowInfo
  
  var body: some View {
    GeometryReader { geometry in
      let windowWidth = geometry.size.width * window.widthPercent
      let windowHeight = geometry.size.height * window.heightPercent
      VStack {
        AppIconView(windowInfo: window, iconSize: 14)
      }
      .frame(width: windowWidth,
        height: windowHeight)
      .background(GradientBackgroundView())
      .cornerRadius(4)
      .position(
        x: geometry.size.width * window.xPercent + (windowWidth) / 2,
        y: geometry.size.height * window.yPercent + (windowHeight) / 2
      )
    }
  }
}


struct SpacePreview: View {
  var space: SpaceInfo

  @StateObject private var appService = AppService.shared
  @State private var desktopImage: NSImage?

  init(space: SpaceInfo) {
    self.space = space
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      ZStack {
        Image(nsImage: desktopImage ?? NSImage(named: "SequoiaLight")!)
          .resizable()
          .cornerRadius(4)
          .edgesIgnoringSafeArea(.all)
        ForEach(space.windowList, id: \.id) { window in
          AppPreviewWidget(window: window)
        }
      }
    }
    .navigationTitle(space.name)
    .onAppear {
      desktopImage = getCurrentDesktopImage()
    }
  }

  private func getCurrentDesktopImage() -> NSImage? {
    guard let screen = NSScreen.main,
          let imageURL = NSWorkspace.shared.desktopImageURL(for: screen),
          let desktopImage = NSImage(contentsOf: imageURL) else {
        return NSImage(named: "SequoiaLight")
    }
    return desktopImage
  }
}
