//
//  ShowImageViewController.swift
//  ImitationShaking
//
//  Created by Lj on 2019/6/25.
//  Copyright © 2019 study. All rights reserved.
//


import UIKit
import Photos

private let cellMargin: CGFloat = 20

public class ShowImageViewController: UICollectionViewController {
        
    public weak var imageDelegate: ShowImageVCDelegate?
    
    fileprivate lazy var configuration = ShowImageConfiguration()
    
    /** 是否显示导航栏 */
    fileprivate lazy var isNacBar: Bool = true
    /** 当前序号  */
    fileprivate(set) var currentIndex: Int = 0 {
        didSet {
            navView.titleLabel.text = "\(currentIndex + 1)/\(configuration.dataArray.count)"
        }
    }

    fileprivate lazy var navView: ShowImageNavView = {
        let navView = ShowImageNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar), configuration: configuration)        
        navView.imageDelegate = self
        return navView
    }()
    
    fileprivate lazy var tabBarView: ShowImageTabBarView = {
        let barView: ShowImageTabBarView = ShowImageTabBarView(frame: CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        barView.imageDelegate = self
        return barView
    }()
    
    fileprivate override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(configuration: ShowImageConfiguration) {
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
        collectionView?.register(ShowImageCollectionViewCell.self, forCellWithReuseIdentifier: ShowImageCollectionViewCell.l_identifire)
        collectionView.scrollToItem(at: IndexPath(item: 0, section: configuration.currentIndex), at: .left, animated: false)
        view.addSubview(navView)
        view.addSubview(tabBarView)
        navView.titleLabel.text = "\(currentIndex + 1)/\(configuration.dataArray.count)"
        tabBarView.originalButton.isSelected = configuration.isOriginalImage
        tabBarView.maxCount = configuration.maxCount
        tabBarView.selectCount = configuration.selectCount
    }
    
    fileprivate func imageClick(_ cell: ShowImageCollectionViewCell, cellForItemAt indexPath: IndexPath, type: ShowImageCollectionViewCell.ActionEnum) {
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
        case .play:
            let showVideoPlayVC = ShowVideoPlayViewController()
            showVideoPlayVC.videoModel = configuration.dataArray[indexPath.section]
            showVideoPlayVC.currentImage = cell.currentImage.image
            showVideoPlayVC.modalPresentationStyle = .custom
            present(showVideoPlayVC, animated: false, completion: nil)
        }
    }
}

// MARK: UICollectionViewDataSource
extension ShowImageViewController {
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return configuration.dataArray.count
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowImageCollectionViewCell.l_identifire, for: indexPath) as! ShowImageCollectionViewCell
        
        cell.updateImage(imageData: configuration.dataArray[indexPath.section])
        cell.imageClick(action: { [weak self] (type) in
            self?.imageClick(cell, cellForItemAt: indexPath, type: type)
        })
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let showImageCell =  cell as? ShowImageCollectionViewCell {
            showImageCell.scrollView.zoomScale = 1.0
            showImageCell.livePhoto.stopPlayback()
            showImageCell.livePhoto.isHidden = true
        }
        
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let showImageCell =  cell as? ShowImageCollectionViewCell  {
            showImageCell.updateImage(imageData: configuration.dataArray[indexPath.section])
        }
        print("将要进入 %ld",indexPath.section);
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.l_width)
        navView.isImageSelect = configuration.dataArray[currentIndex].isSelect
    }
}

// MARK: ShowImageNavTabDelegate
extension ShowImageViewController: ShowImageNavTabDelegate {

    func showImageNavDidSelect(_ view: ShowImageNavView, buttonType: ShowImageButtonType) {
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
            }else {
                showAlertController("提示", message: "最多只能选择\(configuration.maxCount)张照片", preferredStyle: .alert, actionTitles: ["OK"], complete: nil)
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
    
    func showImageBarDidSelect(_ view: ShowImageTabBarView, buttonType: ShowImageButtonType) {
        switch buttonType {
        case .complete:
            self.dismiss(animated: false, completion: nil)
            imageDelegate?.showImageDidComplete(self)
        case .original:
            imageDelegate?.showImageGetOriginalImage(self, isOriginal: self.configuration.isOriginalImage)
        default: break
        }
    }
}

