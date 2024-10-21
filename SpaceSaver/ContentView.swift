//
//  ContentView.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import AppKit
import ApplicationServices
import Cocoa
import CoreGraphics
import SwiftUI

struct ContentView: View {
    @State private var spaceInfo: SpaceInfo = SpaceInfo.init(windowList: [])!
    @State private var spaceList: SpaceList = SpaceList()
    private var ignoreApps: [String] = ["SpaceSaver", "Finder"]
    var body: some View {
        ScrollView {
            VStack {
                Text("Spaces:")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                Button("Open Terminal") {
                    openAppAtPosition(
                        appName: "Terminal",
                        bounds: [0, 0, 500, 500])
                }
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(spaceList.data) { item in
                            VStack {
                                Text("\(item.name)")
                                    .padding(10)
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
                                        openSpace(
                                            at: spaceList.data.firstIndex {
                                                $0.id == item.id
                                            }!)
                                    }
                                    Spacer()
                                    Button(action: {
                                        let index = spaceList.data.firstIndex {
                                            $0.id == item.id
                                        }
                                        if index != nil {
                                            deleteSpace(at: index!)
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
                        getAllOpenWindows()
                    }) {
                        Image(
                            systemName:
                                "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    Button("Close all apps") {
                        let listOpenApp = spaceInfo.windowList.map { $0.ownerName }
                        for app in listOpenApp {
                            if !ignoreApps.contains(app) {
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
                    Button("Save space") {
                        saveToSpaceList()
                    }
                }.padding(.top, 10)
                List(spaceInfo.windowList) { windowInfo in
                    Text("\(windowInfo.ownerName)")
                        .padding(5)
                }
                .frame(minHeight: 100)
            }
            .padding()
            .onAppear {
                getAllOpenWindows()
                getSpaceList()
            }
        }
    }

    func openSpace(at index: Int) {
        let space = spaceList.data[index]
        for window in space.windowList {
            if !ignoreApps.contains(window.ownerName) {
                let bounds = [
                    window.bounds.origin.x,
                    window.bounds.origin.y,
                    window.bounds.origin.x + window.bounds.size.width,
                    window.bounds.origin.y + window.bounds.size.height,
                ]
                openAppAtPosition(
                    appName: window.ownerName,
                    bounds: bounds)
            }
        }
    }

    func deleteSpace(at index: Int) {
        spaceList.data.remove(at: index)
        UserDefaultsHelper.spaceList = spaceList
    }

    func getSpaceList() {
        spaceList = UserDefaultsHelper.spaceList
    }

    func getAllOpenWindows() {
        let options = CGWindowListOption(
            arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowsListInfo as! [[String: Any]]
        let visibleWindows = infoList.filter {
            $0["kCGWindowLayer"] as! Int == 0
                && ignoreApps.contains($0["kCGWindowOwnerName"] as! String) == false
        }
        print(visibleWindows)

        spaceInfo = SpaceInfo(
            windowList: visibleWindows.compactMap(WindowInfo.init))!
    }

    func saveToSpaceList() {
        spaceList.data.insert(spaceInfo, at: 0)
        UserDefaultsHelper.spaceList = spaceList
    }

    func openAppAtPosition(appName: String, bounds: [CGFloat]) {
        print("Open \(appName) at \(bounds)")

        if let bundleIdentifier = getBundleIdentifier(forAppName: appName) {
            print("Bundle Identifier: \(bundleIdentifier)")
            if let appURL = NSWorkspace.shared.urlForApplication(
                withBundleIdentifier: bundleIdentifier)
            {
                let appPath = appURL.path
                let url =
                    NSURL(
                        fileURLWithPath: appPath,
                        isDirectory: true)
                    as URL

                let configuration = NSWorkspace.OpenConfiguration()
                configuration.arguments = []
                configuration.createsNewApplicationInstance = true
                configuration.environment = [
                    "NSWindowFrame": "\(bounds[0]) \(bounds[1]) \(bounds[2]) \(bounds[3])"
                ]
                NSWorkspace.shared.openApplication(
                    at: url,
                    configuration: configuration,
                    completionHandler: { (app, error) in
                        if error == nil {
                            let appleScript = """
                                tell application "\(appName)"
                                    set the bounds of the first window to {\(bounds[0]), \(bounds[1]), \(bounds[2]), \(bounds[3])}
                                end tell
                                """
                            var error: NSDictionary?
                            if let scriptObject = NSAppleScript(source: appleScript) {
                                scriptObject.executeAndReturnError(&error)
                                if let error = error {
                                    print("AppleScript Error: \(error)")
                                }
                            }
                        } else {
                            print("Error launching application: \(String(describing: error))")
                        }
                    })
            }
        }
    }

    func getBundleIdentifier(forAppName appName: String) -> String? {
        let fileManager = FileManager.default
        let applicationPaths = [
            "/Applications",
            "/System/Applications",
            "/System/Applications/Utilities",
            "\(fileManager.homeDirectoryForCurrentUser.path)/Applications",
            "/System/Library/CoreServices",
        ]

        for path in applicationPaths {
            if let appURLs = try? fileManager.contentsOfDirectory(
                at: URL(fileURLWithPath: path), includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)
            {
                for appURL in appURLs where appURL.pathExtension == "app" {
                    let bundle = Bundle(url: appURL)
                    if let name = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String,
                        name == appName
                    {
                        return bundle?.bundleIdentifier
                    } else if let displayName = bundle?.object(
                        forInfoDictionaryKey: "CFBundleDisplayName") as? String,
                        displayName == appName
                    {
                        return bundle?.bundleIdentifier
                    }
                }
            }
        }
        return nil
    }
}

#Preview {
    ContentView()
}
