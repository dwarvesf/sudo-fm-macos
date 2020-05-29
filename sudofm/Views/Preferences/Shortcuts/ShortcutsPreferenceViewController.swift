//
//  ShortcutsPreferenceViewController.swift
//  Sudo.fm
//
//  Created by phucld on 6/11/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa
import Preferences
import MASShortcut

class ShortcutsPreferenceViewController: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.about
    let preferencePaneTitle = "Shortcuts"
    let toolbarItemIcon = NSImage(named: NSImage.infoName)!
    
    @IBOutlet weak var shortcutPlay: MASShortcutView!
    @IBOutlet weak var shortcutNextSong: MASShortcutView!
    @IBOutlet weak var shortcutPreviousSong: MASShortcutView!
    @IBOutlet weak var shortcutShufflePlaylist: MASShortcutView!
    
    override var nibName: NSNib.Name? { "ShortcutsPreferenceViewController" }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupShortcuts()
    }
    
    private func setupShortcuts() {
        shortcutPlay.associatedUserDefaultsKey = Shortcut.kTogglePlay
        shortcutNextSong.associatedUserDefaultsKey = Shortcut.kNextSong
        shortcutPreviousSong.associatedUserDefaultsKey = Shortcut.kPreviousSong
        shortcutShufflePlaylist.associatedUserDefaultsKey = Shortcut.kShufflePlaylist
    }
    
    @IBAction func restoreDefault(_ sender: Any) {
        let togglePlay = MASShortcut(keyCode: kVK_ANSI_Semicolon, modifierFlags: [.command, .shift])
        let playShortcut = NSKeyedArchiver.archivedData(withRootObject: togglePlay as Any)
        
        let nextSong = MASShortcut(keyCode: kVK_ANSI_L, modifierFlags: [.command, .shift])
        let nextSongShortcut = NSKeyedArchiver.archivedData(withRootObject: nextSong as Any)
        
        let previousSong = MASShortcut(keyCode: kVK_ANSI_H, modifierFlags: [.command, .shift])
        let previousSongShortcut = NSKeyedArchiver.archivedData(withRootObject: previousSong as Any)
        
        let shufflePlaylist = MASShortcut(keyCode: kVK_ANSI_J, modifierFlags: [.command, .shift])
        let shufflePlaylistShortcut = NSKeyedArchiver.archivedData(withRootObject: shufflePlaylist as Any)
        
        UserDefaults.standard.set(playShortcut, forKey: Shortcut.kTogglePlay)
        UserDefaults.standard.set(nextSongShortcut, forKey: Shortcut.kNextSong)
        UserDefaults.standard.set(previousSongShortcut, forKey: Shortcut.kPreviousSong)
        UserDefaults.standard.set(shufflePlaylistShortcut, forKey: Shortcut.kShufflePlaylist)
    }
    
}

