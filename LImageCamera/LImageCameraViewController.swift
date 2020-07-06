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

public class LImageCameraViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
    }
    
    
    // MARK: - initView
    fileprivate func initView() {
//        let session = AVCaptureSession()
        
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let availableCameraDevices = session.devices.compactMap{ $0 }
        guard !availableCameraDevices.isEmpty else { return }
        
        for camera in availableCameraDevices {
            if camera.position == .back {
                
            }
        }
        
        
    }

}
