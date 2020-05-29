//
//  MyAspectFillImageNSImageView.swift
//  sudofm
//
//  Created by phucld on 6/3/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

open class MyAspectFillImageNSImageView : NSImageView {
    
    open override var image: NSImage? {
        set {
            self.layer = CALayer()
            self.layer?.contentsGravity = .resizeAspectFill
            self.layer?.contents = newValue
            self.wantsLayer = true
            
            super.image = newValue
        }
        
        get {
            return super.image
        }
    }
}
