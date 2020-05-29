//
//  MoodViewController.swift
//  sudofm
//
//  Created by phucld on 6/4/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa

class MoodViewController: NSViewController {
    
    @IBOutlet weak var viewOverlay: NSView!
    @IBOutlet weak var imgViewOverlay: NSImageView!
    @IBOutlet weak var imgViewMoodIco: NSImageView!
    @IBOutlet weak var lblMoodName: NSTextField!
    @IBOutlet weak var btnToggleMood: NSButton!
    
    private var isSelected = false {
        didSet {
            self.onStateChanged()
        }
    }
    
    var onSelected: (() -> Void)?
    
    private let name: String
    private let ico: NSImage
    
    
    private var onHover = false {
        didSet {
            self.onViewHover()
        }
    }
    
    var isEnabled = true {
        didSet {
            self.onViewEnable()
        }
    }
    
    
    init(name: String, ico: NSImage, isSelected: Bool = false) {
        self.name = name
        self.ico = ico
        self.isSelected = isSelected
        super.init(nibName: "MoodViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    private func setupView() {
        self.view.wantsLayer = true
        self.view.layer?.cornerRadius = 8
        self.view.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.35).cgColor
        
        self.viewOverlay.isHidden = true
        self.viewOverlay.wantsLayer = true
        self.viewOverlay.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.35).cgColor
        self.imgViewOverlay.image =
            #imageLiteral(resourceName: "ico_play_mood")
        self.imgViewMoodIco.image = self.ico
        self.lblMoodName.stringValue = self.name
        
        self.onStateChanged()
        
        self.view.addTrackingArea(NSTrackingArea(rect: self.view.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil))
    }
    
    private func onViewHover() {
        guard isEnabled else {return}
        self.viewOverlay.isHidden = !onHover
    }
    
    private func onViewEnable() {
        btnToggleMood.isEnabled = isEnabled
        let backgroundColor: CGColor = isEnabled ? NSColor.white.withAlphaComponent(0.35).cgColor : NSColor.black.withAlphaComponent(0.35).cgColor
        
        self.view.layer?.backgroundColor = backgroundColor

        
    }
    
    private func onStateChanged() {
        switch self.isSelected {
        case true:
            imgViewOverlay.image = #imageLiteral(resourceName: "ico_pause_mood")
            let color = #colorLiteral(red: 0.2196078431, green: 0.5921568627, blue: 0.9960784314, alpha: 1)
            imgViewMoodIco.image = self.ico.tint(color: color)
            lblMoodName.textColor = color
        case false:
            imgViewOverlay.image = #imageLiteral(resourceName: "ico_play_mood")
            let color = #colorLiteral(red: 0.2509519458, green: 0.251000315, blue: 0.2509455681, alpha: 1)
            imgViewMoodIco.image = self.ico.tint(color: color)
            lblMoodName.textColor = color
        }
    }
    
    @IBAction func selectMood(_ sender: Any) {
        guard !isSelected else {return}
        
        isSelected = true
        onSelected?()
    }
    
    func select() {
        isSelected = true
    }
    
    func unselect() {
        isSelected = false
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseExited(with: event)
        self.onHover = true
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.onHover = false
    }
}


extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}
