import SwiftUI
import AppKit

struct SpaceDetail: View {
  var space: SpaceInfo

  @StateObject private var appService = AppService.shared
  @State private var isEditing = false
  @State private var editedName: String
  @State private var desktopImage: NSImage?

  init(space: SpaceInfo) {
    self.space = space
    _editedName = State(initialValue: space.name)
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        if isEditing {
          TextField("Space Name", text: $editedName)
          .font(.largeTitle)
          .padding(.bottom, 10)
          .onSubmit {
              isEditing = false
              // Save the new name
              if let index = appService.spaceList.data.firstIndex(where: {
                $0.id == space.id
              }) {
                appService.spaceList.data[index].name = editedName
                UserDefaultsHelper.spaceList = appService.spaceList
              }
          }
        } else {
          Text(space.name)
            .font(.largeTitle)
            .padding(.bottom, 10)
            .onTapGesture {
                isEditing = true
            }
        }

        Spacer()

        Button("Launch") {
          //Launch space
          appService.openSpace(at: appService.spaceList.data.firstIndex(where: {
            $0.id == space.id
          })!)
        }
      }

      ZStack {
        Image(nsImage: desktopImage ?? NSImage(named: "SequoiaLight")!)
          .resizable()
          .cornerRadius(20)
          .edgesIgnoringSafeArea(.all)
        ForEach(space.windowList, id: \.id) { window in
          AppWidget(window: window)
        }
      }
      .padding()
    }
    .padding()
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
