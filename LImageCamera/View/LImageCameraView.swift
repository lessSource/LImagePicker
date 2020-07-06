//
//  LImageCameraView.swift
//  LImageCamera
//
//  Created by L j on 2020/7/6.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation

protocol ImageCameraDelegate: class {

    /** 当AVCaptureDevice实例检测到视频主要区域有实质性变化时 */
    func imageCameraCaptureDeviceDidChange()
    
    /** 视频录制结束 */
    func imageCameraDidFinishRecording(_ sussess: Bool, filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool)
    
    /** 视频开始录制 */
    func imageCameraDidStartRecording(filePath: String)
    
    /** 视频录制中 */
    func imageCameraDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval)
}


extension ImageCameraDelegate {
    
    func imageCameraCaptureDeviceDidChange() { }
    
    func imageCameraDidFinishRecording(_ sussess: Bool, filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool) { }
    
    func imageCameraDidStartRecording(filePath: String) { }
    
    func imageCameraDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval) { }
}

class LImageCameraView: UIView {
    
    fileprivate let COUNT_DUR_TIMER_INTERVAL: TimeInterval = 0.05
    
    public weak var delegate: ImageCameraDelegate?
    
    public var captureSession = AVCaptureSession()
    
    /**
     分辨率  默认：AVCaptureSessionPreset1280x720
     需要在setUpSession调用前设置
     */
    public var sessionPreset = AVCaptureSession.Preset.hd1280x720
    
    /**
     预览层方向 默认：portrait
     需要在setUpSession调用前设置
     */
    public var captureVideoPreiewOrientation = AVCaptureVideoOrientation.portrait
    
    /** 视频设备 */
    public var captureDevice: AVCaptureDevice?
    public var captureDeviceInput: AVCaptureDeviceInput?
    
    /** 音频设备 */
    public var audioDevice: AVCaptureDevice?
    public var audioDeviceInput: AVCaptureDeviceInput?
    
    /** 视频输出流 */
    public var captureMovieFileOutput = AVCaptureMovieFileOutput()
    
    /** 预览层 */
    public var previewLayer: AVCaptureVideoPreviewLayer?
    
    /** 视频地址 */
    fileprivate(set) var videoFilePath: String = ""
    
    /** 视频总时间 */
    fileprivate(set) var totleDuration: TimeInterval = 0
    
    /** 最小时长 */
    public var minDuration: TimeInterval = 1
    /** 最大时长 */
    public var maxDuration: TimeInterval = Double.leastNormalMagnitude
    /** 是否正在录制 */
    fileprivate(set) var isRecording: Bool = false
    
    fileprivate var countDurTime: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("LImageCameraView  +  释放")
    }
    
    // MARK: - public
    public func setUpSession() {
        // 设置分辨率
        if captureSession.canSetSessionPreset(sessionPreset) {
            captureSession.sessionPreset = sessionPreset
        }
        
        // 视频
        captureDevice = AVCaptureDevice.default(for: .video)
        
        guard let videoDevice = captureDevice else {
            print("获取视频设备失败")
            return
        }
        
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print(error.localizedDescription)
        }
        
        captureDevice = AVCaptureDevice.default(for: .audio)
        guard let audioDevice = captureDevice else {
            print("获取音频设备失败")
            return
        }
        
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            print(error.localizedDescription)
        }
        
        if captureSession.canAddInput(audioDeviceInput!) {
            captureSession.addInput(audioDeviceInput!)
        }
        
        // 不设置这个属性，超过10s的视频会没有声音
        captureMovieFileOutput.movieFragmentInterval = .invalid
        if captureSession.canAddOutput(captureMovieFileOutput) {
            captureSession.addOutput(captureMovieFileOutput)
            
            let captureConnection = captureMovieFileOutput.connection(with: .video)
            // 开启视频防抖
            if captureConnection?.isVideoStabilizationSupported == true {
                captureConnection?.preferredVideoStabilizationMode = .auto
            }
        }
        
        // 预览层
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = bounds
        layer.insertSublayer(previewLayer!, at: 0)
        
        // 设置预览层方向
        let captureConnection = previewLayer?.connection
        captureConnection?.videoOrientation = captureVideoPreiewOrientation
        
        // 填充模式
        previewLayer?.videoGravity = .resizeAspectFill
        
            
    }
    
}
