//
//  LImageCameraViewController.swift
//  LImageCamera
//
//  Created by L j on 2020/7/6.
//  Copyright © 2020 L. All rights reserved.
//

enum LCameraError: String {
    case noCamerasAvailable
}

import UIKit
import AVFoundation
import LPublicImageParameter
import Photos

public protocol LImageCameraViewDelegate: class {
    
    func imageCameraViewSuccess(viewController: LImageCameraViewController)
    
}

public class LImageCameraViewController: UIViewController {

    public var isSave: Bool = false
    
    public var delegate: LImageCameraViewDelegate?
    
    // 视频
    fileprivate lazy var videoView: LImageCameraView = {
        let videoView = LImageCameraView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight))
        videoView.delegate = self
        videoView.setUpSession()
        videoView.maxDuration = 15
        return videoView
    }()
    
    // 操作
    fileprivate lazy var operationView: LImageCameraOperationView = {
        let view = LImageCameraOperationView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight))
        view.backgroundColor = UIColor(white: 1, alpha: 0)
        view.delegate = self
        return view
    }()
    
    // tabbar
    fileprivate lazy var tabBarView: LImageCameraTabBarView = {
        let view = LImageCameraTabBarView(frame: CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        return view
    }()
    
    // 视频播放
    fileprivate lazy var playerView: LImageCameraPlayerView = {
        let playerView = LImageCameraPlayerView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight))
        playerView.isLoopPlay = true
        return playerView
    }()
    

    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        initView()
    }
    
    
    // MARK: - initView
    fileprivate func initView() {
        view.addSubview(videoView)
        view.addSubview(operationView)
        view.addSubview(tabBarView)
        tabBarView.isHidden = true
        videoView.captureSession.startRunning()
    }

    // MARK: - fileprivate
    fileprivate func imageCameraCompleteShooting() {
        operationView.shootingComplete()
        tabBarView.isHidden = false
    }
    
    deinit {
        print("LImageCameraViewController +++ 释放")
    }
}

extension LImageCameraViewController: LImageCameraDelegate, LImageCameraOperationDelegate {
    
    func imageCameraCaptureDeviceDidChange() {
        print("有变化")
    }
    
    func imageCameraDidStartRecording(filePath: String) {
        print("开始录制 +++++  \(filePath)")
    }
    
    func imageCameraDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval) {
        print("录制中 +++++  \(currentDuration)")
        operationView.shootingAnimate(CGFloat(currentDuration/15.0))
    }
    
    func imageCameraDidFinishRecording(filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool) {
        imageCameraCompleteShooting()
        videoView.captureSession.stopRunning()
        
        if !view.subviews.contains(playerView) {
            view.insertSubview(playerView, at: 1)
            playerView.play(url: filePathUrl)
        }
        
        if isSave {
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePathUrl)
//            }, completionHandler: nil)
        }
    }
    
    func imageCameraDidPhoto(image: UIImage) {
        // 拍摄照片
        imageCameraCompleteShooting()
    }
    
    
    func operationViewDidSelect(buttonType: LImageCameraOperationType) {
        switch buttonType {
        case .shooting:
            let videoNameStr = App.cocumentsPath + "/\(Date().milliStamp).mp4"
            videoView.startRecordVideo(filePath: videoNameStr)
        case .suspended:
            videoView.stopVideoRecoding()
        case .taking:
            videoView.startRecordPhoto()
        case .remake:
            videoView.captureSession.startRunning()
            tabBarView.isHidden = true
            playerView.removeView()
        }
    }
    
    func operationViewPlayStatus() -> Bool {
        return videoView.isRecording
    }
    
    
}
