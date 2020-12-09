//
//  LTakingPicturesController.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LTakingPicturesController: UIViewController {

    public weak var imagePickerDelegate: LImagePickerProtocol?
    
    /** 是否允许拍视频 */
    fileprivate var allowPickingVideo: Bool = false
    /** 拍视频时长 */
    fileprivate var maxDuration: TimeInterval = 15
        
    fileprivate var contentImage: UIImage?
    
    // 拍摄
    fileprivate lazy var takingPicturesView: LTakingPicturesView = {
        let videoView = LTakingPicturesView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight))
        videoView.delegate = self
        videoView.maxDuration = 15
        return videoView
    }()
    
    // 操作
    fileprivate lazy var operationView: LTakingPicturesOperationView = {
        let view = LTakingPicturesOperationView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight))
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    
    convenience init(allowPickingVideo: Bool, maxDuration: TimeInterval) {
        self.init(nibName: nil, bundle: nil)
        self.allowPickingVideo = allowPickingVideo
        self.maxDuration = maxDuration
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        LImagePickerManager.shared.shouldFixOrientation = true
        initView()
        
    }

    // MARK: - initView
    fileprivate func initView() {
        view.addSubview(takingPicturesView)
        cameraAuthorization {
            self.view.addSubview(self.operationView)
            self.takingPicturesView.setUpSession()
            self.takingPicturesView.captureSession.startRunning()
        }
 
    }
    
    // MARK: - 权限
    fileprivate func cameraAuthorization(allow: @escaping (() -> ())) {
        LImagePickerManager.shared.requestsCameraAuthorization(mediaType: .video) { (videoAuthorized) in
            if videoAuthorized {
                if self.allowPickingVideo {
                    LImagePickerManager.shared.requestsCameraAuthorization(mediaType: .audio) { (audioAuthorized) in
                        if audioAuthorized { allow()
                        }else { self.placeholderShow(mediaType: .audio) }
                    }
                }else { allow() }
            }else { self.placeholderShow(mediaType: .video) }
        }
    }
    
    // 提示
    fileprivate func placeholderShow(mediaType: AVMediaType) {
        view.placeholderShow(true) { (promptView) in
            promptView.title("请在iPhone的\'设置-隐私-\(mediaType == .video ? "相机" : "麦克风")'选项中\r允许\(LApp.appName)访问你的\(mediaType == .video ? "相机" : "麦克风")")
            promptView.imageName("icon_permissions")
            promptView.delegate = self
        }
    }
    
    
    // MARK: - fileprivate
    fileprivate func imageCameraCompleteShooting() {
        operationView.shootingComplete()
    }
}

extension LTakingPicturesController: LTakingPicturesProtocol, LTakingPicturesOperationDelegate, LPromptViewDelegate {
    

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
        takingPicturesView.captureSession.stopRunning()
        
//        if !view.subviews.contains(playerView) {
//            view.insertSubview(playerView, at: 1)
//            playerView.play(url: filePathUrl)
//        }
        
//        if isSave {
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePathUrl)
//            }, completionHandler: nil)
//        }
    }
    
    func imageCameraDidPhoto(image: UIImage?) {
        // 拍摄照片
        imageCameraCompleteShooting()
        contentImage = image
    }
    
    
    func operationViewDidSelect(buttonType: LTakingPicturesOperationType) {
        switch buttonType {
        case .shooting: break
//            let videoNameStr = App.cocumentsPath + "/\(Date().milliStamp).mp4"
//            takingPicturesView.startRecordVideo(filePath: videoNameStr)
        case .suspended:
            takingPicturesView.stopVideoRecoding()
        case .taking:
            takingPicturesView.startRecordPhoto()
//            takingPicturesView.startRecordVideo(filePath: "122")
//            takingPicturesView.focusModeLocked(lensPosition: 0.1)
        case .remake:
            takingPicturesView.captureSession.startRunning()
//            tabBarView.isHidden = true
//            playerView.removeView()
        case .cancle:
            dismiss(animated: true, completion: nil)
        case .complete:
            if let image = contentImage {
                
                
//                LImagePickerManager.shared.savePhotoWithImage(image: image, location: nil) { (asset) in
//                    self.imagePickerDelegate?.takingPicturesSaveImage(viewController: self, asset: asset)
//                } failureClosure: { (error) in
//                    print(error ?? "")
//                }
                var localIdentifier = ""
                PHPhotoLibrary.shared().performChanges {
                    print("111111")
                    let reuqest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localIdentifier = reuqest.placeholderForCreatedAsset?.localIdentifier ?? ""
                    reuqest.location = nil
                    reuqest.creationDate = Date()
                } completionHandler: { (success, error) in

                }
                print(image)
            }
            imagePickerDelegate?.takingPictures(viewController: self, image: contentImage)
            dismiss(animated: true, completion: nil)
        case .flash:
            break
        case .switchCamera:
            break
        }
    }
    
    func operationViewPlayStatus() -> Bool {
//        return takingPicturesView.isRecording
        return true
    }
    
    func operationViewPinch(view: LTakingPicturesOperationView, value: CGFloat) {
        takingPicturesView.videoZoomFactor(value: value)
    }
    
    
    func promptViewImageClick(_ promptView: LImagePickerPromptView) {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [: ], completionHandler: nil)
        }
    }
    
}
