//
//  PhotographCollectionViewCell.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit
import Photos

class PhotographCollectionViewCell: UICollectionViewCell {
    
    fileprivate var imageRequestID: PHImageRequestID = 0
    
    fileprivate var requestAssetIdentifier: String = ""
    
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
    
    // MARK:- initView
    fileprivate func initView() {
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
    }
    
    public func loadingResourcesModel(_ mediaModel: PhotographModel) {
        requestAssetIdentifier = mediaModel.media.localIdentifier
        
        let resquestID = ImagePickerManager.shared.getPhotoWithAsset(mediaModel.media, size: CGSize(width: l_width * UIScreen.main.scale, height: l_height * UIScreen.main.scale)) { image, isDegraded in
            if self.requestAssetIdentifier == mediaModel.media.localIdentifier {
                self.imageView.image = image
                self.setNeedsLayout()
            }else {
//                PHImageManager.default().cancelImageRequest(self.imageRequestID)
            }
            if !isDegraded {
                self.imageRequestID = 0
            }
        }
        if resquestID != self.imageRequestID {
//            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        imageRequestID = resquestID
        setNeedsLayout()
    }
    
}


class PhotographImageCell: PhotographCollectionViewCell {
    
}

class PhotographGifCell: PhotographCollectionViewCell {
    
}

class PhotographVideoCell: PhotographCollectionViewCell {
    
}

class PhotographLivePhotoCell: PhotographCollectionViewCell {
    
}

class PhotographShootingCell: UICollectionViewCell {
    
    fileprivate lazy var iconImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.lImageNamedFromMyBundle(name: "icon_photo_shoot")
        return image
    }()
    
    fileprivate lazy var iconName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.shootingTextColor
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var imageMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.shootingBackColor
        contentView.addSubview(iconImage)
        contentView.addSubview(iconName)
        contentView.addSubview(imageMaskView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImage.frame = CGRect(x: bounds.width/2 - 16, y: 20, width: 32, height: 32)
        iconName.frame = CGRect(x: 10, y: iconImage.frame.maxY, width: l_width - 20, height: iconName.intrinsicContentSize.height)
        imageMaskView.frame = contentView.bounds
    }
    
    public func selectSerialNumber(allowSelect: Bool) {
        imageMaskView.isHidden = allowSelect
        iconName.text = allowSelect ? "拍摄" : "无法拍摄"
        iconImage.image = UIImage.lImageNamedFromMyBundle(name: allowSelect ? "icon_photo_shoot" : "icon_photo_cant_shoot")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}