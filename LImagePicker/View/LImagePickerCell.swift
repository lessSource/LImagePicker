//
//  LImagePickerCell.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos
import LPublicImageParameter

class LImagePickerCell: UICollectionViewCell {
    
    typealias SelectClosure = (Bool) -> (Bool)
    
    public var didSelectButtonClosure: SelectClosure?

        public var assetModel: LMediaResourcesModel? {
            didSet {
                guard let model = assetModel else {  return }
                selectButton.isSelected  = model.isSelect
                selectImageView.image = model.isSelect ? UIImage.imageNameFromBundle("icon_album_sel") : UIImage.imageNameFromBundle("icon_album_nor")
                timeLabel.text = model.videoTime
                if let asset = model.dataProtocol as? PHAsset {
                    let width = (LConstant.screenWidth - 3)/4
                    LImagePickerManager.shared.getPhotoWithAsset(asset, photoWidth: width) { (image, dic) in
                        self.imageView.image = image
                    }
                    backView.isHidden = asset.mediaType == .image
                }
            }
        }
    
    public lazy var imageView: UIImageView = {
        let image = UIImageView(frame: self.bounds)
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    public lazy var selectImageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: self.l_width - 29, y: 5, width: 24, height: 24))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.image = UIImage.imageNameFromBundle("icon_album_nor")
        return image
    }()
    
    public lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.l_width - 20, height: 18))
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    public lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: self.l_height - 18, width: self.l_width, height: 18))
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return view
    }()
    
    public lazy var selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.l_width - 44, y: 0, width: 44, height: 44)
        button.addTarget(self, action: #selector(selectButtonClick(_ :)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectImageView)
        contentView.addSubview(selectButton)
        contentView.addSubview(backView)
        backView.addSubview(timeLabel)
    }
    
    // MARK:- Event
     @objc fileprivate func selectButtonClick(_ sender: UIButton) {
        guard let closure = didSelectButtonClosure else { return }
        if closure(sender.isSelected) {
            selectImageView.image = sender.isSelected ? UIImage.imageNameFromBundle("icon_album_nor") : UIImage.imageNameFromBundle("icon_album_sel")
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                selectImageView.showOscillatoryAnimation()
            }
        }
    }
    
}
