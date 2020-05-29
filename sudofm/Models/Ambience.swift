//
//  Ambience.swift
//  sudofm
//
//  Created by phucld on 6/5/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation
import Lottie

struct AmbienceSound: Codable {
    let type: AmbienceType
    var volume: Float // 0 -> 1
    var isEnabled: Bool
    
    func getTitle() -> String {
        switch type {
        case .fire: return "Fire"
        case .night: return "Night"
        case .thunderStorm: return "Thunder Storm"
        case .coffeHouse: return "Coffee House"
        case .summerRain: return "Summer Rain"
        case .seaWaves: return "Sea Waves"
        }
    }
    
    func getAnimation() -> Animation? {
        switch type {
        case .fire: return Animation.named("Fire")
        case .night: return Animation.named("Night")
        case .thunderStorm: return Animation.named("ThunderStorm")
        case .coffeHouse: return Animation.named("CoffeeHouse")
        case .summerRain: return Animation.named("Rain")
        case .seaWaves: return Animation.named("Waves")
        }
    }
    
    func getSoundName() -> String {
        switch type {
        case .fire: return "Fire"
        case .night: return "Night"
        case .thunderStorm: return "ThunderStorm"
        case .coffeHouse: return "CoffeeHouse"
        case .summerRain: return "SummerRain"
        case .seaWaves: return "SeaWaves"
        }
    }
    
    func getIcon() -> NSImage {
        switch type {
        case .fire: return #imageLiteral(resourceName: "ico_work")
        case .night: return #imageLiteral(resourceName: "ico_chill")
        case .thunderStorm: return #imageLiteral(resourceName: "ico_bed")
        case .coffeHouse: return #imageLiteral(resourceName: "ico_coffee")
        case .summerRain: return #imageLiteral(resourceName: "ico_rain")
        case .seaWaves: return #imageLiteral(resourceName: "ico_wave")
        }
    }
}

enum AmbienceType: Int, CaseIterable, Codable {
    case fire
    case night
    case thunderStorm
    case coffeHouse
    case summerRain
    case seaWaves
}
