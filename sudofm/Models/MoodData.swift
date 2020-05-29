//
//  MoodData.swift
//  sudofm
//
//  Created by phucld on 6/3/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation

struct MoodData: Codable {
    let id: Int
    let name: String
    let playlists: [Playlist]
}
