//
//  CustomPopover.swift
//  sudofm
//
//  Created by phucld on 6/1/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

class CustomPopover: NSView {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {return true}
    
    override func viewDidMoveToWindow() {
        
        guard let frameView = window?.contentView?.superview else {
            return
        }
        
        let backgroundView = NSView(frame: frameView.bounds)
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.8549019608, blue: 0.8549019608, alpha: 1) // colour of your choice
        backgroundView.autoresizingMask = [.width, .height]
        
        frameView.addSubview(backgroundView, positioned: .below, relativeTo: frameView)
        
    }
}
