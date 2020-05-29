//
//  Environment.swift
//  Sudo.fm
//
//  Created by phucld on 7/13/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation

public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let baseURL = "BASE_URL"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: - Plist values
    static let baseURL: String = {
        guard let url = Environment.infoDictionary[Keys.Plist.baseURL] as? String else {
            fatalError("Base URL not set in plist for this environment")
        }
        return url
    }()
}
