//
//  NSView+Ext.swift
//  sudofm
//
//  Created by phucld on 6/3/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

extension NSView {
    
    /// Set color for any NSView
    ///
    /// - Parameter color: The NSColor for the NSView
    func setFilterColor(_ color: NSColor) {
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor0")
        colorFilter.setValue(CIColor(cgColor: color.cgColor), forKey: "inputColor1")
        contentFilters = [colorFilter]
    }
    
    /// Set anchor point for any NSView
    ///
    /// - Parameter anchorPoint: The anchor point for the NSView
    func setAnchorPoint(anchorPoint: CGPoint) {
        if let layer = self.layer {
            var newPoint = NSPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
            var oldPoint = NSPoint(x: self.bounds.size.width * layer.anchorPoint.x, y: self.bounds.size.height * layer.anchorPoint.y)
            
            newPoint = newPoint.applying(layer.affineTransform())
            oldPoint = oldPoint.applying(layer.affineTransform())
            
            var position = layer.position
            
            position.x -= oldPoint.x
            position.x += newPoint.x
            
            position.y -= oldPoint.y
            position.y += newPoint.y
            
            
            layer.anchorPoint = anchorPoint
            layer.position = position
        }
    }
    
    /// Set clockwise spin animation  point for any NSView
    ///
    /// - Parameter timeToRotate: The less is the timeToRotate, the more fast the animation is !
    func spinClockwise(timeToRotate: Double) {
        startRotate(angle: CGFloat(-1 * .pi * 2.0), timeToRotate: timeToRotate)
    }
    
    /// Set anti clockwise spin animation  point for any NSView
    ///
    /// - Parameter timeToRotate: The less is the timeToRotate, the more fast the animation is !
    func spinAntiClockwise(timeToRotate: Double) {
        startRotate(angle: CGFloat(.pi * 2.0), timeToRotate: timeToRotate)
    }
    
    /// Stop all animations for the view
    ///
    func stopAnimations() {
        self.layer?.removeAllAnimations()
    }
    
    private func startRotate(angle: CGFloat, timeToRotate: Double) {
        self.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5))
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = angle
        rotateAnimation.duration = timeToRotate
        rotateAnimation.repeatCount = .infinity
        
        self.layer?.add(rotateAnimation, forKey: nil)
    }
    
    func addChild(view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
