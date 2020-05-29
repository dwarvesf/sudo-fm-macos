//
//  Touchbar+Ext.swift
//  Sudo.fm
//
//  Created by phucld on 6/17/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import AppKit

extension NSTouchBarItem.Identifier {
    static let playButtonItem = NSTouchBarItem.Identifier("playButtonItem")
    static let nextButtonItem = NSTouchBarItem.Identifier("nextButtonItem")
    static let previousButtonItem = NSTouchBarItem.Identifier("previousButtonItem")
    static let shuffleButtonItem = NSTouchBarItem.Identifier("shuffleButtonitem")
}

extension NSTouchBar.CustomizationIdentifier {
    static let sudofm = NSTouchBar.CustomizationIdentifier("foundation.dwarves.sudofm")
}

