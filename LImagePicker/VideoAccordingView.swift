//
//  VideoAccordingView.swift
//  LImagePicker
//
//  Created by L on 2021/7/26.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol VideoAccordingProtocol: AnyObject {
    
    func videoAccordingState(_ type: VideoAccordingType)
    
}

enum VideoAccordingType {
    /** 开始播放 */
    case play
    /** 播放失败 */
    case failed(String)
    /** 缓存进度 */
    case cache(Double)
    /** 正在缓存 */
    case cacheing
    /** 播放中 */
    case playing(Double, Double)
}


class VideoAccordingView: UIView {

    public weak var delegate: VideoAccordingProtocol?
    
    fileprivate var avAsset: AVAsset?
    
    fileprivate var player: AVPlayer?

    fileprivate var playerItem: AVPlayerItem?

    fileprivate var plyerLayer: AVPlayerLayer?

    fileprivate var timeObserver: Any?
    
    fileprivate lazy var videoView: VideoPlayer = {
        let videoView = VideoPlayer(frame: self.bounds)
        videoView.backgroundColor = UIColor.black
        return videoView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    deinit {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
        removePlayerItemObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        addSubview(videoView)
        addNotification()
    }
    
    public func requestAVAsset(media: PHAsset) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        let hud = ProgressHUDView(style: .darkBlur)
        hud.show(showView: self)
        PHImageManager.default().requestAVAsset(forVideo: media, options: options) { asset, audio, dic in
            DispatchQueue.main.async {
                self.avAsset = asset
                guard let avAsset = asset else { return }
                self.playerItem = AVPlayerItem(asset: avAsset)
                self.videoPlay()
                hud.hide()
            }
        }
    }
    
    public func requestUrlAsset(url: URL) {
        let urlAsset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: urlAsset)
        videoPlay()
    }
}


extension VideoAccordingView {
    
    fileprivate func addPlayerItemObserver() {
        // 播放状态
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        // 缓存区间, 可用来获取缓存了多少
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        // 缓存不够了，自动暂停播放
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        // 缓存好了，手动播放
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    fileprivate func removePlayerItemObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeDeath), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    fileprivate func videoPlay() {
        addPlayerItemObserver()
        player = AVPlayer(playerItem: playerItem)
        if let playerLayer = videoView.layer as? AVPlayerLayer {
            playerLayer.player = player
        }
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
            // 当前正在播放的时间
            let loadTime = time.seconds
            print(loadTime)
            // 视频总时长
            let duration = self?.player?.currentItem?.duration.seconds ?? 0
            self?.delegate?.videoAccordingState(.playing(loadTime, duration))
        })
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "status":
            switch self.playerItem?.status {
            case .readyToPlay:
                delegate?.videoAccordingState(.play)
                player?.play()
                print("准备播放")
            case .failed:
                delegate?.videoAccordingState(.failed("播放失败"))
                print("播放失败")
                break
            case .unknown:
                delegate?.videoAccordingState(.failed("unknown"))
                print("unknown")
                break
            case .none:
                delegate?.videoAccordingState(.failed("none"))
                print("none")
                break
            default:
                delegate?.videoAccordingState(.failed("未知错误"))
                break
            }
                        
        case "loadedTimeRanges":
            let loadTimeArray = playerItem?.loadedTimeRanges
            // 获取最新缓存的区间
            guard let newTimeRange = loadTimeArray?.first as? CMTimeRange else { return }
            // 缓存总长度
            let totalBuffer = newTimeRange.start.seconds + newTimeRange.duration.seconds
            print(totalBuffer)
            delegate?.videoAccordingState(.cache(totalBuffer))
        case "playbackBufferEmpty":
            print("正在缓存视频")
            delegate?.videoAccordingState(.cacheing)
        case "playbackLikelyToKeepUp":
            print("缓存好了继续播放")
            delegate?.videoAccordingState(.play)
            player?.play()
        default:
            break
        }
    }
    
}

@objc
extension VideoAccordingView {
    
    fileprivate func playToEndTime() {
        player?.seek(to: CMTimeMake(value: 1, timescale: 1), completionHandler: { finished in
            if finished {
                self.player?.play()
            }
        })
    }
    
    fileprivate func becomeActive() {
        player?.play()
    }
    
    fileprivate func becomeDeath() {
        player?.pause()
    }
    
}
