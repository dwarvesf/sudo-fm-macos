//
//  AmbienceSoundViewController.swift
//  sudofm
//
//  Created by phucld on 6/1/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa
import AVFoundation
import Lottie

class AmbienceSoundViewController: NSViewController {

    @IBOutlet weak var animationViewSound: AnimationView!
    @IBOutlet weak var btnAction: NSButton!
    @IBOutlet weak var lblVolumn: NSTextField!
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var imgViewIcon: NSImageView!
    
    var volumeDidChange: ((Float) -> Void)?
    var playingDidChange: ((Bool) -> Void)?
    
    private var isPlaying = false {
        didSet {
            togglePlaying()
            playingDidChange?(isPlaying)
        }
    }
    
    private var volumn: Float = 0.5 {
        didSet {
            volumnDidChange()
            volumeDidChange?(volumn)
        }
    }
    
    private let name: String
    private let soundName: String
    private let icon: NSImage
    private let animation: Animation?
    
    private var player: AVAudioPlayer?
    
    init(name: String, soundName: String, animation: Animation?, icon: NSImage, volume: Float = 0.5, isPlaying: Bool = false) {
        self.name = name
        self.soundName = soundName
        self.icon = icon
        self.animation = animation
        self.isPlaying = isPlaying
        self.volumn = volume
        super.init(nibName: "AmbienceSoundViewController", bundle: Bundle.main)
    }
    
    @IBAction func toggleSound(_ sender: Any) {
        isPlaying.toggle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let animation = self.animation {
            imgViewIcon.isHidden = true
            animationViewSound.animation = animation
            animationViewSound.contentMode = .scaleAspectFit
            animationViewSound.loopMode = .loop
        } else {
            animationViewSound.isHidden = true
            imgViewIcon.image = icon
        }
        
        lblTitle.stringValue = name
            
        self.setupPlayer()
        
        btnAction.addCursorRect(btnAction.bounds, cursor: .pointingHand)
        lblVolumn.stringValue = "\(Int(volumn * 100))%"
        
        self.view.addTrackingArea(NSTrackingArea(rect: self.view.bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil))
        
        self.togglePlaying()
    }
    
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: self.soundName, withExtension: "mp3") else { return }
        
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = volumn
        player?.prepareToPlay()
    }
    
    private func togglePlaying() {

        if isPlaying {
            let color = #colorLiteral(red: 0.2196078431, green: 0.5921568627, blue: 0.9960784314, alpha: 1)
            animationViewSound.setFilterColor(color)
            imgViewIcon.image = self.icon.tint(color: color)
            
            animationViewSound.play(toFrame: 100)
            player?.play()
        } else {
            let color = #colorLiteral(red: 0.2509519458, green: 0.251000315, blue: 0.2509455681, alpha: 1)
            animationViewSound.setFilterColor(color)
            imgViewIcon.image = self.icon.tint(color: color)
            
            animationViewSound.pause()
            player?.pause()
        }
    }
    
    private func volumnDidChange() {
        if volumn > 1 {volumn = 1}
        if volumn < 0 {volumn = 0}
        player?.volume = volumn
        isPlaying = volumn != 0
        lblVolumn.stringValue = "\(Int(volumn * 100))%"
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseExited(with: event)
//        lblVolumn.textColor = NSColor.systemOrange
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
//        lblVolumn.textColor = isPlaying ? .systemPink : .gray
    }
    
    override func scrollWheel(with event: NSEvent) {
        if event.scrollingDeltaX != 0 {
            self.volumn += Float(event.scrollingDeltaX) * 0.001
        }
        
        self.volumn -= Float(event.scrollingDeltaY) * 0.001
    }

}

class CustomButton: NSButton {
    
    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: .pointingHand)
    }
}
