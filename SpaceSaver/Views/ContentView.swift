//
//  ContentView.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import AppKit
import SwiftUI

struct ContentView: View {

  @StateObject private var appService = AppService.shared

  var body: some View {
    ScrollView {
      VStack {
        HeaderView()
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
        Text("Saved Spaces: ")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
        ScrollView(.horizontal) {
          HStack {
            ForEach(appService.spaceList.data) { item in
              VStack {
                ScrollView(.vertical) {
                  HStack {
                    Text("\(item.name)")
                      .padding(10)
                      .fixedSize(horizontal: false, vertical: true)
                    Button(action: {
                      let alert = NSAlert()
                      alert.messageText = "Edit Space Name"
                      alert.informativeText =
                        "Enter a new name for the space:"
                      alert.alertStyle = .informational
                      alert.addButton(withTitle: "OK")
                      alert.addButton(withTitle: "Cancel")

                      let inputTextField = NSTextField(
                        frame: NSRect(x: 0, y: 0, width: 200, height: 24))
                      inputTextField.stringValue = item.name
                      alert.accessoryView = inputTextField

                      let response = alert.runModal()
                      if response == .alertFirstButtonReturn {
                        let newName = inputTextField.stringValue
                        if let index = appService.spaceList.data.firstIndex(where: {
                          $0.id == item.id
                        }) {
                          appService.spaceList.data[index].name = newName
                          UserDefaultsHelper.spaceList = appService.spaceList
                        }
                      }
                    }) {
                      Image(systemName: "pencil")
                    }
                  }
                }.frame(height: 40)
                Divider()
                ScrollView {
                  VStack {
                    ForEach(item.windowList) { windowInfo in
                      Text("\(windowInfo.ownerName)")
                        .frame(
                          maxWidth: .infinity,
                          alignment: .leading
                        )
                        .padding(.horizontal, 10)
                    }
                  }
                  .padding(.vertical, 10)
                }.frame(height: 100)
                Divider()
                HStack {
                  Button("Open") {
                    appService.openSpace(
                      at: appService.spaceList.data.firstIndex {
                        $0.id == item.id
                      }!)
                  }
                  Spacer()
                  Button(action: {
                    let index = appService.spaceList.data.firstIndex {
                      $0.id == item.id
                    }
                    if index != nil {
                      appService.deleteSpace(at: index!)
                    }
                  }) {
                    Image(systemName: "trash")
                      .foregroundColor(.red)
                  }
                }.padding(.horizontal, 10)
                  .padding(.vertical, 5)
              }.frame(width: 150, height: 200)
                .background(
                  Color(NSColor.controlBackgroundColor)
                    .cornerRadius(10)
                )
                .cornerRadius(10)
                .padding(10)
            }
          }
        }
        Divider()
        HStack {
          Text("Opening apps on this space:")
          Spacer()
          Button(action: {
            appService.getAllOpenWindows()
          }) {
            Image(
              systemName:
                "arrow.trianglehead.2.clockwise.rotate.90")
          }
          Button("Close apps on this space") {
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
                    if let bundleId = appService.getBundleIdentifier(forAppName: windowInfo.ownerName),
                        let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                      let icon = NSWorkspace.shared.icon(forFile: appUrl.path)
                      Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    } else {
                      Image(systemName: "app.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                    }

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
      }
    }
  }
}

#Preview {
  ContentView()
}
