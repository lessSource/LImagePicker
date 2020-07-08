//
//  LImageCameraView.swift
//  LImageCamera
//
//  Created by L j on 2020/7/6.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation

protocol LImageCameraDelegate: class {

    /** 当AVCaptureDevice实例检测到视频主要区域有实质性变化时 */
    func imageCameraCaptureDeviceDidChange()
    
    /** 视频录制完成 */
    func imageCameraDidFinishRecording(filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool)
    
    /** 视频录制失败 */
    func imageCameraDidFailureRecording(filePathUrl: URL, error: Error?)
    
    /** 视频开始录制 */
    func imageCameraDidStartRecording(filePath: String)
    
    /** 视频录制中 */
    func imageCameraDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval)
    
    /** 照片 */
    func imageCameraDidPhoto(image: UIImage)
}


extension LImageCameraDelegate {
    
    func imageCameraCaptureDeviceDidChange() { }
    
    func imageCameraDidFinishRecording(filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool) { }
    
    func imageCameraDidFailureRecording(filePathUrl: URL, error: Error?) { }

    func imageCameraDidStartRecording(filePath: String) { }
    
    func imageCameraDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval) { }
    
    func imageCameraDidPhoto(image: UIImage) { }
}

class LImageCameraView: UIView {
    
    fileprivate let COUNT_DUR_TIMER_INTERVAL: TimeInterval = 0.05
    
    public weak var delegate: LImageCameraDelegate?
    
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
    
    /** 拍照 */
    public var photoOutput = AVCapturePhotoOutput()
    
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
    
    fileprivate var waitingForStop: Bool?
    fileprivate var currentDuration: TimeInterval = 0
    fileprivate var currentDurationArr: Array = [TimeInterval]()
    
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
        
        if captureSession.canAddInput(captureDeviceInput!) {
            captureSession.addInput(captureDeviceInput!)
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
        
        // 拍摄照片
        if captureSession.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            captureSession.addOutput(photoOutput)
            captureSession.commitConfiguration()
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
        
        addNotification(to: captureDevice!)
    }
    
    // 拍照
    public func startRecordPhoto() {
        let settings = AVCapturePhotoSettings()
        if settings.availablePreviewPhotoPixelFormatTypes.count > 0 {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: settings.availablePreviewPhotoPixelFormatTypes.first!]
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /** 开始录制 */
    public func startRecordVideo(filePath: String) {
        if totleDuration >= maxDuration {
            return
        }
        isRecording = true
        let captureConnection = captureMovieFileOutput.connection(with: .video)
        // 如果正在录制，则重新录制，先暂停
        if captureMovieFileOutput.isRecording {
            stopVideoRecoding()
        }
        // 预览图层和视频方向保持一致
        captureConnection?.videoOrientation = previewLayer?.connection?.videoOrientation ?? AVCaptureVideoOrientation.portrait
        // 添加路径
        let fileUrl = URL(fileURLWithPath: filePath)
        videoFilePath = filePath
        captureMovieFileOutput.startRecording(to: fileUrl, recordingDelegate: self)
        
    }
    
    // 结束录制
    public func stopVideoRecoding() {
        waitingForStop = true
        if captureMovieFileOutput.isRecording {
            captureMovieFileOutput.stopRecording()
            videoFilePath = ""
        }
        isRecording = false
        stopCountDurTimer()
    }
    
    // MARK: - fileprivate
    fileprivate func addNotification(to captureDevice: AVCaptureDevice) {
        // 注意 添加区域改变捕获通知必须设置设备允许捕获
        changeDevice(captureDevice: captureDevice) { (device) in
            device.isSubjectAreaChangeMonitoringEnabled = true
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil, queue: OperationQueue.main) { [weak self] note in
            // 当AVCaptureDevice实例检测到视频主题区域有实质性变化时
            self?.delegate?.imageCameraCaptureDeviceDidChange()
        }
    }
    
    fileprivate func startCountDurTimer() {
        countDurTime = Timer(timeInterval: COUNT_DUR_TIMER_INTERVAL, repeats: true, block: { [weak self] (timer) in
            self?.timeTask(time: timer)
        })
        RunLoop.current.add(countDurTime!, forMode: .common)
    }
    
    fileprivate func timeTask(time: Timer) {
        delegate?.imageCameraDidRecording(filePath: videoFilePath, currentDuration: currentDuration, totalDuration: totleDuration)
        // 当录制时间超过最长时间
        if totleDuration >= maxDuration {
            stopVideoRecoding()
        }else {
            currentDuration += COUNT_DUR_TIMER_INTERVAL
            totleDuration += COUNT_DUR_TIMER_INTERVAL
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
    
    fileprivate func stopCountDurTimer() {
        countDurTime?.invalidate()
        countDurTime = nil
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

extension LImageCameraView: AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

        guard let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) else {
            return
        }
        guard let dataProvider = CGDataProvider(data: dataImage as CFData), let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
            return
        }
        
        let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .right)
        delegate?.imageCameraDidPhoto(image: image)
        captureSession.stopRunning()
    }
    

    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        if waitingForStop == true {
            stopVideoRecoding()
            return
        }
        currentDuration = 0
        startCountDurTimer()
        delegate?.imageCameraDidStartRecording(filePath: videoFilePath)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        waitingForStop = false
        if error == nil {
            let isOverDuration = totleDuration >= maxDuration
            currentDurationArr.append(currentDuration)
            delegate?.imageCameraDidFinishRecording(filePathUrl: outputFileURL, currentDuration: currentDuration, totalDuration: totleDuration, isOverDuration: isOverDuration)
        }else {
            totleDuration -= currentDuration
            deleteVideoFile(filePathArr: [videoFilePath])
            delegate?.imageCameraDidFailureRecording(filePathUrl: outputFileURL, error: error)
        }
    }
    
}
