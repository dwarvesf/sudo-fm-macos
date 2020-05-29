//
//  AppDelegate.swift
//  launcher
//
//  Created by phucld on 6/5/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LauncherManager.shared.setupLauncher()
    }
}

