//
//  LShowVideoPlayViewController.swift
//  LImageShow
//
//  Created by L j on 2020/6/22.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

fileprivate let MaxHiddenTime = 5

class VideoViewController: UIViewController {
    
    public var currentImage: UIImage?
    
    public var videoModel: PhotographModel?
    
    fileprivate lazy var videoView: VideoAccordingView = {
        let videoView = VideoAccordingView(frame: self.view.bounds)
        videoView.delegate = self
        return videoView
    }()
    
    fileprivate lazy var operationView: VideoOperationView = {
        let operationView = VideoOperationView(frame: self.view.bounds)
        return operationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    // MARK:- initView
    fileprivate func initView() {
        view.addSubview(videoView)
        view.addSubview(operationView)
        
        if let media = videoModel?.media {
            videoView.requestAVAsset(media: media)
        }
    }
    
}

extension VideoViewController: VideoAccordingProtocol {
    
    func videoAccordingState(_ type: VideoAccordingType) {
        
    }
    
}



class VideoPlayer: UIView {
    
    override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
}



