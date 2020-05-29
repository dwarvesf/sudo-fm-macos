//
//  App.swift
//  sudofm
//
//  Created by phucld on 6/5/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

enum App {
    static let id = Bundle.main.bundleIdentifier!
    static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    static let versionWithBuild = "\(version) (\(build))"
    static let icon = NSApp.applicationIconImage!
    static let url = Bundle.main.bundleURL

    static func quit() {
        NSApp.terminate(nil)
    }

    static let isFirstLaunch: Bool = {
        let key = "sudofm_hasLaunched"

        if UserDefaults.standard.bool(forKey: key) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
    }()
}

extension AppDelegate {
    static let shared = NSApp.delegate as! AppDelegate
}
