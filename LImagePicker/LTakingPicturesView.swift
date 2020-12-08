//
//  LTakingPicturesView.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

class LTakingPicturesView: UIView {
    
    fileprivate let COUNT_DUR_TIMER_INTERVAL: TimeInterval = 0.05
    
    public weak var delegate: LTakingPicturesProtocol?
    
    /** 最小时长 */
    public var minDuration: TimeInterval = 1
    /** 最大时长 */
    public var maxDuration: TimeInterval = 10
    /** 是否允许拍视频 */
    public var allowPickingVideo: Bool = false
    /** 负责输入和输出设备之间的连接会话,数据流的管理控制 */
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
    fileprivate var captureDevice: AVCaptureDevice?
    fileprivate var captureDeviceInput: AVCaptureDeviceInput?
    
    /** 音频设备 */
    fileprivate var audioDevice: AVCaptureDevice?
    fileprivate var audioDeviceInput: AVCaptureDeviceInput?
    
    /** 拍照 */
    fileprivate var photoOutput = AVCapturePhotoOutput()
    
    /** 视频输出流 */
    fileprivate var captureMovieFileOutput = AVCaptureMovieFileOutput()
    
    /** 实时捕获(暂时没用) */
    fileprivate var captureVideoDataOutput = AVCaptureVideoDataOutput()
    
    /** 预览层 */
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    
    /** 视频地址 */
    fileprivate(set) var videoFilePath: String = ""
    
    /** 视频总时间 */
    fileprivate(set) var totleDuration: TimeInterval = 0
    
    /** 是否正在录制 */
    fileprivate(set) var isRecording: Bool = false
    
    /** 当前录制时长 */
    fileprivate var currentDuration: TimeInterval = 0
    
    /** 计时器 */
    fileprivate var countDurTime: Timer?
    
    //
    //    fileprivate var waitingForStop: Bool?
    //
    //    fileprivate var currentDurationArr: Array = [TimeInterval]()
    //
    //
    
    
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
            return
        }
        if captureSession.canAddInput(captureDeviceInput!) {
            captureSession.addInput(captureDeviceInput!)
        }
        
        
        if allowPickingVideo {
            // 音频
            captureDevice = AVCaptureDevice.default(for: .audio)
            guard let audioDevice = captureDevice else {
                print("获取音频设备失败")
                return
            }
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            } catch {
                print(error.localizedDescription)
                return
            }
            if captureSession.canAddInput(audioDeviceInput!) {
                captureSession.addInput(audioDeviceInput!)
            }
        }
        
        // 拍摄照片
        if captureSession.canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            captureSession.addOutput(photoOutput)
        }
        
        // 输出
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
        let captureCpnnection = previewLayer?.connection
        captureCpnnection?.videoOrientation = captureVideoPreiewOrientation
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
        let videoConnection = photoOutput.connection(with: .video)
        if videoConnection?.isVideoOrientationSupported == true {
            videoConnection?.videoOrientation = getCaptureVideoOrientation(orientation: UIDevice.current.orientation)
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
        // 预览图层 和 视频方向保持一致
        captureConnection?.videoOrientation = previewLayer?.connection?.videoOrientation ?? AVCaptureVideoOrientation.portrait
        // 添加路径
        let fileUrl = URL(fileURLWithPath: filePath)
        videoFilePath = filePath
        captureMovieFileOutput.startRecording(to: fileUrl, recordingDelegate: self)
    }
    
    // 结束录制
    public func stopVideoRecoding() {
        //        waitingForStop = true
        if captureMovieFileOutput.isRecording {
            captureMovieFileOutput.stopRecording()
            videoFilePath = ""
        }
        isRecording = false
        stopCountDurTimer()
    }
    
    /** 切换摄像头 */
    public func switchCamera() {
        let newCamara: AVCaptureDevice?
        let newInput: AVCaptureDeviceInput?
        // 另一个摄像头位置
        let position = captureDeviceInput?.device.position
        if position == .front {
            newCamara = cameraWithPosition(.back)
        }else {
            newCamara = cameraWithPosition(.front)
        }
        guard let camara = newCamara else { return }
        // 生成新的输入
        do {
            newInput = try AVCaptureDeviceInput(device: camara)
        } catch {
            print(error.localizedDescription)
            return
        }
        captureSession.beginConfiguration()
        captureSession.removeInput(captureDeviceInput!)
        if captureSession.canAddInput(newInput!) {
            captureSession.addInput(newInput!)
            captureDeviceInput = newInput
        }else {
            captureSession.addInput(captureDeviceInput!)
        }
        captureSession.commitConfiguration()
    }
    
    // 照明灯
    public func hasToTurnoffTheLights() {
        self.captureDevice = cameraWithPosition(.back)
        if self.captureDevice?.hasTorch == true {
            guard let device = self.captureDevice else { return }
            changeDevice(captureDevice: device) { (changeDevice) in
                if changeDevice.torchMode == .off {
                    changeDevice.torchMode = .on
                }else {
                    changeDevice.torchMode = .off
                }
            }
        }
    }
    
    // 焦距
    public func focusModeLocked(lensPosition: CGFloat) {
        guard let device = self.captureDevice else { return }
        changeDevice(captureDevice: device) { (changeDevice) in
            changeDevice.setFocusModeLocked(lensPosition: Float(lensPosition), completionHandler: nil)
        }
    }
    
    // 聚焦和曝光
    public func focusAndExposeTap(tapPoint: CGPoint) {
        let devicePoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: tapPoint) ?? .zero
        guard let device = self.captureDevice else { return }
        changeDevice(captureDevice: device) { (changeDevice) in
            if changeDevice.focusMode != .locked && changeDevice.isFocusPointOfInterestSupported && changeDevice.isFocusModeSupported(changeDevice.focusMode) {
                changeDevice.focusPointOfInterest = devicePoint
                changeDevice.focusMode = .continuousAutoFocus
            }
            if changeDevice.exposureMode != .custom && changeDevice.isExposurePointOfInterestSupported && changeDevice.isExposureModeSupported(changeDevice.exposureMode) {
                changeDevice.exposurePointOfInterest = devicePoint
                changeDevice.exposureMode = .continuousAutoExposure
            }
            changeDevice.isSubjectAreaChangeMonitoringEnabled = true
        }
        
    }
    
    
    
    // MARK: - fileprivate
    fileprivate func getCaptureVideoOrientation(orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result: AVCaptureVideoOrientation = .portrait
        switch orientation {
        case .portrait, .faceUp, .faceDown:
            result = .portrait
        case .portraitUpsideDown:
            result = .portraitUpsideDown
        case .landscapeLeft:
            result = .landscapeRight
        case .landscapeRight:
            result = .landscapeLeft
        default:
            result = .portrait
        }
        return result
    }
    
    
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
            return
        }
        property(captureDevice)
        captureDevice.unlockForConfiguration()
    }
    
    
    // 根据前后位置拿到对应的摄像头
    fileprivate func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: position)
            
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
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


extension LTakingPicturesView: AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) else {
            return
        }
        
        var image: UIImage? = UIImage(data: dataImage)
        if captureDeviceInput?.device.position == AVCaptureDevice.Position.front  {
            if let cgImage = image?.cgImage {
                image = UIImage(cgImage: cgImage, scale: 1.0, orientation: .leftMirrored)
            }            
        }
        image = LImagePickerManager.shared.fixOrientation(aImage: image)
        delegate?.imageCameraDidPhoto(image: image)
        captureSession.stopRunning()
    }
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        //        if waitingForStop == true {
        //            stopVideoRecoding()
        //            return
        //        }
        currentDuration = 0
        startCountDurTimer()
        delegate?.imageCameraDidStartRecording(filePath: videoFilePath)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        //
        //        waitingForStop = false
        if error == nil {
            let isOverDuration = totleDuration >= maxDuration
            //            currentDurationArr.append(currentDuration)
            delegate?.imageCameraDidFinishRecording(filePathUrl: outputFileURL, currentDuration: currentDuration, totalDuration: totleDuration, isOverDuration: isOverDuration)
        }else {
            totleDuration -= currentDuration
            deleteVideoFile(filePathArr: [videoFilePath])
            delegate?.imageCameraDidFailureRecording(filePathUrl: outputFileURL, error: error)
        }
    }
    
}






// /** 移除视频 */
// public func removelastVideo() {
//     if currentDurationArr.count > 1 {
//         totleDuration -= currentDurationArr.last!
//         currentDurationArr.remove(at: currentDurationArr.count - 1)
//         delegate?.publicVideoDidFinishRecording(false, filePathUrl: URL(fileURLWithPath: videoFilePath), currentDuration: 0, totalDuration: totleDuration, isOverDuration: false)
//
//     }
// }
//




// 切换快慢速
// public func changeSpeed() {
//     guard let deviceVideo = captureDeviceInput?.device else {
//         return
//     }
//     var selectedFormet: AVCaptureDevice.Format?
//     var frameRateRange: AVFrameRateRange?
//     let desiredFPS = 240.0
//     var maxWidth: Int32 = 0
//     for format in deviceVideo.formats {
//         for range in format.videoSupportedFrameRateRanges {
//             let desc = format.formatDescription
//             let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
//             let width: Int32 = dimensions.width
//             if range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth {
//                 selectedFormet = format
//                 frameRateRange = range
//                 maxWidth = width
//             }
//
//         }
//     }
//     guard let formet = selectedFormet, let _ = frameRateRange else {
//         return
//     }
//     do {
//         try deviceVideo.lockForConfiguration()
//     } catch  {
//         print(error.localizedDescription)
//     }
//     deviceVideo.activeFormat = formet
//     deviceVideo.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFPS))
//     deviceVideo.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFPS))
//
//     print(deviceVideo.formats)
// }










