//
//  SpaceSaverApp.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import Cocoa
import Sparkle
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {

	var window: NSWindow?
	var statusItem: NSStatusItem?
	let updaterController = SPUStandardUpdaterController(
		startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

	func applicationDidFinishLaunching(_ notification: Notification) {

		// Add firebase configuration
		FirebaseApp.configure()

		statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		if let button = statusItem?.button {
			button.image = NSImage(
				systemSymbolName: "rectangle.3.group.fill", accessibilityDescription: "Space Saver")
		}
		constructMenu()
	}

	func constructMenu() {
		let menu = NSMenu()

		menu.addItem(NSMenuItem(title: "Open", action: #selector(openAction), keyEquivalent: "O"))
		menu.addItem(NSMenuItem.separator())
		menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "Q"))

		statusItem?.menu = menu
	}

	@objc func openAction() {
		// Create window if it doesn't exist
		if window == nil {
			window = NSWindow(
				contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
				styleMask: [.titled, .closable, .miniaturizable, .resizable],
				backing: .buffered,
				defer: false
			)
			window?.center()
			window?.contentView = NSHostingView(rootView: ContentView())
			window?.title = "Space Saver"
		}

		// Make app active and show window
		NSApp.setActivationPolicy(.regular)
		NSApp.activate(ignoringOtherApps: true)
		window?.makeKeyAndOrderFront(nil)
	}

	@objc func quitAction() {
		NSApplication.shared.terminate(self)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		NSApp.setActivationPolicy(.accessory)
		return false
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
