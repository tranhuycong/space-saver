//
//  SpaceSaverApp.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import Cocoa
import Sparkle
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
    var statusItem: NSStatusItem?
    let updaterController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "rectangle.3.group.fill", accessibilityDescription: "Space Saver")
            button.action = #selector(statusBarButtonClicked)
        }
    }

    @objc func statusBarButtonClicked() {
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 600, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.show(
            relativeTo: statusItem!.button!.bounds, of: statusItem!.button!,
            preferredEdge: NSRectEdge.minY)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

}

@main
struct SpaceSaverApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
