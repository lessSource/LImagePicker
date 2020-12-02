//
//  LPreviewImageController.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

private let cellMargin: CGFloat = 20

class LPreviewImageController: UICollectionViewController {

    public weak var imagePickerDelegate: LImagePickerProtocol?
    
    /** 数据模型 */
    fileprivate(set) var configuration = LPreviewImageModel()
    
    /** 当前序号 */
    fileprivate(set) var currentIndex: Int = 0
    
    fileprivate lazy var navView: LImagePickerNavView = {
        let navView = LImagePickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.cancleImageStr = "icon_back_white"
        navView.backgroundColor = UIColor.previewNavBackColor
        navView.isPreviewButton = true
        navView.delegate = self
        return navView
    }()
    
    fileprivate lazy var bottomView: LImagePickerBottomView = {
        let bottomView = LImagePickerBottomView(frame: CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        bottomView.backgroundColor = UIColor.previewNavBackColor
        bottomView.isPreviewHidden = true
        return bottomView
    }()
    
    fileprivate override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init(configuration: LPreviewImageModel) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: LConstant.screenWidth + cellMargin, height: LConstant.screenHeight)
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.init(collectionViewLayout: layout)
        self.configuration = configuration
        assert(!(configuration.currentIndex >= configuration.dataArray.count || configuration.currentIndex < 0), "请输入正确的序号")
        self.currentIndex = configuration.currentIndex
        if configuration.currentIndex < 0 || configuration.currentIndex >= configuration.dataArray.count {
            self.currentIndex = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }

    // MARK: - initView
    fileprivate func initView() {
        collectionView.frame = UIScreen.main.bounds
        collectionView.l_width = LConstant.screenWidth + cellMargin
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(LPreviewImageCell.self, forCellWithReuseIdentifier: LPreviewImageCell.l_identifire)
        collectionView.register(LPreviewVideoCell.self, forCellWithReuseIdentifier: LPreviewVideoCell.l_identifire)
        collectionView.register(LPreviewGifCell.self, forCellWithReuseIdentifier: LPreviewGifCell.l_identifire)
        collectionView.register(LPreviewLivePhoteCell.self, forCellWithReuseIdentifier: LPreviewLivePhoteCell.l_identifire)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: configuration.currentIndex), at: .left, animated: false)
        if let photographModel = configuration.dataArray[currentIndex] as? LPhotographModel {
            navView.selectSerialNumber(index: photographModel.selectIndex)
        }
        view.addSubview(navView)
        view.addSubview(bottomView)
        bottomView.number = configuration.dataArray.count
    }
}

extension LPreviewImageController: LImagePickerButtonProtocl {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return configuration.dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LPreviewImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: LPreviewImageCell.l_identifire, for: indexPath) as! LPreviewImageCell
        if let asset = configuration.dataArray[indexPath.section] as? PHAsset  {
            cell.getPhotoAsset(asset: asset)
        }else if let image = configuration.dataArray[indexPath.section] as? UIImage {
            cell.getPhotoImage(image: image)
        }else if let photographModel = configuration.dataArray[indexPath.section] as? LPhotographModel {
            cell.getPhotoAsset(asset: photographModel.media)
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let previewImageCell = cell as? LPreviewCollectionViewCell {
            previewImageCell.scrollView.zoomScale = 1.0
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.l_width)
        if let photographModel = configuration.dataArray[safe: currentIndex] as? LPhotographModel {
            navView.selectSerialNumber(index: photographModel.selectIndex)
        }
    }
    
    func buttonView(view: UIView, buttonType: LImagePickerButtonType) {
        if buttonType == .cancle {
            dismiss(animated: true, completion: nil)
        }else if buttonType == .confirm {
            
        }else if buttonType == .previewSelect {
            if let photographModel = configuration.dataArray[safe: currentIndex] as? LPhotographModel {
                photographModel.isSelect = !photographModel.isSelect
                if !photographModel.isSelect {
                    photographModel.selectIndex = 0
                }
                navView.selectSerialNumber(index: photographModel.selectIndex)
            }
            let selectArray = configuration.dataArray.compactMap { $0 as? LPhotographModel }.filter { $0.isSelect }
            for (i, item) in selectArray.enumerated() {
                item.selectIndex = i + 1
            }
            imagePickerDelegate?.previewImageState(viewController: self)
            
        }
    }
    
}
