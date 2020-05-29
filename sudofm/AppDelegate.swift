//
//  AppDelegate.swift
//  sudofm
//
//  Created by phucld on 5/29/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa
import Preferences
import MASShortcut
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(),
            ShortcutsPreferenceViewController(),
            AboutPreferenceViewController()
        ],
        style: .segmentedControl
    )
    
    lazy var menuStatusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Example", action: nil, keyEquivalent: ""))
            button.menu = menu
            
            let slider = GesturableCircularSlider()
            slider.doubleValue = LocalStorage.musicVolume
            slider.onScrollGesture = {
                LocalStorage.musicVolume = slider.doubleValue
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "musicVolumeDidChange"), object: slider)
            }
            
            button.addSubview(slider)
            NSLayoutConstraint.activate([
                slider.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                slider.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            ])
            
            popover.delegate = self
            popover.contentViewController = PopoverViewControler()
            
        }
        
        return statusItem
    }()
    
    lazy var eventMonitor: EventMonitor = {
        let eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let self = self, self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        
        return eventMonitor
    }()
    
    let popover = NSPopover()
    
    // Mark: - App lifecycle
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerDefault()
        setupAutoStart()
        showPreferencesScreenIfNeeded()
        fetchData()
        startTimerForFetchingData()
        configAppCenter()
        
        _ = menuStatusItem
        
        setupGlobalHotkey()
    }
    
    func configAppCenter() {
        MSAppCenter.start("0615366d-ef91-48bf-85c0-962986fec932", withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
    }
    
    // Mark: - Other methods
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = menuStatusItem.button {
            let positioningView = NSView(frame: button.bounds)
            
            // set an identifier for positioning view, so we can easily remove it later.
            positioningView.identifier = NSUserInterfaceItemIdentifier(rawValue: "positioningView")
            
            button.addSubview(positioningView)

            // show popover
            popover.show(relativeTo: positioningView.bounds, of: positioningView, preferredEdge: .minY)
            
            // move positioning view away
            positioningView.bounds = button.bounds.offsetBy(dx: 0, dy: button.bounds.height)
            
            if let popWindow = popover.contentViewController?.view.window {
                popWindow.setFrame(popWindow.frame.offsetBy(dx: 0, dy: 10), display: false)

                popWindow.parent?.removeChildWindow(popWindow)
            }
        }
        
        eventMonitor.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor.stop()
    }
    
    func setupAutoStart() {
        LauncherManager.shared.setupMainApp(isAutoStart: LocalStorage.startAtLogin)

    }
    
    func showPreferencesScreenIfNeeded() {
        if LocalStorage.showPreferencesOnlaunch {
            preferencesWindowController.show()
        }
    }
    
    func registerDefault() {
        UserDefaults.standard.register(defaults: [
            UserDefaults.Key.startAtLogin: false,
            UserDefaults.Key.showPreferencesOnLaunch: true,
            UserDefaults.Key.musicVolume: 50.0,
            UserDefaults.Key.selectedMood: Mood.code.rawValue
        ])
        
        let defaultSelectedAmbiences: [AmbienceSound] = [
            .init(type: .coffeHouse, volume: 0.5, isEnabled: false),
            .init(type: .summerRain, volume: 0.5, isEnabled: true),
            .init(type: .seaWaves, volume: 0.5, isEnabled: false)
        ]
        
        if let selectedAmbienceData = try? JSONEncoder().encode(defaultSelectedAmbiences) {
            UserDefaults.standard.register(defaults: [
                UserDefaults.Key.selectedAmbiences: selectedAmbienceData
            ])
        }
        
        setDefaultShortcut()
    }
    
    func setDefaultShortcut() {
        let togglePlay = MASShortcut(keyCode: kVK_ANSI_Semicolon, modifierFlags: [.command, .shift])
        let playShortcut = NSKeyedArchiver.archivedData(withRootObject: togglePlay as Any)
        
        let nextSong = MASShortcut(keyCode: kVK_ANSI_L, modifierFlags: [.command, .shift])
        let nextSongShortcut = NSKeyedArchiver.archivedData(withRootObject: nextSong as Any)
        
        let previousSong = MASShortcut(keyCode: kVK_ANSI_H, modifierFlags: [.command, .shift])
        let previousSongShortcut = NSKeyedArchiver.archivedData(withRootObject: previousSong as Any)
        
        let shufflePlaylist = MASShortcut(keyCode: kVK_ANSI_J, modifierFlags: [.command, .shift])
        let shufflePlaylistShortcut = NSKeyedArchiver.archivedData(withRootObject: shufflePlaylist as Any)
        
        UserDefaults.standard.register(defaults: [
            Shortcut.kTogglePlay: playShortcut,
            Shortcut.kNextSong: nextSongShortcut,
            Shortcut.kPreviousSong: previousSongShortcut,
            Shortcut.kShufflePlaylist: shufflePlaylistShortcut,
        ])
    }
    
    
    func setupGlobalHotkey() {
        guard let popoverVC = popover.contentViewController as? PopoverViewControler
            else {return}
        
        MASShortcutBinder.shared()?.bindShortcut(
        withDefaultsKey: Shortcut.kTogglePlay) {
            popoverVC.toggleMusic(self)
        }
        
        MASShortcutBinder.shared()?.bindShortcut(
        withDefaultsKey: Shortcut.kNextSong) {
            popoverVC.forwardSong(self)
        }
        
        MASShortcutBinder.shared()?.bindShortcut(
        withDefaultsKey: Shortcut.kPreviousSong) {
            popoverVC.backwardSong(self)
        }
        
        MASShortcutBinder.shared()?.bindShortcut(
            withDefaultsKey: Shortcut.kShufflePlaylist) {
            popoverVC.shufflePlaylist(self)
        }
    }
    
    
    
    var timer: RepeatingTimer? = nil

    func startTimerForFetchingData() {

        if timer == nil {
            timer = RepeatingTimer(timeInterval: 60 * 60 * 8) // every 8 hour
             
             timer?.eventHandler = { [weak self] in
                 self?.fetchData()
             }
             timer?.resume()
        }
    }
    
    @objc
    private func fetchData() {
        NetworkManager.shared.getMoods { result in
            switch result {
            case .success(let moods):
                guard !moods.isEmpty else {return}
                
                let code = moods.first { $0.id == 6 }
                let chill = moods.first { $0.id == 3 }
                let sleep = moods.first { $0.id == 4}
                
                let filteredMoods = [code, chill, sleep].compactMap { $0 }
                
                LocalStorage.mooods = filteredMoods
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension AppDelegate: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        let positioningView = menuStatusItem.button?.subviews.first {
            $0.identifier?.rawValue == "positioningView"
        }
        positioningView?.removeFromSuperview()
    }
}
