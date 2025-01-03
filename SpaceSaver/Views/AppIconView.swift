import SwiftUI

struct AppIconView: View {
  let windowInfo: WindowInfo
  let iconSize: CGFloat
    
  var body: some View {
    if let bundleId = AppService.shared.getBundleIdentifier(forAppName: windowInfo.ownerName),
      let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
      let icon = NSWorkspace.shared.icon(forFile: appUrl.path)
      Image(nsImage: icon)
        .resizable()
        .frame(width: iconSize, height: iconSize)
    } else {
      Image(systemName: "app.fill")
        .resizable()
        .frame(width: iconSize, height: iconSize)
    }
  }
}
