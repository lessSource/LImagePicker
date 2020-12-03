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
        
    fileprivate lazy var selectButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    fileprivate lazy var selectImageView: UIImageView = {
        let selectImageView = UIImageView()
        selectImageView.contentMode = .scaleAspectFit
        selectImageView.clipsToBounds = true
        return selectImageView
    }()
    
    fileprivate lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.mediaSelectColor
        label.textColor = UIColor.mediaSelectTextColor
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isHidden = true
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
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectImageView.frame = CGRect(x: l_width - 26, y: 6, width: 20, height: 20)
        indexLabel.frame = selectImageView.frame
        selectButton.frame = CGRect(x: l_width - 44, y: 0, width: 44, height: 44)
        imageMaskView.frame = contentView.bounds
    }
    
    // MARK: - initView
    fileprivate func initView() {
        contentView.addSubview(selectImageView)
        contentView.addSubview(indexLabel)
        contentView.addSubview(imageMaskView)
        contentView.addSubview(selectButton)
        selectButton.addTarget(self, action: #selector(selectButtonClick), for: .touchUpInside)
    }
    
    // 相册
    public func selectSerialNumber(index: Int, allowSelect: Bool) {
        if index == 0 {
            selectImageView.image = UIImage.lImageNamedFromMyBundle(name: "icon_photograph_nor")
            selectImageView.isHidden = false
            indexLabel.isHidden = true
            imageMaskView.isHidden = allowSelect
        }else {
            selectImageView.isHidden = true
            indexLabel.isHidden = false
            indexLabel.text = "\(index)"
            imageMaskView.isHidden = true
        }
    }
    
    // 预览
    public func previewSelect(isCurrent: Bool, isSelect: Bool) {
        selectImageView.isHidden = true
        indexLabel.isHidden = true
        selectButton.isHidden = true
        imageMaskView.isHidden = isSelect
        if isCurrent {
            imageView.layer.borderColor = UIColor.withHex(hexString: "#007AFD").cgColor
            imageView.layer.borderWidth = 3
        }else {
            imageView.layer.borderWidth = 0
        }
    }
    
}

@objc
extension LPhotographImageCell {
    
    fileprivate func selectButtonClick() {
//        selectImageView.l_showOscillatoryAnimation()
        didSelectClosure()
    }
    
}


class LPhotographShootingCell: UICollectionViewCell {
    
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
