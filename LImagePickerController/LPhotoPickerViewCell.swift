//
//  LPhotoPickerCollectionViewCell.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/31.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LPhotoPickerViewCell: UICollectionViewCell {
    
    public var asset: PHAsset? {
        didSet {
            if let asset = asset {
                loadingPhotoAsset(asset)
            }
        }
    }
    
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public lazy var progressView: LProgressView = {
        let progressView = LProgressView()
        progressView.isHidden = true
        return progressView
    }()
    
    fileprivate lazy var representedAssetIdentifier: String = ""
    
    fileprivate lazy var imageRequestID: PHImageRequestID = 0

    fileprivate var bigImageRequestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWith()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initWith() {
        imageView.frame = contentView.bounds
        imageView.backgroundColor = UIColor.blue
        contentView.addSubview(imageView)
    }
    
}


extension LPhotoPickerViewCell {
    
    fileprivate func loadingPhotoAsset(_ asset: PHAsset) {
        representedAssetIdentifier = asset.localIdentifier
        
        let imaegRequestID0 = LImagePickerManager.shared.getPhotoWithAsset(asset, photoWidth: self.l_width, completion: { (photo, info, isDegraded) in
            
            if self.representedAssetIdentifier == asset.localIdentifier {
                self.imageView.image = photo
                self.setNeedsLayout()
            }else {
                PHImageManager.default().cancelImageRequest(self.imageRequestID)
            }
            if !isDegraded {
//                [self hideProgressView];
                self.imageRequestID = 0
            }
        }, progressHandler: nil, networkAccessAllowed: false)
        if imaegRequestID0 != self.imageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        self.imageRequestID = imaegRequestID0
        
        // 用户选中了图片，提前获取一下大图
        if true {
            requestBigImage()
        }else {
            cancelBigImageRequest()
        }
        self.setNeedsLayout()
    }
    
}


extension LPhotoPickerViewCell {
    
    // 获取大图
    fileprivate func requestBigImage() {
        if bigImageRequestID != nil {
            PHImageManager.default().cancelImageRequest(bigImageRequestID!)
        }
        guard let `asset` = asset else { return }
        
        bigImageRequestID = LImagePickerManager.shared.requestImageDataForAsset(asset, completion: { (imageData, dataUTI, orientation, info) in
            
        }, progressHandler: { (progress, error, objc, info) in
            
        })
        
        // Video
        if true {
            LImagePickerManager.shared.getVideoWithAsset(asset, progressHandler: nil) { (playerItem, info) in
                
            }
        }
        
    }
    
    // 取消大图
    fileprivate func cancelBigImageRequest() {
        if bigImageRequestID != nil {
            PHImageManager.default().cancelImageRequest(bigImageRequestID!)
        }
    }
  
}
