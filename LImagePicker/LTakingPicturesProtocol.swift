//
//  LTakingPicturesProtocol.swift
//  LImagePicker
//
//  Created by L. on 2020/12/1.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit


protocol LTakingPicturesProtocol: LImagePickerProtocol {
    
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
    func imageCameraDidPhoto(image: UIImage?)
    
}

extension LTakingPicturesProtocol {
    
    func imageCameraCaptureDeviceDidChange() { }
    
    func imageCameraDidFinishRecording(filePathUrl: URL, currentDuration: TimeInterval, totalDuration: TimeInterval, isOverDuration: Bool) { }
    
    func imageCameraDidFailureRecording(filePathUrl: URL, error: Error?) { }

    func imageCameraDidStartRecording(filePath: String) { }
    
    func imageCameraDidRecording(filePath: String, currentDuration: TimeInterval, totalDuration: TimeInterval) { }
    
    func imageCameraDidPhoto(image: UIImage?) { }
    
}

enum LTakingPicturesOperationType: String {
    case shooting = "拍摄"
    case suspended = "暂停"
    case taking = "拍照"
    case remake = "重拍"
    case cancle = "取消"
    case complete = "完成"
    case flash = "闪光灯"
    case switchCamera = "切换相机"
}


protocol LTakingPicturesOperationDelegate: LImagePickerProtocol {
    
    func operationViewDidSelect(buttonType: LTakingPicturesOperationType)
    
    func operationViewPlayStatus() -> Bool
    
    func operationViewPinch(view: LTakingPicturesOperationView, value: CGFloat)
    
}
