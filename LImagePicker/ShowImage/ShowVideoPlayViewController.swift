//
//  ShowVideoPlayViewController.swift
//  ImitationShaking
//
//  Created by less on 2019/8/28.
//  Copyright © 2019 study. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

fileprivate let MaxHiddenTime = 5

class ShowVideoPlayViewController: UIViewController, VideoTabBarViewDelegate {
    
    public var currentImage: UIImage?
    
    public var videoModel: LMediaResourcesModel?
    
    fileprivate var avAsset: AVAsset?
    
    fileprivate var player: AVPlayer?
    
    fileprivate var playerItem: AVPlayerItem?
    
    fileprivate var plyerLayer: AVPlayerLayer?
    
    fileprivate var timeObserver: Any?
    /** 视频总时长 */
    fileprivate var totalTime: Float64 = 0
    /** 计时 */
    fileprivate var timing: Int = 0
    
    fileprivate lazy var videoView: VideoPlayer = {
        let videoView = VideoPlayer(frame: self.view.bounds)
        videoView.backgroundColor = UIColor.black
        return videoView
    }()
    
    fileprivate lazy var coverImageView: UIImageView = {
        let image = UIImageView(frame: self.view.bounds)
        image.backgroundColor = UIColor.black
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    fileprivate lazy var cancleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 5, y: LConstant.statusHeight + 2, width: 40, height: 40))
        button.setImage(UIImage.imageNameFromBundle("icon_close"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    fileprivate lazy var playerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: LConstant.screenWidth/2 - 25, y: LConstant.screenHeight/2 - 25, width: 80, height: 80))
        button.setImage(UIImage.imageNameFromBundle("icon_video"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    fileprivate lazy var tabBarView: VideoTabBarView = {
        let barView: VideoTabBarView = VideoTabBarView(frame: CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        barView.delegate = self
        return barView
    }()
    
    deinit {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
        NotificationCenter.default.removeObserver(self)
        removeObserver()
        print("ShowVideoPlayViewController++++释放")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(videoView)
        view.addSubview(coverImageView)
        view.addSubview(cancleButton)
        view.addSubview(playerButton)
        view.addSubview(tabBarView)
        coverImageView.image = currentImage
        tabBarView.endLabel.text = changeTimeFormat(timeInterval: Double(videoModel?.videoTime ?? "0") ?? 0)
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
        playerButton.addTarget(self, action: #selector(playerButtonClick), for: .touchUpInside)
        requestAVAsset()
        addNotification()
        hiddenProgress()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureClick))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    fileprivate func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeDeath), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    fileprivate func addObserver() {
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil) // 播放状态
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil) // 缓存区间，可用来获取缓存了多少
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil) // 缓存不够了 自动暂停播放
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil) // 缓存好了 手动播放
    }
    
    fileprivate func removeObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
    }
    
    fileprivate func requestAVAsset() {
        guard let videoResoure = videoModel else { return }
        if let phAsset = videoResoure.dataProtocol as? PHAsset {
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: nil) { (asset, audio, dic) in
                 DispatchQueue.main.async {
                     self.avAsset = asset
                     guard let avAsset = self.avAsset else { return }
                     self.playerItem = AVPlayerItem(asset: avAsset)
                     self.videoPlay()
                 }
             }
        }else if let videoUrl = videoResoure.dataProtocol as? String, let url = URL(string: videoUrl) {
            let urlAsset = AVURLAsset(url: url)
            self.playerItem = AVPlayerItem(asset: urlAsset)
            
            self.videoPlay()
        }
    }
    
    fileprivate func videoPlay() {
        addObserver()
        player = AVPlayer(playerItem: playerItem)
        if let playerLayer = videoView.layer as? AVPlayerLayer {
            playerLayer.player = player
        }
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let `self` = self else { return }
            // 当前正在播放时间
            let loadTime = CMTimeGetSeconds(time)
            // 视频总时间
            if let duration = self.player?.currentItem?.duration {
                self.totalTime = CMTimeGetSeconds(duration)
            }
            self.tabBarView.progress(proportion: Float(loadTime/self.totalTime))
            self.tabBarView.startLabel.text = self.changeTimeFormat(timeInterval: loadTime)
            self.tabBarView.endLabel.text = self.changeTimeFormat(timeInterval: self.totalTime)
            self.timing += 1
            self.hiddenProgress()
        })
    }
    
    fileprivate func hiddenProgress() {
        if self.timing >= MaxHiddenTime && !cancleButton.isHidden {
            cancleButton.isHidden = true
            UIView.animate(withDuration: 0.5) {
                self.tabBarView.frame = CGRect(x: 0, y: LConstant.screenHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight)
            }
        }
    }
    
    // MARK:- Event
    @objc fileprivate func playToEndTime() {
        coverImageView.isHidden = false
        playerButton.isHidden = false
        tabBarView.startLabel.text = "00:00:00"
        tabBarView.progress(proportion: 0.0)
        tapGestureClick()
    }
    
    @objc fileprivate func becomeActive() {
        playerButton.isHidden = true
        player?.play()
    }
    
    @objc fileprivate func becomeDeath() {
        playerButton.isHidden = false
        player?.pause()
    }
    
    @objc fileprivate func tapGestureClick() {
        hiddenProgress()
        if cancleButton.isHidden {
            timing = 0
            cancleButton.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.tabBarView.frame = CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight)
            }
        }
    }
    
    @objc fileprivate func playerButtonClick() {
        seekProgress(progress: 0.0)
        player?.play()
    }
    
    @objc fileprivate func cancleButtonClick() {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK:- 操作
    // 静音
    fileprivate func muted() {
        player?.isMuted = false
    }
    
    // 音量
    fileprivate func volume() {
        player?.volume = 0.5
    }
    
    // 播放进度
    fileprivate func seekProgress(progress: CGFloat) {
        if let totalTime = player?.currentItem?.duration {
            timing = 0
            let totalSec = CMTimeGetSeconds(totalTime)
            let playTimeSec = totalSec * Float64(progress)
            let currentTime = CMTimeMake(value: Int64(playTimeSec), timescale: 1)
            player?.seek(to: currentTime) { (finished) in
                if finished {
                    self.playerButton.isHidden = true
                    self.coverImageView.isHidden = true
                }
            }
        }
    }
    
    // MARK:- VideoTabBarViewDelegate
    func videoTabBarView(_ view: VideoTabBarView, changeValue: Float) {
        seekProgress(progress: CGFloat(changeValue))
    }
    
    func videoTabBarViewBegin(_ view: VideoTabBarView) {
        player?.pause()
    }
    
    func videoTabBarViewEnd(_ view: VideoTabBarView) {
        player?.play()
    }
    
    
    // MARK:- observeValue
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            switch playerItem?.status {
            case .readyToPlay?:
                print("准备播放")
                player?.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   self.coverImageView.isHidden = true
                }
            case .failed?:
                print("播放失败")
            case .unknown?:
                print("unknown")
            case .none:
                print("no")
            @unknown default: break
                
            }
        }else if keyPath == "loadedTimeRanges" {
            let loadTimeArray = playerItem?.loadedTimeRanges
            // 获取最新缓存的区间
            let newTimeRange: CMTimeRange = loadTimeArray?.first as! CMTimeRange
            let startSeconds = CMTimeGetSeconds(newTimeRange.start)
            let durationSeconds = CMTimeGetSeconds(newTimeRange.duration)
            let totalBuffer = startSeconds + durationSeconds // 缓存总长度
            tabBarView.isUserEnabled = totalBuffer >= totalTime
        }else if keyPath == "playbackBufferEmpty" {
            print("正在缓存视频")
        }else if keyPath == "playbackLikelyToKeepUp" {
            print("缓存好了继续播放")
            player?.play()
        }
    }
    
    // 转时间格式化
    fileprivate func changeTimeFormat(timeInterval: TimeInterval) -> String {
        if timeInterval.isNaN { return "00:00:00" }
        return String(format: "%02d:%02d:%02d", Int(timeInterval) / 3600, (Int(timeInterval) % 3600) / 60, Int(timeInterval) % 60)
    }
}

class VideoPlayer: UIView {
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
}

// MARK:- AVplayer 通知
// 音频中断通知
// AVAudioSessionInterruptionNotification
// 音频线路改变（耳机插入、拔出）
// AVAudioSessionSilenceSecondaryAudioHintNotification
// 媒体服务器终止、重启
// AVAudioSessionMediaServicesWereLostNotification
// AVAudioSessionMediaServicesWereResetNotification
// 其他app的音频开始播放或者停止时
// AVAudioSessionSilenceSecondaryAudioHintNotification

// 播放结束
// AVPlayerItemDidPlayToEndTime
// 进行跳转
// AVPlayerItemTimeJumpedNotification
// 异常中断通知
// AVPlayerItemPlaybackStalledNotification
// 播放失败
// AVPlayerItemFailedToPlayToEndTimeNotification

protocol VideoTabBarViewDelegate: NSObjectProtocol {
    
    func videoTabBarViewBegin(_ view: VideoTabBarView)
    
    func videoTabBarView(_ view: VideoTabBarView, changeValue: Float)
    
    func videoTabBarViewEnd(_ view: VideoTabBarView)

}


class VideoTabBarView: UIView {
    
    public weak var delegate: VideoTabBarViewDelegate?
    
    public var isUserEnabled: Bool = true {
        didSet {
            progressView.isUserInteractionEnabled = isUserEnabled
        }
    }
    
    public lazy var startLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        label.frame = CGRect(x: 5, y: 0, width: label.intrinsicContentSize.width + 2, height: 49)
        return label
    }()
    
    public lazy var endLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "00:00:00"
        label.textColor = UIColor.white
        label.frame = CGRect(x: LConstant.screenWidth - 5 - label.intrinsicContentSize.width , y: 0, width: label.intrinsicContentSize.width, height: 49)
        return label
    }()
    
    
    fileprivate lazy var progressView: UISlider = {
        let sliderView = UISlider(frame: CGRect(x: self.startLabel.frame.maxX + 5, y: self.startLabel.l_height/2 - 6, width: LConstant.screenWidth - self.startLabel.l_width * 2 - 18, height: 12))
        sliderView.tintColor = UIColor.white
        sliderView.isContinuous = true
        sliderView.setThumbImage(UIImage.imageNameFromBundle("icon_slider"), for: .normal)
        return sliderView
    }()
    
    fileprivate lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.15)
        gradientLayer.colors = [UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2).cgColor, UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0).cgColor]
        gradientLayer.locations = [0, 1.0]
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        addSubview(startLabel)
        addSubview(endLabel)
        addSubview(progressView)
        progressView.addTarget(self, action: #selector(progressViewClick(_ :)), for: .valueChanged)
        progressView.addTarget(self, action: #selector(progressViewBeginClick(_ :)), for: .touchDown)
        progressView.addTarget(self, action: #selector(progressViewEndClick(_ :)), for: .touchUpInside)

    }
    
    public func progress(proportion: Float) {
        if proportion.isNaN { return }
        self.progressView.setValue(proportion, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Event
    @objc fileprivate func progressViewClick(_ sender: UISlider) {
        delegate?.videoTabBarView(self, changeValue: sender.value)
    }
    
    @objc fileprivate func progressViewBeginClick(_ sender: UISlider) {
        delegate?.videoTabBarViewBegin(self)
    }
    
    @objc fileprivate func progressViewEndClick(_ sender: UISlider) {
        delegate?.videoTabBarViewEnd(self)
    }
}

