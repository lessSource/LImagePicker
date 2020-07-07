//
//  LImageCameraPlayerView.swift
//  LImageCamera
//
//  Created by L j on 2020/7/7.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVKit

class LImageCameraPlayerView: UIView {
    
    // 是否循环播放
    public var isLoopPlay: Bool = false
    
    fileprivate var avplayer: AVPlayer!
    // 显示视频
    private var videoView: VideoPlayer!
    private var playerItem: AVPlayerItem!
    
    // 视频总时长
    var totalTimeFormat: String {
        if let totalTime = self.avplayer.currentItem?.duration {
            let totalTimeSec = CMTimeGetSeconds(totalTime)
            if totalTimeSec.isNaN {
                return "00:00"
            }
            return String(format: "%02zd:%02zd", Int(totalTimeSec / 60), Int(totalTimeSec.truncatingRemainder(dividingBy: 60.0)))
        }
        return "00:00"
    }
    
    // 视频播放时长
    var currentTimeFormat: String {
        if let playTime = self.avplayer.currentItem?.currentTime() {
            let playTimeSec = CMTimeGetSeconds(playTime)
            if playTimeSec.isNaN {
                return "00:00"
            }
            return String(format: "%02zd:%02zd", Int(playTimeSec / 60), Int(playTimeSec.truncatingRemainder(dividingBy: 60.0)))
        }
        return "00:00"
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        videoView = VideoPlayer(frame: bounds)
        addSubview(videoView)
    }
    
    func play(url: URL) {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        // 监听它状态的改变，实现kvo的方法
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.avplayer = AVPlayer(playerItem: playerItem)
        if let playerLayer = videoView.layer as? AVPlayerLayer {
            playerLayer.player = avplayer
        }
        
        // 播放结束的通知
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let palyerItem = object as? AVPlayerItem else { return }
        if keyPath == "status" {
            // 资源准备好，可以播放
            if palyerItem.status == .readyToPlay {
                self.avplayer.play()
            }else {
                print("load error")
            }
        }
        
    }
    
    // 暂停
    func pause() {
        avplayer.pause()
    }
    
    // 继续
    func resume() {
        avplayer.play()
    }
    
    public func dddddd() {
        avplayer.pause()
        avplayer = nil
//        avplayer.removel
        videoView.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    // 播放进度
    func progress(_ sender: UISlider) {
        let progress: Float64 = Float64(sender.value)
        if progress < 0 || progress > 1 {
            return
        }
        
        if let totalTime = avplayer.currentItem?.duration {
            let totalSec = CMTimeGetSeconds(totalTime)
            let platTimeSec = totalSec * progress
            let currentTime = CMTimeMake(value: Int64(platTimeSec), timescale: 1)
            self.avplayer.seek(to: currentTime) { (finished) in
            }
        }
        
    }
    
    // 几倍数
    func rate(_ multiple: Float) {
        avplayer.rate = multiple
    }
    
    // 静音
    func muted() {
        avplayer.isMuted = false
    }
    
    // 音量
    func volume(_ sender: UISlider) {
        if sender.value < 0 || sender.value > 1 {
            return
        }
        if sender.value > 0 {
            avplayer.isMuted = false
        }
        avplayer.volume = sender.value
    }
    
    // 播放完成
    @objc fileprivate func playToEndTime() {
        if isLoopPlay {
            avplayer.seek(to: CMTimeMake(value: 0, timescale: 1)) { (success) in
                self.avplayer.play()
            }
        }
    }
    
    deinit {
        playerItem.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
        print("LImageCameraPlayerView ++++  释放")
    }

}


class VideoPlayer: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
}
