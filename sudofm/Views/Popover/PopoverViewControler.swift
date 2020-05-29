//
//  PopoverViewControler.swift
//  sudofm
//
//  Created by phucld on 5/31/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa
import AVKit
import Sparkle

class PopoverViewControler: NSViewController {
    
    @IBOutlet weak var imgView: MyAspectFillImageNSImageView!
    @IBOutlet weak var imgContainerView: NSView!
    
    @IBOutlet weak var rainView: NSView!
    @IBOutlet weak var fireView: NSView!
    @IBOutlet weak var nightView: NSView!
    
    @IBOutlet weak var codeView: NSView!
    @IBOutlet weak var chillView: NSView!
    @IBOutlet weak var sleepView: NSView!
    @IBOutlet weak var studyView: NSView!
    @IBOutlet weak var readView: NSView!
    @IBOutlet weak var sadView: NSView!
    
    @IBOutlet weak var viewControlBackground: NSView!
    @IBOutlet weak var viewSeparator: NSView!
    
    @IBOutlet weak var seekSlider: NSSlider! {
        didSet {
            seekSlider.setFilterColor(.systemPink)
        }
    }
    
    @IBOutlet weak var btnPlay: NSButton!
    
    @IBOutlet weak var lblCurrentTime: NSTextField!
    @IBOutlet weak var lblDuration: NSTextField!
    
    @IBOutlet weak var lblPlaylist: NSTextField!
    @IBOutlet weak var lblPlaylistAuthor: NSTextField!
    
    @IBOutlet weak var lblSong: NSTextField!
    @IBOutlet weak var lblSongAuthor: NSTextField!
    
    @IBOutlet weak var youtubeView: NSView!
    
    lazy private var moodViews: [NSView] = [
        codeView, chillView, sleepView, studyView, readView, sadView
    ]
    
    lazy private var ambienceViews: [NSView] = [
        rainView, fireView, nightView
    ]
    
    @IBOutlet weak var btnAmbienceGuide: HoverButton! {
        didSet {
            btnAmbienceGuide.onMouseEnter = {
                self.lblAmbienceGuide.isHidden = false
            }
            
            btnAmbienceGuide.onMouseExit = {
                self.lblAmbienceGuide.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var lblAmbienceGuide: NSTextField! {
        didSet {
            lblAmbienceGuide.isHidden = true
        }
    }
    
    private var selectedAmbiences: [AmbienceSound] = LocalStorage.selectedAmbiences
    
    private var ambienceVCs: [AmbienceSoundViewController] = []
    
    private var moodVCs: [MoodViewController] = []
    
    private var selectedMood: Mood = LocalStorage.selectedMood {
        didSet {
            switchMoodPlaylists()
        }
    }
    
    private var youtubeVC = EmbededYoutubeViewController()
    
    private var isSeeking = false
    
    private var moods: [MoodData] = []
    
    private var moodPlaylists: [Playlist] = [] {
        didSet {
            self.currentPlaylist = moodPlaylists.shuffled().first
        }
    }
    
    private var currentPlaylist: Playlist? = nil {
        didSet {
            DispatchQueue.main.async {
                self.loadPlaylist()
            }
        }
    }
    
    var seekTimer: Timer?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMoods()
        observeNotification()
    }
    
    private func observeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateMusicVolume(notification:)), name: NSNotification.Name(rawValue: "musicVolumeDidChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMoodData(notification:)), name: NSNotification.Name(rawValue: "moodsDataDidChange"), object: nil)
    }
    
    @objc
    private func updateMusicVolume(notification: Notification) {
        guard let slider = notification.object as? NSSlider else {return}
        youtubeVC.setVolume(to: slider.doubleValue)
        
        if slider.doubleValue == 0 {
            youtubeVC.pause()
            return
        }
        
        youtubeVC.play()
    }
    
    @objc
    private func updateMoodData(notification: Notification) {
        self.moods = LocalStorage.mooods
    }
    
    private func reloadData() {
        guard
            selectedMood.rawValue < moods.count,
            youtubeVC.state != .playing
            else {return}
        
        moodPlaylists = moods[selectedMood.rawValue].playlists
    }
    
    private func switchMoodPlaylists() {
        guard selectedMood.rawValue < moods.count else {return}
        
        moodPlaylists = moods[selectedMood.rawValue].playlists
    }
    
    private func loadPlaylist() {
        guard let playlist = currentPlaylist else {return}
        
        lblPlaylist.stringValue = playlist.name
        lblPlaylistAuthor.stringValue = playlist.credit ?? ""
        
        DispatchQueue.main.async {
            self.youtubeVC.loadPlaylist(by: playlist.songs.filter { $0.source == "youtube" }.map { $0.youtubeID }.shuffled())
        }
    }
    
    private func fetchMoods() {
        guard LocalStorage.mooods.isEmpty else {
            self.moods = LocalStorage.mooods
            reloadData()
            return
        }
        
        NetworkManager.shared.getMoods { result in
            switch result {
            case .success(let moods):
                guard !moods.isEmpty else {return}
                
                let code = moods.first { $0.id == 6 }
                let chill = moods.first { $0.id == 3 }
                let sleep = moods.first { $0.id == 4}
                
                let filteredMoods = [code, chill, sleep].compactMap { $0 }
                
                LocalStorage.mooods = filteredMoods
                
                self.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    private func setupViews() {
        btnPlay.isEnabled = false
        
        imgContainerView.wantsLayer = true
        imgContainerView.layer?.cornerRadius = 5
        
        imgView.image = #imageLiteral(resourceName: "img_placeholder")
        
        selectedAmbiences.enumerated().forEach { (idx, ambience) in
            let vc = AmbienceSoundViewController(
                name: ambience.getTitle(),
                soundName: ambience.getSoundName(),
                animation: ambience.getAnimation(),
                icon: ambience.getIcon(),
                volume: ambience.volume,
                isPlaying: ambience.isEnabled
            )
            
            vc.playingDidChange = { isPlaying in
                var updatedAmbience = LocalStorage.selectedAmbiences[idx]
                updatedAmbience.isEnabled = isPlaying
                LocalStorage.selectedAmbiences[idx] = updatedAmbience
            }
            
            vc.volumeDidChange = { newVolume in
                var updatedAmbience = LocalStorage.selectedAmbiences[idx]
                updatedAmbience.volume = newVolume
                LocalStorage.selectedAmbiences[idx] = updatedAmbience
            }
            
            ambienceVCs.append(vc)
            
            ambienceViews[idx].addChild(view: vc.view)
        }
        
        Mood.allCases.enumerated().forEach { (idx, mood) in
            let vc = MoodViewController(name: mood.getTitle(), ico: mood.getIcon(), isSelected: selectedMood == mood)
            vc.onSelected = { [weak self] in
                guard let self = self else {return}
                self.moodVCs[self.selectedMood.rawValue].unselect()
                self.selectedMood = mood
            }
            moodVCs.append(vc)
            moodViews[idx].addChild(view: vc.view)
        }
        
        // Disable all moods except the Coding
        moodVCs.dropFirst(3).forEach { $0.isEnabled = false }
        
        youtubeView.addChild(view: youtubeVC.view)
        youtubeVC.delegate = self
        
        viewControlBackground.wantsLayer = true
        viewControlBackground.layer?.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)
        
        viewSeparator.wantsLayer = true
        viewSeparator.layer?.backgroundColor = #colorLiteral(red: 0.8274509804, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
        
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
            self.keyUp(with: $0)
            return $0
        }
    }
    
    private func startAnimation() {
        imgView.spinClockwise(timeToRotate: 5)
    }
    
    private func stopAnimation() {
        imgView.stopAnimations()
    }
    
    @IBAction func openMenu(_ sender: NSButton) {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "Check for Updates...", action: #selector(SUUpdater.checkForUpdates(_:)), keyEquivalent: "u").target = SUUpdater.shared()
        menu.addItem(withTitle: "Preferences", action: #selector(showPreferences), keyEquivalent: ",").target = self
        menu.addItem(withTitle: "Quit", action: #selector(quitApplication), keyEquivalent: "q").target = self
        
        menu.popUp(positioning: nil, at: .init(x: 0, y: 26), in: sender)
    }
    
    @objc
    private func showPreferences() {
        AppDelegate.shared.preferencesWindowController.show()
    }
    
    @objc
    private func quitApplication() {
        NSApp.terminate(self)
    }
    
    @IBAction func openSharingMenu(_ sender: NSButton) {
        let url = URL(string: "http://sudo.fm/")!
        let sharingPicker = NSSharingServicePicker(items: [url])
        
        sharingPicker.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
    }
    
    @IBAction func backwardSong(_ sender: Any) {
        youtubeVC.previousVideo { [weak self] isFirstSong in
            guard let self = self, isFirstSong else { return }
            self.handleBackwardFirstSong()
        }
    }
    
    @IBAction func forwardSong(_ sender: Any) {
        youtubeVC.nextVideo { [weak self] isLastSong in
            guard let self = self, isLastSong else { return }
            self.handleForwardLastSong()
        }
    }
    
    @IBAction func shufflePlaylist(_ sender: Any) {
        guard selectedMood.rawValue < moods.count else {return}
        
        moodPlaylists = moods[selectedMood.rawValue].playlists.shuffled()
    }
    
    @IBAction func toggleMusic(_ sender: Any) {
        if youtubeVC.state == .playing {
            youtubeVC.pause()
        } else {
            youtubeVC.play()
        }
    }
    
    @IBAction func seekSliderValueChanged(_ sender: NSSlider) {
        let currentTime = TimeInterval(seekSlider.doubleValue)
        lblCurrentTime.stringValue = currentTime.toMMSS()
        
        isSeeking = true
        seekTimer?.invalidate()
        seekTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(seek),
            userInfo: nil,
            repeats: false)
    }
    
    @objc
    private func seek() {
        let time = TimeInterval(seekSlider.doubleValue)
        youtubeVC.seek(to: time)
        
        isSeeking = false
    }
    
    private func handleForwardLastSong() {
        if
            let currentPlaylist = currentPlaylist,
            let currentPlaylistIdx = moodPlaylists.firstIndex(where: { $0.id == currentPlaylist.id }) {
            
            if currentPlaylistIdx == moodPlaylists.endIndex - 1 {
                self.currentPlaylist = moodPlaylists.first
            } else if currentPlaylistIdx < moodPlaylists.endIndex - 1 {
                self.currentPlaylist = moodPlaylists[currentPlaylistIdx + 1]
            }
        }
    }
    
    private func handleBackwardFirstSong() {
        if
            let currentPlaylist = currentPlaylist,
            let currentPlaylistIdx = moodPlaylists.firstIndex(where: { $0.id == currentPlaylist.id }) {
            
            if currentPlaylistIdx == moodPlaylists.startIndex {
                self.currentPlaylist = moodPlaylists.last
            } else if currentPlaylistIdx > moodPlaylists.startIndex {
                self.currentPlaylist = moodPlaylists[currentPlaylistIdx - 1]
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        // Space
        case 49: toggleMusic(self)
            
        // ←
        case 123: backwardSong(self)
            
        // →
        case 124: forwardSong(self)
            
        default: break
        }
    }
    
}

extension PopoverViewControler: YoutubeDelegate {
    func youtube(_ youtube: EmbededYoutubeViewController, changeState state: YouTubeState, for videoInfo: VideoInfo) {
        self.touchBar = nil
        
        switch state {
        case .unstarted:
            btnPlay.isEnabled = false
            seekSlider.maxValue = videoInfo.duration
            lblDuration.stringValue = videoInfo.duration.toMMSS()
            lblSong.stringValue = videoInfo.title
            lblSongAuthor.stringValue = videoInfo.author
            if let url = URL(string: "https://img.youtube.com/vi/\(videoInfo.id)/sddefault.jpg") {
                imgView.image = NSImage(contentsOf: url)
            }
            
        case .buffering: break
        case .cued: break
        case .playing:
            btnPlay.isEnabled = true
            btnPlay.image = #imageLiteral(resourceName: "ico_pause")
        case .paused:
            btnPlay.image = #imageLiteral(resourceName: "ico_play")
        case .ended:
            if
                let currentPlaylist = currentPlaylist,
                let lastSong = currentPlaylist.songs.last,
                videoInfo.id == lastSong.ytId,
                let currentPlaylistIdx = moodPlaylists.firstIndex(where: { $0.id == currentPlaylist.id }) {
                
                // Handle when play to the last song of playlist
                
                if currentPlaylistIdx < moodPlaylists.endIndex - 1 {
                    self.currentPlaylist = moodPlaylists[currentPlaylistIdx + 1]
                } else {
                    self.currentPlaylist = moodPlaylists[0]
                }
                
                return
            }
            btnPlay.image = #imageLiteral(resourceName: "ico_play")
        }
    }
}

extension PopoverViewControler: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .sudofm
        touchBar.defaultItemIdentifiers = [
            .previousButtonItem,
            .playButtonItem,
            .nextButtonItem,
            .shuffleButtonItem
        ]
        return touchBar
    }
    
    func touchBar(
        _ touchBar: NSTouchBar,
        makeItemForIdentifier identifier: NSTouchBarItem.Identifier
    ) -> NSTouchBarItem? {
        
        switch identifier {
        case .playButtonItem:
             
            let btnPlay = NSButton(title: "", target: self, action: #selector(toggleMusic(_:)))
            let imageName = youtubeVC.state == .playing ? NSImage.touchBarPauseTemplateName : NSImage.touchBarPlayTemplateName
            btnPlay.image = NSImage(named: imageName)

          
            let touchBarButton = NSCustomTouchBarItem(identifier: identifier)
            touchBarButton.view = btnPlay
            return touchBarButton
        case .previousButtonItem:
            
            let btnPrevious = NSButton(title: "", target: self, action: #selector(backwardSong(_:)))
            btnPrevious.image = NSImage(named: NSImage.touchBarRewindTemplateName)
            
            let touchBarButton = NSCustomTouchBarItem(identifier: identifier)
            touchBarButton.view = btnPrevious
            return touchBarButton
            
        case .nextButtonItem:
            
            let btnNext = NSButton(title: "", target: self, action: #selector(forwardSong(_:)))
            btnNext.image = NSImage(named: NSImage.touchBarFastForwardTemplateName)
            
            let touchBarButton = NSCustomTouchBarItem(identifier: identifier)
            touchBarButton.view = btnNext
            return touchBarButton
            
        case .shuffleButtonItem:
            
            let btnShuffle = NSButton(title: "", target: self, action: #selector(shufflePlaylist(_:)))
            let image = #imageLiteral(resourceName: "ico_shuffle_touchbar").tint(color: .white)
            btnShuffle.image = image
            let touchBarButton = NSCustomTouchBarItem(identifier: identifier)
            touchBarButton.view = btnShuffle
            return touchBarButton
            
        default:
            return nil
        }
    }
}
