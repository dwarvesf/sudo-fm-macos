//
//  GeneralPreferenceViewController.swift
//  MicMonitor
//
//  Created by phucld on 2/28/20.
//  Copyright © 2020 Dwarvesf. All rights reserved.
//

import Cocoa
import Preferences
import Sparkle

final class GeneralPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    
    override var nibName: NSNib.Name? { "GeneralPreferenceViewController" }
    
    @IBOutlet weak var checkboxStartAtLogin: NSButton!
    @IBOutlet weak var checkboxShowPreferencesOnLaunch: NSButton!
    @IBOutlet weak var btnCheckForUpdate: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPreferenes()
    }
    
    private func fetchPreferenes() {
        checkboxStartAtLogin.state = LocalStorage.startAtLogin ? .on : .off
        checkboxShowPreferencesOnLaunch.state = LocalStorage.showPreferencesOnlaunch ? .on : .off
    }
    
    @IBAction func checkForUpdate(_ sender: Any) {
        SUUpdater.shared()?.checkForUpdates(self)
    }
    
    @IBAction func toggleStartAtLogin(_ sender: NSButton) {
        switch sender.state {
        case .on:
            LocalStorage.startAtLogin = true
        case .off:
            LocalStorage.startAtLogin = false
        default:
            break
        }
    }
    
    @IBAction func toggleShowPreferencesOnLaunch(_ sender: NSButton) {
        switch sender.state {
        case .on:
            LocalStorage.showPreferencesOnlaunch = true
        case .off:
            LocalStorage.showPreferencesOnlaunch = false
        default:
            break
        }
    }
}
