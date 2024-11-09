//
//  Updater.swift
//  SpaceSaver
//
//  Created by Tran Cong on 9/11/24.
//

import Sparkle

class Updater: NSObject, SPUUpdaterDelegate {
    static let shared = Updater()

    private var updaterController: SPUStandardUpdaterController?

    override init() {
        super.init()
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true, updaterDelegate: self, userDriverDelegate: nil)
    }

    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }
}
