//
//  TimeInterval+Ext.swift
//  sudofm
//
//  Created by phucld on 6/4/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    /// Converts a `TimeInterval` into a MM:SS formatted string.
    ///
    /// - Returns: A `String` representing the MM:SS formatted representation of the time interval.
    public func toMMSS() -> String {
        let ts = Int(self)
        let s = ts % 60
        let m = (ts / 60) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
}
