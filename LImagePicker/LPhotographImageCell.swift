//
//  LPhotographImageCell.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LPhotographImageCell: LPhotographCollectionViewCell {
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
    }
    
    
    public func loadingResourcesModel(_ mediaModel: LPhotographModel) {
        mediaAsset = mediaModel.media
        loadingPhotoAsset(mediaModel.media)
    }
    
    fileprivate func loadingPhotoAsset(_ asset: PHAsset) {
        representedAssetIdentifier = asset.localIdentifier
        let resquestID = LImagePickerManger.shared.getPhotoWithAsset(asset, size: CGSize(width: self.l_width * UIScreen.main.scale, height: self.l_height * UIScreen.main.scale)) { (progress, error, objc, info) in
            print(progress)
        } completion: { (image, isDegraded) in
            if self.representedAssetIdentifier == asset.localIdentifier {
                self.imageView.image = image
                self.setNeedsLayout()
            }else {
                PHImageManager.default().cancelImageRequest(self.imageRequestID)
            }
            if !isDegraded {
                self.imageRequestID = 0
            }
        }
        if resquestID != self.imageRequestID {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
        }
        self.imageRequestID = resquestID
        self.setNeedsLayout()
    }
    
    
}
