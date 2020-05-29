//
//  EmbededYoutubeViewController.swift
//  sudofm
//
//  Created by phucld on 6/3/20.
//  Copyright © 2020 Dwarves Foundation. All rights reserved.
//

import Cocoa
import WebKit

struct VideoInfo {
    let id: String
    let title: String
    let author: String
    let duration: TimeInterval
}

enum YouTubeState: Int {
    case unstarted = -1
    case ended
    case playing
    case paused
    case buffering
    case cued
}

protocol YoutubeDelegate: class {
    func youtube(_ youtube: EmbededYoutubeViewController, failedDownloadWithError error: Error)
    func youtube(_ youtube: EmbededYoutubeViewController, updateDownloadProgress progress: Float)
    func youtube(_ youtube: EmbededYoutubeViewController, changeState state: YouTubeState, for videoInfo: VideoInfo)
    func youtube(_ youtube: EmbededYoutubeViewController, updatedCurrentTime currentTime: TimeInterval)
}


// Provide a default implementation of protocol
// https://useyourloaf.com/blog/swift-optional-protocol-methods/
extension YoutubeDelegate {
    func youtube(_ youtube: EmbededYoutubeViewController, failedDownloadWithError error: Error) {}
    func youtube(_ youtube: EmbededYoutubeViewController, updateDownloadProgress progress: Float) {}
    func youtube(_ youtube: EmbededYoutubeViewController, changeState state: YouTubeState) {}
    func youtube(_ youtube: EmbededYoutubeViewController, updatedCurrentTime currentTime: TimeInterval) {}
    func youtube(_ youtube: EmbededYoutubeViewController, updatedDuration duration: TimeInterval) {}
}

// https://developers.google.com/youtube/iframe_api_reference
class EmbededYoutubeViewController: NSViewController {
    
    private var webView: WKWebView? = nil
    
    weak var delegate: YoutubeDelegate?
    
    private (set) var state: YouTubeState = .unstarted {
        didSet {
            self.delegate?.youtube(self, changeState: self.state)
        }
    }
    
    private let onPlayerReady = "onPlayerReady"
    private let onPlayerStateChange = "onPlayerStateChange"

    private var ids: [String] = []
    private var currentID = ""
    
    private var volume = LocalStorage.musicVolume
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWebView()
        
    }
    
    /// Plays the currently cued/loaded video. The final player state after this function executes will be playing (1).
    ///
    /// - Note: A playback only counts toward a video's official view count if it is initiated via a native play button in the player.
    func play() {
        if state != .playing {
            self.execute("player.playVideo();")
        }
    }
    
    /// Pauses the currently playing video.
    ///
    /// The final player state after this function executes will be paused (2) unless the player is in the ended (0) state when the function is called, in which case the player state will not change.
    func pause() {
        self.execute("player.pauseVideo();")
    }
    
    /// Stops and cancels loading of the current video.
    ///
    /// This function should be reserved for rare situations when you know that the user will not be watching additional video in the player. If your intent is to pause the video, you should just call the pauseVideo function. If you want to change the video that the player is playing, you can call one of the queueing functions without calling stopVideo first.
    /// - Important: Unlike the pauseVideo function, which leaves the player in the paused (2) state, the stopVideo function could put the player into any not-playing state, including ended (0), paused (2), video cued (5) or unstarted (-1).
    func stop() {
        self.execute("player.stopVideo();")
    }
    
    /// Seeks to a specified time in the video. If the player is paused when the function is called, it will remain paused. If the function is called from another state (playing, video cued, etc.), the player will play the video.
    ///
    /// - Parameter seconds: The seconds parameter identifies the time to which the player should advance.
    /// The player will advance to the closest keyframe before that time unless the player has already downloaded the portion of the video to which the user is seeking.
    func seek(to seconds: TimeInterval) {
        self.execute("player.seekTo(\(seconds))")
    }
    
    func loadVideo(by id: String) {
        self.execute("player.loadVideoById(\(id));")
    }
    
    func cueVideo(by id: String) {
        self.execute("player.cueVideoById(\(id));")
    }
    
    func loadPlaylist(by ids: [String]) {
        self.ids = ids
        self.execute("player.loadPlaylist(\(ids));")
    }
    
    func cuePlaylist(by ids: [String]) {
        self.ids = ids
        self.execute("player.cuePlaylist(\(ids));")
    }
    
    func nextVideo(handleLastSong: ((Bool) -> Void)) {
        // Last song
        if let lastID = ids.last, currentID == lastID {
            handleLastSong(true)
            return
        }
        
        self.execute("player.nextVideo();")
    }
    
    func previousVideo(handleFirstSong: ((Bool) -> Void)) {
        // First song
        if let firstID = ids.first, currentID == firstID {
            handleFirstSong(true)
            return
        }
        
        self.execute("player.previousVideo();")
    }
    
    func mute() {
        self.execute("player.mute();")
    }
    
    func unMute() {
        self.execute("player.unMute();")
    }
    
    func setVolume(to newVolume: Double) {
        self.volume = newVolume
        self.execute("player.setVolume(\(newVolume));")
    }
    
    func setLoop(isLoop: Bool) {
        self.execute("player.setLoop(\(isLoop));")
    }
    
    func setShuffle(isShuffle: Bool) {
        self.execute("player.setShuffle(\(isShuffle));")
    }
    
    private func execute(_ script: String) {
        DispatchQueue.main.async {
             self.webView?.evaluateJavaScript(script, completionHandler: nil)
        }
    }
}

// Private methods
extension EmbededYoutubeViewController {
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: onPlayerReady)
        config.userContentController.add(self, name: onPlayerStateChange)
        let webView = WKWebView(frame: .zero, configuration: config)
        
        self.webView = webView
        self.view.addChild(view: webView)

        if let url = Bundle.main.url(forResource: "youtube", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}


extension EmbededYoutubeViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == onPlayerReady {
            self.loadPlaylist(by: ids)
            self.setVolume(to: volume)
        }
        
        if message.name == onPlayerStateChange {
            guard
                let dict = message.body as? [String: AnyObject],
                let rawState = dict["state"] as? Int,
                let state = YouTubeState(rawValue: rawState),
                let videoData = dict["video"] as? [String: AnyObject],
                let id = videoData["id"] as? String,
                let title = videoData["title"] as? String,
                let author = videoData["author"] as? String,
                let duration = videoData["duration"] as? Double
                else {return}
            
            self.state = state
            self.currentID = id
            
            DispatchQueue.main.async {
                self.delegate?.youtube(self, changeState: state, for: VideoInfo(id: id, title: title, author: author, duration: duration))
            }
        }
    }
}
