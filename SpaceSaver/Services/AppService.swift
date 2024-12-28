import AppKit
import ApplicationServices
import Cocoa
import CoreGraphics
import SwiftUICore

class AppService: ObservableObject {
  static let shared = AppService()

  @Published var spaceInfo: SpaceInfo
  @Published var spaceList: SpaceList
  @Published var excludedApps: [String]

  public init() {
    self.spaceInfo = SpaceInfo(windowList: [])!
    self.spaceList = SpaceList()
    self.excludedApps = UserDefaults.standard.stringArray(forKey: "excludedApps") ?? []

    setupWindowChangeObserver()
  }

  func setupWindowChangeObserver() {
    let notifications: [NSNotification.Name] = [
      NSWindow.didBecomeKeyNotification
    ]

    let notificationCenter = NotificationCenter.default
    notifications.forEach { notification in
      notificationCenter.addObserver(
        forName: notification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.getAllOpenWindows()
      }
    }
  }

  func openSpace(at index: Int) {
    let space = spaceList.data[index]
    guard let mainScreen = NSScreen.main else { return }
    let screenFrame = mainScreen.frame

    for window in space.windowList {
      if !excludedApps.contains(window.ownerName) {
        let xPosition = window.xPercent * screenFrame.width
        let yPosition = window.yPercent * screenFrame.height
        let bounds = [
          xPosition,
          yPosition,
          xPosition + window.widthPercent * screenFrame.width,
          yPosition + window.heightPercent * screenFrame.height,
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
    let workspace = NSWorkspace.shared
    let options: CGWindowListOption = [.excludeDesktopElements, .optionOnScreenOnly]

    // Get main screen dimensions
    guard let screen = NSScreen.main,
      let windowsListInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID)
        as? [[String: Any]]
    else {
      return
    }

    let screenFrame = screen.frame
    let screenWidth = screenFrame.width
    let screenHeight = screenFrame.height

    let visibleWindows = windowsListInfo.filter { window in
      guard let layer = window["kCGWindowLayer"] as? Int,
        let ownerName = window["kCGWindowOwnerName"] as? String
      else {
        return false
      }
      return layer == 0 && !excludedApps.contains(ownerName)
    }.map { window -> [String: Any] in
      var windowInfo = window

      // Convert bounds to percentages
      if let bounds = window["kCGWindowBounds"] as? [String: CGFloat] {
        let x = bounds["X"] ?? 0
        let y = bounds["Y"] ?? 0
        let width = bounds["Width"] ?? 0
        let height = bounds["Height"] ?? 0

        let xPercent = (x / screenWidth)
        let yPercent = (y / screenHeight)
        let widthPercent = (width / screenWidth)
        let heightPercent = (height / screenHeight)

        windowInfo["xPercent"] = xPercent
        windowInfo["yPercent"] = yPercent
        windowInfo["widthPercent"] = widthPercent
        windowInfo["heightPercent"] = heightPercent
      }

      return windowInfo
    }

    spaceInfo = SpaceInfo(windowList: visibleWindows.compactMap(WindowInfo.init))!
  }

  func saveToSpaceList() {
    spaceList.data.insert(spaceInfo, at: 0)
    UserDefaultsHelper.spaceList = spaceList
  }

  func openAppAtPosition(appName: String, bounds: [CGFloat]) {
    print("Open \(appName) at \(bounds)")

    // Try to open the application by its name first
    if !NSWorkspace.shared.launchApplication(appName) {
      print("Failed to open \(appName) by name, trying with bundle identifier")

      // If opening by name fails, try to get the bundle identifier
      if let bundleIdentifier = getBundleIdentifier(forAppName: appName) {
        print("Bundle Identifier: \(bundleIdentifier)")
        if let appURL = NSWorkspace.shared.urlForApplication(
          withBundleIdentifier: bundleIdentifier)
        {
          let appPath = appURL.path
          let url = NSURL(fileURLWithPath: appPath, isDirectory: true) as URL

          let configuration = NSWorkspace.OpenConfiguration()
          configuration.arguments = []
          configuration.createsNewApplicationInstance = true
          NSWorkspace.shared.openApplication(
            at: url, configuration: configuration,
            completionHandler: { (app, error) in
              if error == nil {
                self.trySetWindowPosition(
                  appName: appName, bounds: bounds, retries: 5)
              } else {
                print("Error launching application: \(String(describing: error))")
              }
            })
        }
      } else {
        print("Could not find bundle identifier for app: \(appName)")
      }
    } else {
      // If opening by name succeeds, set the window position
      self.trySetWindowPosition(appName: appName, bounds: bounds, retries: 5)
    }
  }

  func trySetWindowPosition(appName: String, bounds: [CGFloat], retries: Int) {
    let appleScript = """
      tell application "System Events"
          tell process "\(appName)"
              if exists window 1 then
                  set the position of window 1 to {\(bounds[0]), \(bounds[1])}
                  set the size of window 1 to {\(bounds[2] - bounds[0]), \(bounds[3] - bounds[1])}
              else
                  error "No windows found for application \(appName)"
              end if
          end tell
      end tell
      """
    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: appleScript) {
      scriptObject.executeAndReturnError(&error)
      if let error = error {
        print("AppleScript Error: \(error)")
        if retries > 0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.trySetWindowPosition(
              appName: appName, bounds: bounds, retries: retries - 1)
          }
        }
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
