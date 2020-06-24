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
            numberLabel.text = "\(albumModel.selectCount) "
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
        view.backgroundColor = UIColor.lLineColor
        return view
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lLabelColor
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
    
    // MARK:- layoutView
    fileprivate func layoutView() {
        contentView.addSubview(coverImage)
        contentView.addSubview(lineView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(numberLabel)
        
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        coverImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        coverImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.topAnchor.constraint(equalTo: coverImage.bottomAnchor).isActive = true
        lineView.leftAnchor.constraint(equalTo: coverImage.rightAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: LConstant.screenWidth - 80).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: coverImage.centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: coverImage.rightAnchor, constant: 10).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.centerYAnchor.constraint(equalTo: coverImage.centerYAnchor).isActive = true
        numberLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        numberLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        
        
    }
    
}
