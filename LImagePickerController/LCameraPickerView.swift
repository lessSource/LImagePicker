//
//  LCameraPickerView.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/29.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation

protocol LCameraPickerDelegate: class {
    
    /** 当AVCaptureDevice实例检测到视频主要区域有实质性变化时 */
    func cameraPickerCaptureDeviceDidChange()
    
    /** 视频录制完成 */
    func cameraPickerDidFinishRecording(filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool)
    
    /** 视频录制失败 */
    func cameraPickerDidFailureRecording(filePathUrl: URL, error: Error?)
    
    /** 视频开始录制 */
    func cameraPickerDidStartRecording(filePath: String)
    
    /** 视频录制中 */
    func cameraPickerDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval)
    
    /** 照片 */
    func cameraPickerDidFinishPhoto(image: UIImage)
    
    
}

extension LCameraPickerDelegate {
    
    func cameraPickerCaptureDeviceDidChange() { }
     
    func cameraPickerDidFinishRecording(filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool) { }
     
    func cameraPickerDidFailureRecording(filePathUrl: URL, error: Error?) { }
     
    func cameraPickerDidStartRecording(filePath: String) { }
     
    func cameraPickerDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval) { }
     
    func cameraPickerDidFinishPhoto(image: UIImage) { }
}


class LCameraPickerView: UIView {

    fileprivate let COUNT_DUR_TIMER_INTERVAL: TimeInterval = 0.05

    /** 协议 */
    public weak var delegate: LCameraPickerDelegate?
    
    /** 核心类 */
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

    /** 拍摄视频定时器 */
    fileprivate var countDurTimer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(self, "+  释放")

    }
    
}


extension LCameraPickerView {
    
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
        
        guard let captureDeviceInput = captureDeviceInput else {
            return
        }
        if captureSession.canAddInput(captureDeviceInput) {
            captureSession.addInput(captureDeviceInput)
        }
        
        // 音频
        audioDevice = AVCaptureDevice.default(for: .audio)
        guard let audioDevice = audioDevice else {
            print("获取音频设备失败")
            return
        }
        
        if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            } catch {
                print(error.localizedDescription)
            }
        }        
        
        if let audioDeviceInput = audioDeviceInput {
            if captureSession.canAddInput(audioDeviceInput) {
                captureSession.addInput(audioDeviceInput)
            }
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
    
    // 开始录制
    public func startRecordVideo(filePath: String) {
        
        if totleDuration >= maxDuration {
            return
        }
        isRecording = true
        
        guard let captureConnection = captureMovieFileOutput.connection(with: .video) else {
            return
        }
        
        // 如果正在录制，则重新录制，先暂停
        if captureMovieFileOutput.isRecording {
            stopVideoRecoding()
        }
        
        // 预览层和视频方向保持一致
        captureConnection.videoOrientation = previewLayer?.connection?.videoOrientation ?? AVCaptureVideoOrientation.portrait
        if !videoFilePath.isEmpty {
            deleteVideoFile(filePathArr: [videoFilePath])
        }
        // 添加路径
        let fileUrl = URL(fileURLWithPath: filePath)
        videoFilePath = filePath
        captureMovieFileOutput.startRecording(to: fileUrl, recordingDelegate: self)
    }
    
    // 结束录制
    public func stopVideoRecoding() {
//        waiting
        if captureMovieFileOutput.isRecording {
            captureMovieFileOutput.stopRecording()
        }
        isRecording = false
        stopCountDurTimer()
        
    }
    
    // MARK: - fileprivate
    // 添加通知
    fileprivate func addNotification(to captureDevice: AVCaptureDevice) {
        // 注意 添加区域改变捕获通知必须设置设备允许捕获
        changeDevice(captureDevice: captureDevice) { (device) in
            device.isSubjectAreaChangeMonitoringEnabled = true
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceSubjectAreaDidChange, object: nil, queue: .main) { [weak self] note in
            // 当AVCaptureDevice实例检测到视频主题区域有实质性变化时
            self?.delegate?.cameraPickerCaptureDeviceDidChange()
        }
        
    }
    
    // 改变设备属性的统一操作方法
    fileprivate func changeDevice(captureDevice: AVCaptureDevice, property: ((_ device: AVCaptureDevice) -> ())) {
        // 注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
        do {
            try captureDevice.lockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
        property(captureDevice)
        captureDevice.unlockForConfiguration()
    }
    
    // 销毁定时器
    fileprivate func stopCountDurTimer() {
        countDurTimer?.invalidate()
        countDurTimer = nil
    }
    
    // 删除视频文件
    fileprivate func deleteVideoFile(filePathArr: [String]) {
        if filePathArr.isEmpty { return }
        let manager = FileManager.default
        for item in filePathArr {
            do {
                try manager.removeItem(atPath: item)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}


extension LCameraPickerView: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
//        if waitingForStop == true {
//            stopVideoRecoding()
//            return
//        }
//        currentDuration = 0
//        startCountDurTimer()
//        delegate?.imageCameraDidStartRecording(filePath: videoFilePath)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        waitingForStop = false
//        if error == nil {
//            let isOverDuration = totleDuration >= maxDuration
//            currentDurationArr.append(currentDuration)
//            delegate?.imageCameraDidFinishRecording(filePathUrl: outputFileURL, currentDuration: currentDuration, totalDuration: totleDuration, isOverDuration: isOverDuration)
//        }else {
//            totleDuration -= currentDuration
//            deleteVideoFile(filePathArr: [videoFilePath])
//            delegate?.imageCameraDidFailureRecording(filePathUrl: outputFileURL, error: error)
//        }
    }
    
}
