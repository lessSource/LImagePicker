//
//  LCameraPickerViewController.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation

class LCameraPickerViewController: UIViewController {

    // 视频
    fileprivate lazy var videoView: LCameraPickerView = {
        let videoView = LCameraPickerView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight))
//        videoView.delegate = self
        videoView.maxDuration = 15
        return videoView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "拍照"
        
        view.addSubview(videoView)
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            videoView.setUpSession()
            videoView.captureSession.startRunning()
        }
        
        
//        let videoNameStr = App.cocumentsPath + "1231231212.mp4"
//        videoView.startRecordVideo(filePath: videoNameStr)
        
    }
    
    deinit {
        print(self, "+  释放")

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }

}
