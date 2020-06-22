//
//  LAlbumPickerTableViewCell.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/6.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

class LAlbumPickerTableViewCell: UITableViewCell {

    public var albumModel: LAlbumPickerModel = LAlbumPickerModel() {
        didSet {
            nameLabel.text = "\(albumModel.title)(\(albumModel.count))"
            numberLabel.text = "\(albumModel.selectCount)"
            numberLabel.isHidden = albumModel.selectCount == 0
            if let asset = albumModel.asset {
                LImagePickerManager.shared.getPhotoWithAsset(asset, photoWidth: 80) { (image, dic) in
                    self.coverImage.image = image
                }
            }
        }
    }
    
    fileprivate lazy var coverImage: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    fileprivate lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    fileprivate lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(red: 0.12, green: 0.73, blue: 0.13, alpha: 1.00)
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 15)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         selectionStyle = .none
         accessoryType = .disclosureIndicator
         layoutView()
     }
     

     override func layoutSubviews() {
         super.layoutSubviews()

         coverImage.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height - 1)
         lineView.frame = CGRect(x: coverImage.frame.maxX, y: coverImage.l_height, width: LConstant.screenWidth - coverImage.l_width, height: 1)
         nameLabel.frame = CGRect(x: coverImage.l_width + 10, y: 20, width: contentView.l_width - coverImage.l_width - 60, height: bounds.height - 40)
         let width = CGFloat.maximum(numberLabel.intrinsicContentSize.width + 8, 24)
         numberLabel.frame = CGRect(x: nameLabel.frame.maxX + 45 - width, y: bounds.height/2 - 12, width: width, height: 24)
     }
     
     // MARK:- layoutView
     fileprivate func layoutView() {
         contentView.addSubview(coverImage)
         contentView.addSubview(lineView)
         contentView.addSubview(nameLabel)
         contentView.addSubview(numberLabel)
     }

}
