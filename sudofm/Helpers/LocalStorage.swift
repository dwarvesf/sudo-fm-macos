//
//  LocalStorage.swift
//  sudofm
//
//  Created by phucld on 6/4/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation


enum Shortcut {
    static let kTogglePlay = "kTogglePlay"
    static let kNextSong = "kNextSong"
    static let kPreviousSong = "kPreviousSong"
    static let kShufflePlaylist = "kShufflePlaylist"
}

extension UserDefaults {
    enum Key {
        static let startAtLogin = "startAtLogin"
        static let showPreferencesOnLaunch = "showPreferencesOnLaunch"
        static let moods = "moods"
        static let musicVolume = "musicVolume"
        static let selectedMood = "selectedMood"
        static let selectedAmbiences = "selectedAmbiences"
    }
}

enum LocalStorage {
    static var startAtLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.Key.startAtLogin)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.startAtLogin)
            LauncherManager.shared.setupMainApp(isAutoStart: newValue)
        }
    }
    
    static var showPreferencesOnlaunch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.Key.showPreferencesOnLaunch)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.showPreferencesOnLaunch)
        }
    }
    
    static var mooods: [MoodData] {
        get {
            guard let data = UserDefaults.standard.value(forKey: UserDefaults.Key.moods) as? Data else { return [] }
            return (try? JSONDecoder().decode([MoodData].self, from: data)) ?? []
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: UserDefaults.Key.moods)
            NotificationCenter.default.post(name: NSNotification.Name("moodsDataDidChange"), object: self, userInfo: nil)
        }
    }
    
    static var musicVolume: Double {
        get {
            return UserDefaults.standard.double(forKey: UserDefaults.Key.musicVolume)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.musicVolume)
        }
    }
    
    static var selectedMood: Mood {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: UserDefaults.Key.selectedMood)
            return Mood(rawValue: rawValue) ?? .code
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.Key.selectedMood)
        }
    }
    
    static var selectedAmbiences: [AmbienceSound] {
        get {
            guard let data = UserDefaults.standard.value(forKey: UserDefaults.Key.selectedAmbiences) as? Data else { return [] }
            return (try? JSONDecoder().decode([AmbienceSound].self, from: data)) ?? []
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(data, forKey: UserDefaults.Key.selectedAmbiences)
        }
    }
}
