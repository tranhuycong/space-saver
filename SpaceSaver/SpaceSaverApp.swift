//
//  SpaceSaverApp.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import Cocoa
import SwiftUI

func requestAccessibilityPermissions() {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    let accessEnabled = AXIsProcessTrustedWithOptions(options)

    if !accessEnabled {
        print(
            "Accessibility permissions are not enabled. Please enable them in System Preferences.")
    } else {
        print("Accessibility permissions are already enabled.")
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        requestAccessibilityPermissions()
    }
}

@main
struct SpaceSaverApp: App {
    init() {
        requestAccessibilityPermissions()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
