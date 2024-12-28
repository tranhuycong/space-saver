import SwiftUI

struct HeaderView: View {
  var body: some View {
    HStack {
      Text("Space Saver")
        .font(.headline)
      Spacer()
      Menu {
        Button("About") {
          if let url = URL(string: "https://tranhuycong.github.io/space-saver/") {
            NSWorkspace.shared.open(url)
          }
        }
        Button("Quit") {
          NSApplication.shared.terminate(nil)
        }
      } label: {
        Image(systemName: "gearshape")
      }
      .menuStyle(BorderlessButtonMenuStyle())
      .menuIndicator(.hidden)
    }
  }
}
