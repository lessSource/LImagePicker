//
//  LShowImageViewController.swift
//  LImageShow
//
//  Created by L j on 2020/6/19.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos
import LPublicImageParameter

private let cellMargin: CGFloat = 20

public class LShowImageViewController: UICollectionViewController {
        
    weak var imageDelegate: LShowImageVCDelegate?
    
    fileprivate lazy var configuration = LShowImageConfiguration()
    
    /** 是否显示导航栏 */
    fileprivate lazy var isNacBar: Bool = true
    /** 当前序号  */
    fileprivate(set) var currentIndex: Int = 0 {
        didSet {
            navView.titleLabel.text = "\(currentIndex + 1)/\(configuration.dataArray.count)"
        }
    }

    fileprivate lazy var navView: LShowImageNavView = {
        let navView = LShowImageNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar), configuration: configuration)
        navView.imageDelegate = self
        return navView
    }()
    
    fileprivate lazy var tabBarView: LShowImageTabBarView = {
        let barView: LShowImageTabBarView = LShowImageTabBarView(frame: CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        barView.imageDelegate = self
        return barView
    }()
    
    fileprivate override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(configuration: LShowImageConfiguration) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: LConstant.screenWidth + cellMargin, height: LConstant.screenHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.init(collectionViewLayout: layout)
        self.configuration = configuration
    }

    deinit {
        print(self, "+++++释放")
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.imageDelegate?.showImageDidDisappear(self)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
    }

    fileprivate func layoutView() {
        collectionView?.frame = UIScreen.main.bounds
        collectionView?.l_width = LConstant.screenWidth + cellMargin
        collectionView?.alwaysBounceHorizontal = true
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.register(LShowImageCollectionViewCell.self, forCellWithReuseIdentifier: LShowImageCollectionViewCell.l_identifire)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: configuration.currentIndex), at: .left, animated: false)
        view.addSubview(navView)
//        view.addSubview(tabBarView)
        navView.titleLabel.text = "\(currentIndex + 1)/\(configuration.dataArray.count)"
        tabBarView.originalButton.isSelected = configuration.isOriginalImage
        tabBarView.maxCount = configuration.maxCount
        tabBarView.selectCount = configuration.selectCount
    }
    
    fileprivate func imageClick(_ cell: LShowImageCollectionViewCell, cellForItemAt indexPath: IndexPath, type: LShowImageCollectionViewCell.ActionEnum) {
        switch type {
        case .tap:
            UIView.animate(withDuration: 0.15, animations: {
                self.tabBarView.l_y = !self.isNacBar ? LConstant.screenHeight - self.tabBarView.l_height : LConstant.screenHeight
                self.navView.l_y = !self.isNacBar ? 0 : -LConstant.navbarAndStatusBar
            }) { (successful) in
                self.isNacBar = !self.isNacBar
            }
        case .long:
            if configuration.isSave {
            }
            showAlertController("提示", message: nil, preferredStyle: .actionSheet, actionTitles: ["保存", "取消"]) { (index) in
                
            }
            print("long")
        case .play: break
//            let showVideoPlayVC = ShowVideoPlayViewController()
//            showVideoPlayVC.videoModel = configuration.dataArray[indexPath.section]
//            showVideoPlayVC.currentImage = cell.currentImage.image
//            showVideoPlayVC.modalPresentationStyle = .custom
//            present(showVideoPlayVC, animated: false, completion: nil)
        }
    }
}

// MARK: UICollectionViewDataSource
extension LShowImageViewController {
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return configuration.dataArray.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LShowImageCollectionViewCell.l_identifire, for: indexPath) as! LShowImageCollectionViewCell
        cell.updateImage(imageData: configuration.dataArray[indexPath.section])
        cell.imageClick(action: { [weak self] (type) in
            self?.imageClick(cell, cellForItemAt: indexPath, type: type)
        })
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let showImageCell =  cell as? LShowImageCollectionViewCell {
            showImageCell.scrollView.zoomScale = 1.0
            showImageCell.livePhoto.stopPlayback()
            showImageCell.livePhoto.isHidden = true
        }
        
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let showImageCell =  cell as? ShowImageCollectionViewCell  {
//            showImageCell.updateImage(imageData: configuration.dataArray[indexPath.section])
//        }
//        print("将要进入 %ld",indexPath.section);
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.l_width)
        navView.isImageSelect = configuration.dataArray[currentIndex].isSelect
        switch configuration.selectType {
        case .default: break
        case .video:
            if configuration.dataArray[currentIndex].dataEnum != .video {
                navView.selectButton.isUserInteractionEnabled = false
                navView.selectImageView.isHidden = true
            }else {
                navView.selectButton.isUserInteractionEnabled = true
                navView.selectImageView.isHidden = false
            }
        case .image:
            if configuration.dataArray[currentIndex].dataEnum == .video {
                navView.selectButton.isUserInteractionEnabled = false
                navView.selectImageView.isHidden = true
            }else {
                navView.selectButton.isUserInteractionEnabled = true
                navView.selectImageView.isHidden = false
            }
        }
    }
}

// MARK: ShowImageNavTabDelegate
extension LShowImageViewController: LShowImageNavTabDelegate {

    func showImageNavDidSelect(_ view: LShowImageNavView, buttonType: ShowImageButtonType) {
        switch buttonType {
        case .select:
            if self.imageDelegate?.showImageDidSelect(self, index: currentIndex, imageData: configuration.dataArray[currentIndex]) == true {
                configuration.dataArray[currentIndex].isSelect = !configuration.dataArray[currentIndex].isSelect
                navView.selectImageViewAnimation(configuration.dataArray[currentIndex].isSelect)
                if configuration.dataArray[currentIndex].isSelect {
                    configuration.selectCount += 1
                }else {
                    configuration.selectCount -= 1
                }
                tabBarView.selectCount = configuration.selectCount
//                collectionView.reloadData()
//
                
            }
        case .delete:
            showAlertController(message: "是否删这张照片", actionTitles: ["确认","取消"]) { [weak self] (actionIndex) in
                guard let `self` = self else { return }
                if actionIndex == 0 {
                    self.imageDelegate?.showImageDidDelete(self, index: self.currentIndex, imageData: self.configuration.dataArray[self.currentIndex])
                    self.configuration.dataArray.remove(at: self.currentIndex)
                    self.currentIndex = min(self.currentIndex, self.configuration.dataArray.count)
                    self.collectionView.reloadData()
                    if self.configuration.dataArray.count == 0 {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        default:break
        }
    }
    
    func showImageBarDidSelect(_ view: LShowImageTabBarView, buttonType: ShowImageButtonType) {
        switch buttonType {
        case .complete:
            self.dismiss(animated: false, completion: nil)
            imageDelegate?.showImageDidComplete(self)
        case .original:
            self.configuration.isOriginalImage = !self.configuration.isOriginalImage
            imageDelegate?.showImageGetOriginalImage(self, isOriginal: self.configuration.isOriginalImage)
        default: break
        }
    }
}

