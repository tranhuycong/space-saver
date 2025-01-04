//
//  SpaceyApp.swift
//  Spacey
//
//  Created by Tran Cong on 7/10/24.
//

import Cocoa
import Sparkle
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, SPUUpdaterDelegate {
	private var window: NSWindow?
	private var windowController: NSWindowController?
	var statusItem: NSStatusItem?
	let updaterController = SPUStandardUpdaterController(
		startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

	func applicationDidFinishLaunching(_ notification: Notification) {

		// Add firebase configuration
		FirebaseApp.configure()

		// Set the app to always use dark mode
		NSApp.appearance = NSAppearance(named: .darkAqua)

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
		DispatchQueue.main.async {
			// Change from accessory to regular app mode
			NSApp.setActivationPolicy(.regular)
			
			// Create and configure window if needed
			if self.windowController == nil {
				let window = NSWindow(
					contentRect: NSRect(x: 0, y: 0, width: 1000, height: 800),
					styleMask: [.titled, .closable, .miniaturizable, .resizable],
					backing: .buffered,
					defer: false
				)
				window.center()
				window.title = "Space Saver"
				window.contentView = NSHostingView(rootView: ContentView())
				
				// Create window controller to manage window lifecycle
				self.windowController = NSWindowController(window: window)
				
				// Set window close handler
				window.delegate = self
			}
			
			self.windowController?.showWindow(nil)
			NSApp.activate(ignoringOtherApps: true)
		}
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

	func windowWillClose(_ notification: Notification) {
		windowController = nil
		NSApp.setActivationPolicy(.accessory)
	}

}

@main
struct SpaceyApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
