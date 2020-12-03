//
//  LTakingPicturesView.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class LTakingPicturesView: UIView {
    
    fileprivate let COUNT_DUR_TIMER_INTERVAL: TimeInterval = 0.05

    public weak var delegate: LTakingPicturesProtocol?
    
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
    public var captureVideoDataOutput = AVCaptureVideoDataOutput()
    
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
    
    // 重力感应对象
    fileprivate var cmmotionManager: CMMotionManager = CMMotionManager()
    
    // 记录设备方向
    fileprivate var deviceOrientation: UIDeviceOrientation = .unknown
    
    // 识别方向
    public var senseType: LDirectionSenseType = .none {
        didSet {
            setSenseType(senseType: senseType)
        }
    }
    
    /** 是否正在录制 */
    fileprivate(set) var isRecording: Bool = false
    
    fileprivate var waitingForStop: Bool?
    fileprivate var currentDuration: TimeInterval = 0
    fileprivate var currentDurationArr: Array = [TimeInterval]()
    
    fileprivate var countDurTime: Timer?
    
    fileprivate var filter: CIFilter = CIFilter(name: "CIPhotoEffectTransfer")!
    fileprivate lazy var context: CIContext = {
        let eaglContext = EAGLContext(api: .openGLES2)
        
        let options = [CIContextOption.workingColorSpace: NSNull()]
        return CIContext(eaglContext: eaglContext!, options: options)
    }()
    
    lazy var filterNames: [String] = {
        return ["CIColorInvert", "CIPhotoEffectMono", "CIPhotoEffectInstant", "CIPhotoEffectTransfer"]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        senseType = .system
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
        captureSession.beginConfiguration()
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
        }
                
        // 不设置这个属性，超过10s的视频会没有声音
        captureVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(captureVideoDataOutput) {
            captureSession.addOutput(captureVideoDataOutput)
            let captureConnection = captureVideoDataOutput.connection(with: .video)
            // 开启视频防抖
            if captureConnection?.isVideoStabilizationSupported == true {
                captureConnection?.preferredVideoStabilizationMode = .auto
            }
        }
        captureVideoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        
        // 预览层
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = bounds
        layer.insertSublayer(previewLayer!, at: 0)
        
        // 设置预览层方向
        let captureConnection = previewLayer?.connection
        captureConnection?.videoOrientation = captureVideoPreiewOrientation
        
        // 填充模式
        previewLayer?.videoGravity = .resizeAspectFill
        captureSession.commitConfiguration()
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
            if senseType == .system {
                videoConnection?.videoOrientation = getCaptureVideoOrientation(orientation: UIDevice.current.orientation)
            }else {
                videoConnection?.videoOrientation = getCaptureVideoOrientation(orientation: deviceOrientation)
            }
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /** 开始录制 */
    public func startRecordVideo(filePath: String) {
        if totleDuration >= maxDuration {
            return
        }
        isRecording = true
        let captureConnection = captureVideoDataOutput.connection(with: .video)
        // 如果正在录制，则重新录制，先暂停
//        if captureVideoDataOutput.isRecordin {
//            stopVideoRecoding()
//        }
        // 预览图层和视频方向保持一致
        captureConnection?.videoOrientation = previewLayer?.connection?.videoOrientation ?? AVCaptureVideoOrientation.portrait
        if !videoFilePath.isEmpty {
            deleteVideoFile(filePathArr: [videoFilePath])
        }
        // 添加路径
        let fileUrl = URL(fileURLWithPath: filePath)
        videoFilePath = filePath
//        captureVideoDataOutput.startRecording(to: fileUrl, recordingDelegate: self)
        
    }
    
    // 结束录制
    public func stopVideoRecoding() {
        waitingForStop = true
//        if captureMovieFileOutput.isRecording {
//            captureMovieFileOutput.stopRecording()
//        }
        isRecording = false
        stopCountDurTimer()
    }
    
    // MARK: - fileprivate
    // 设置方向
    fileprivate func setSenseType(senseType: LDirectionSenseType) {
        if senseType == .motion {
            if cmmotionManager.isDeviceMotionAvailable {
                cmmotionManager.startAccelerometerUpdates(to: OperationQueue.current ?? OperationQueue()) { [weak self] (accelerometerData, error) in
                    let x = accelerometerData?.acceleration.x ?? 0.0
                    let y = accelerometerData?.acceleration.y ?? 0.0
                    if fabs(y) >= fabs(x) {
                        if y >= 0 {
                            self?.deviceOrientation = .portraitUpsideDown
                        }else {
                            self?.deviceOrientation = .portrait
                        }
                    }else {
                        if x >= 0 {
                            self?.deviceOrientation = .landscapeRight
                        }else {
                            self?.deviceOrientation = .landscapeLeft
                        }
                    }
                    
                }
            }
        }
    }
    
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


extension LTakingPicturesView: AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("1234")
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        var currentVideoDimensions: CMVideoDimensions? = CMVideoFormatDescriptionGetDimensions(formatDescription!)
        var currentSampleTime: CMTime? = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)

        var outputImage = CIImage(cvImageBuffer: imageBuffer!)
        if filter != nil {
            filter.setValue(outputImage, forKey: kCIInputImageKey)
            outputImage = filter.outputImage!
            let orientation = UIDevice.current.orientation
            var t: CGAffineTransform!
            if orientation == UIDeviceOrientation.portrait {
                t = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
            } else if orientation == UIDeviceOrientation.portraitUpsideDown {
                t = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
            } else if (orientation == UIDeviceOrientation.landscapeRight) {
                t = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                t = CGAffineTransform(rotationAngle: 0)
            }
            outputImage = outputImage.transformed(by: t)
            let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent)
            DispatchQueue.main.async {
                self.previewLayer?.contents = cgImage
            }
        }
        
    }
    

    
    
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
