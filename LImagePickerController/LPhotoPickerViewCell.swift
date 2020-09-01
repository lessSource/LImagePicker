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
        
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    fileprivate lazy var representedAssetIdentifier: String = ""
    
    fileprivate lazy var imageRequestID: PHImageRequestID = 0

    
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
    
    public func photoAsset(asset: PHAsset) {
        representedAssetIdentifier = asset.localIdentifier
        
        let imageRequestID = LImagePickerManager.shared.getPhotoWithAsset(asset, photoWidth: 150, completion: { (image, info, isDegraded) in
            
            if self.representedAssetIdentifier == asset.localIdentifier {
                self.imageView.image = image
                self.setNeedsLayout()
            }else {
                
                PHImageManager.default().cancelImageRequest(self.imageRequestID)
            }
            
            if !isDegraded {
                self.imageRequestID = 0
            }
            
        }, progressHandler: { (do, error, objc, info) in
            
        }, networkAccessAllowed: false)
        
        if self.imageRequestID != imageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        self.imageRequestID = imageRequestID
        
        if true {
            // requestBigImage
        }else {
            // cancelBitImageReuqest
        }
        self.setNeedsLayout()
        
    }
    
}


extension LPhotoPickerViewCell {
    
  
}
