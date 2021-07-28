//
//  VideoContentView.swift
//  LImagePicker
//
//  Created by L on 2021/7/26.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit


class VideoNavView: UIView {
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 5, y: LConstant.statusHeight + 2, width: 40, height: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_video_back"), for: .normal)
        return button
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
        addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
    }
    
    @objc fileprivate func backButtonClick() {
        viewController()?.dismiss(animated: true, completion: nil)
    }
    
}

class VideoBottomView: UIView {
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: (LConstant.screenWidth - 60)/4, height: 80)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.l_width, height: self.l_height - LConstant.barMargin),collectionViewLayout: flowLayout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    fileprivate var dataArray: [VideoBottomButtonType] = [.music, .volume, .filter, .cover]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
        collectionView.register(VideoBottomCollectionViewCell.self, forCellWithReuseIdentifier: VideoBottomCollectionViewCell.l_identifire)
        addSubview(collectionView)
    }

    
}

extension VideoBottomView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoBottomCollectionViewCell.l_identifire, for: indexPath) as! VideoBottomCollectionViewCell
        cell.nameLabel.text = dataArray[indexPath.row].name
        cell.iconImage.image = UIImage.lImageNamedFromMyBundle(name: dataArray[indexPath.row].iconImage)
        return cell
    }
    
}



class VideoBottomCollectionViewCell: UICollectionViewCell {
    
    fileprivate lazy var iconImage: UIImageView = {
        let iconImage = UIImageView()
        return iconImage
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "音乐"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
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
        contentView.addSubview(iconImage)
        contentView.addSubview(nameLabel)
        
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        iconImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        iconImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: iconImage.bottomAnchor, constant: 8).isActive = true
        
    }
    
}

enum VideoBottomButtonType {
    case music
    case volume
    case filter
    case cover
    
    var name: String {
        switch self {
        case .music:
            return "音乐"
        case .volume:
            return "音量"
        case .filter:
            return "滤镜"
        case .cover:
            return "封面"
        }
    }
    
    var iconImage: String {
        switch self {
        case .music:
            return "icon_down_pic"
        case .volume:
            return "icon_down_pic"
        case .filter:
            return "icon_down_pic"
        case .cover:
            return "icon_down_pic"
        }
    }
    
}
