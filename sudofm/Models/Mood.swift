//
//  Mood.swift
//  sudofm
//
//  Created by phucld on 6/5/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

enum Mood: Int, CaseIterable {
    case code
    case chill
    case sleep
    case study
    case read
    case sad
    
    func getID() -> Int {
        self.rawValue + 1
    }
    
    func getTitle() -> String {
        switch self {
        case .code: return "Code"
        case .chill: return "Chill"
        case .sleep: return "Sleep"
        case .study: return "Study"
        case .read: return "Read"
        case .sad: return "Sad"
        }
    }
    
    func getIcon() -> NSImage {
        switch self {
        case .code: return #imageLiteral(resourceName: "ico_work")
        case .chill: return #imageLiteral(resourceName: "ico_chill")
        case .sleep: return #imageLiteral(resourceName: "ico_bed")
        case .study: return #imageLiteral(resourceName: "ico_study")
        case .read: return #imageLiteral(resourceName: "ico_read")
        case .sad: return #imageLiteral(resourceName: "ico_sad")
        }
    }
}
