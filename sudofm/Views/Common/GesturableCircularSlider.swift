//
//  GesturableCircularSlider.swift
//  sudofm
//
//  Created by phucld on 6/5/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

class GesturableCircularSlider: NSSlider {
        
    var onScrollGesture: (() -> Void)?
    private var trackingArea: NSTrackingArea!
    
    override var doubleValue: Double {
        didSet {
            self.isEnabled = doubleValue != 0
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        self.isEnabled = doubleValue != 0
        self.minValue = 0
        self.maxValue = 100
        self.sliderType = .circular
        self.controlSize = .small
        self.translatesAutoresizingMaskIntoConstraints = false
        let trackingArea = NSTrackingArea(
            rect: self.frame,
            options: [.activeAlways, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        self.rotate(byDegrees: 180)
    }
    
    override func mouseDown(with event: NSEvent) {
        superview?.mouseDown(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        // Scroll down/left is down value
        // Scroll up/right is up value
        
        if event.scrollingDeltaX != 0 {
            self.doubleValue += Double(event.scrollingDeltaX) * 0.2
        }
        
        self.doubleValue -= Double(event.scrollingDeltaY) * 0.2
        
        onScrollGesture?()
    }
    
}
