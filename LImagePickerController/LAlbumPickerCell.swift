//
//  LAlbumPickerCell.swift
//  LImagePickerController
//
//  Created by L j on 2020/9/2.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LAlbumPickerCell: UITableViewCell {
    
    public lazy var coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    fileprivate lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lLineColor
        return view
    }()
    
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lLabelColor
        label.font = UIFont.systemFont(ofSize: 14)
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
        label.text = "99"
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
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
        lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
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
    
    public func photoAsset(albumModel: LAlbumPickerModel) {
        nameLabel.text = albumModel.title
        
        LImagePickerManager.shared.getPostImageWithAlbumModel(model: albumModel) { (image) in
            self.coverImage.image = image
        }
    }
    
}
