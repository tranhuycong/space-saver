import SwiftUI

struct HomeView: View {
  @StateObject private var appService = AppService.shared
  @State private var desktopImage: NSImage?

  var body: some View {
    ScrollView {
      VStack {
        if !AXIsProcessTrusted() {
          HStack {
            Text(
              "App permission: This app needs accessibility permission to open apps on your space."
            )
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
            Spacer()
            Button("Accessibility Settings") {
              NSWorkspace.shared.open(
                URL(
                  string:
                    "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                )!)
            }
          }
        }
        Divider()
        HStack {
          Spacer()
          Button(action: {
            appService.getAllOpenWindows()
          }) {
            Image(
              systemName:
                "arrow.trianglehead.2.clockwise.rotate.90")
          }
          Button("Close apps below") {
            appService.getAllOpenWindows()
            let listOpenApp = appService.spaceInfo.windowList.map { $0.ownerName }
            for app in listOpenApp {
              if !appService.excludedApps.contains(app) {
                NSAppleScript(
                  source: """
                    tell application "\(app)"
                        quit
                    end tell
                    """
                )?.executeAndReturnError(nil)
              }
            }
          }
          Button("Save this space") {
            appService.saveToSpaceList()
          }
        }.padding(.top, 10)
        ZStack {
            Image(nsImage: desktopImage ?? NSImage(named: "SequoiaLight")!)
            .resizable()
            .aspectRatio(16/9, contentMode: .fit)
            .cornerRadius(20)
            .edgesIgnoringSafeArea(.all)
          ForEach(appService.spaceInfo.windowList, id: \.id) { window in
            AppWidget(window: window)
          }
        }
        ScrollView(.horizontal) {
          HStack {
            ForEach(appService.spaceInfo.windowList) { windowInfo in
              VStack {
                ZStack {
                  // Remove button in top right
                  HStack {
                    Spacer()
                    VStack {
                      Button(action: {
                        // Add app to excluded list
                        appService.excludedApps.append(windowInfo.ownerName)
                        // Save updated list
                        UserDefaults.standard.set(appService.excludedApps, forKey: "excludedApps")
                        // Refresh window list
                        appService.getAllOpenWindows()
                      }) {
                        Image(systemName: "xmark.circle.fill")
                          .foregroundColor(.red)
                          .font(.system(size: 16))
                      }
                      .buttonStyle(PlainButtonStyle())
                      .padding(4)
                      Spacer()
                    }
                  }

                  // icon display
                  VStack {
                    AppIconView(windowInfo: windowInfo, iconSize: 32)

                    Text("\(windowInfo.ownerName)")
                      .font(.caption)
                      .lineLimit(1)
                  }
                }
              }
              .frame(width: 80, height: 80)
              .background(
                Color(NSColor.controlBackgroundColor)
                  .cornerRadius(10)
              )
              .cornerRadius(10)
              .padding(10)
            }
          }
        }.frame(minHeight: 100)

        Divider().padding(.vertical)

        Text("Excluded Apps")
          .font(.headline)
          .padding(.leading)

        ScrollView(.horizontal) {
          HStack {
            ForEach(appService.excludedApps, id: \.self) { appName in
              VStack {
                ZStack {
                  // Remove from excluded list button
                  HStack {
                    Spacer()
                    VStack {
                      Button(action: {
                        // Remove app from excluded list
                        if let index = appService.excludedApps.firstIndex(of: appName) {
                          appService.excludedApps.remove(at: index)
                          // Save updated list
                          UserDefaults.standard.set(appService.excludedApps, forKey: "excludedApps")
                          // Refresh window list
                          appService.getAllOpenWindows()
                        }
                      }) {
                        Image(systemName: "plus.circle.fill")
                          .foregroundColor(.green)
                          .font(.system(size: 16))
                      }
                      .buttonStyle(PlainButtonStyle())
                      .padding(4)
                      Spacer()
                    }
                  }

                  VStack {
                    // Try to get app icon
                    if let bundleId = appService.getBundleIdentifier(forAppName: appName),
                      let appUrl = NSWorkspace.shared.urlForApplication(
                        withBundleIdentifier: bundleId)
                    {
                      let icon = NSWorkspace.shared.icon(forFile: appUrl.path)
                      Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    } else {
                      Image(systemName: "app.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                    }

                    Text(appName)
                      .font(.caption)
                      .lineLimit(1)
                  }
                }
              }
              .frame(width: 80, height: 80)
              .background(
                Color(NSColor.controlBackgroundColor)
                  .cornerRadius(10)
              )
              .cornerRadius(10)
              .padding(10)
            }
          }
        }
        .frame(height: 100)
        .padding(.horizontal)

      }
      .padding()
      .onAppear {
        appService.getSpaceList()
        appService.getAllOpenWindows()
        desktopImage = appService.getCurrentDesktopImage()
      }
    }
  }
}
