import SwiftUI
import AppKit

struct SpaceDetail: View {
  var space: SpaceInfo

  @StateObject private var appService = AppService.shared
  @State private var isEditing = false
  @State private var editedName: String
  @State private var desktopImage: NSImage?

  @FocusState private var isFocused: Bool

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
          .focused($isFocused)
          .onSubmit(saveName)
          .onChange(of: isFocused) { focused in
            if !focused {
              saveName()
            }
          }
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
      desktopImage = appService.getCurrentDesktopImage()
    }
  }

  private func saveName() {
    isEditing = false
    if let index = appService.spaceList.data.firstIndex(where: {
      $0.id == space.id
    }) {
      appService.spaceList.data[index].name = editedName
      UserDefaultsHelper.spaceList = appService.spaceList
    }
  }
}
