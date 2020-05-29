//
//  HoverButton.swift
//  Sudo.fm
//
//  Created by phucld on 6/15/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

class HoverButton: NSButton {
    var onMouseEnter: (()->Void)?
    var onMouseExit: (()->Void)?
    
    var trackingArea: NSTrackingArea?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        if let area = trackingArea {
            self.addTrackingArea(area)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        if let area = trackingArea {
            self.addTrackingArea(area)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        onMouseEnter?()
        self.isEnabled = true
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        onMouseExit?()
        self.isEnabled = false
    }
}
