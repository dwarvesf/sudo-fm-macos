//
//  Song.swift
//  sudofm
//
//  Created by phucld on 6/3/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation

struct Song: Codable {
    let id: Int
    let name: String
    let ytId: String
    let source: String
    
    var youtubeID: String {
        return String(ytId.split(separator: "=").last ?? "")
    }
    
    var thumbnail: String { "https://img.youtube.com/vi/\(youtubeID)/sddefault.jpg" }
}
