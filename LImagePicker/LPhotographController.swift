//
//  LPhotographController.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LPhotographController: UIViewController {
    
    public weak var imagePickerDelegate: LImagePickerProtocol?
    
    public var albumModel: LPhotoAlbumModel?
    
    fileprivate var dataArray: Array = [LPhotographModel]()
    
    fileprivate var animationDelegate = LPreviewAnimationDelegate()
    
    fileprivate var allowSelect: Bool = true
    
    fileprivate var imageQueue: OperationQueue = OperationQueue()
    
    fileprivate lazy var navView: LImagePickerNavView = {
        let navView = LImagePickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.backgroundColor = UIColor.navViewBackColor
        navView.cancleImageStr = "icon_close"
        navView.delegate = self
        return navView
    }()
    
    fileprivate lazy var bottomView: LImagePickerBottomView = {
        let bottomView = LImagePickerBottomView(frame: CGRect(x: 0, y: LConstant.screenHeight - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        bottomView.backgroundColor = UIColor.bottomViewBackColor
        bottomView.delegate = self
        return bottomView
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar - LConstant.bottomBarHeight), collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.backColor
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    deinit {
        print(self, "++++++释放")
        NotificationCenter.default.removeObserver(self)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        PHPhotoLibrary.shared().register(self)
        initView()
        initData()
    }
    
    // MARK: - initView
    fileprivate func initView() {
        collectionView.register(LPhotographGifCell.self, forCellWithReuseIdentifier: LPhotographGifCell.l_identifire)
        collectionView.register(LPhotographImageCell.self, forCellWithReuseIdentifier: LPhotographImageCell.l_identifire)
        collectionView.register(LPhotographVideoCell.self, forCellWithReuseIdentifier: LPhotographVideoCell.l_identifire)
        collectionView.register(LPhotographLivePhotoCell.self, forCellWithReuseIdentifier: LPhotographLivePhotoCell.l_identifire)
        collectionView.register(LPhotographShootingCell.self, forCellWithReuseIdentifier: LPhotographShootingCell.l_identifire)
        view.addSubview(collectionView)
        view.addSubview(navView)
        view.addSubview(bottomView)
    }
    
    // MARK: - initData
    fileprivate func initData() {
        if let albumModel = albumModel {
            navView.title = albumModel.title
            LImagePickerManager.shared.getAssetsFromFetchResult(albumModel.fetchResult) { [weak self] (array) in
                guard let `self` = self, let imagePicker = navigationController as? LImagePickerController else { return }
                self.dataArray = array
                for item in imagePicker.selectArray {
                    if let index = array.firstIndex(of: item) {
                        self.dataArray[index] = item
                    }
                }
                if imagePicker.allowTakePicture {
                    let photographModel = LPhotographModel(media: PHAsset(), type: .shooting, isSelect: false, selectIndex: 0)
                    self.dataArray.insert(photographModel, at: 0)
                }
                self.collectionView.reloadData()
            }
        }else {
            LImagePickerManager.shared.getPhotoAlbumResources(.image) { [weak self] (albumModel) in
                guard let `self` = self else { return }
                self.albumModel = albumModel
                self.initData()
            }
        }
    }
    
    fileprivate func collectionViewDidSelectImage(indexPath: IndexPath) {
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if imagePicker.selectArray.count == imagePicker.maxImageCount && !imagePicker.selectArray.contains(dataArray[indexPath.item]) {
            print("最多能选\(imagePicker.maxImageCount)张照片")
            return
        }
        dataArray[indexPath.item].isSelect = !dataArray[indexPath.item].isSelect
        if dataArray[indexPath.item].isSelect {
            imagePicker.selectArray.append(dataArray[indexPath.item])
            dataArray[indexPath.item].selectIndex = imagePicker.selectArray.count
        }else {
            imagePicker.selectArray.remove(at: dataArray[indexPath.item].selectIndex - 1)
            dataArray[indexPath.item].selectIndex = 0
            for (i, item) in imagePicker.selectArray.enumerated() {
                item.selectIndex = i + 1
            }
        }
        allowSelect = imagePicker.selectArray.count != imagePicker.maxImageCount
        collectionView.reloadData()
    }
    
    
}

extension LPhotographController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LImagePickerProtocol, PHPhotoLibraryChangeObserver, LImagePickerButtonProtocl {
    
    // MARK: -  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataArray[indexPath.row].type {
        case .livePhoto:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographLivePhotoCell.l_identifire, for: indexPath) as! LPhotographLivePhotoCell
            return cell
        case .photoGif:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographGifCell.l_identifire, for: indexPath) as! LPhotographGifCell
            return cell
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographGifCell.l_identifire, for: indexPath) as! LPhotographGifCell
            return cell
        case .shooting:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographShootingCell.l_identifire, for: indexPath) as! LPhotographShootingCell
            cell.selectSerialNumber(allowSelect: allowSelect)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographImageCell.l_identifire, for: indexPath) as! LPhotographImageCell
            cell.loadingResourcesModel(dataArray[indexPath.row])
            cell.selectSerialNumber(index: dataArray[indexPath.row].selectIndex, allowSelect: allowSelect)
            cell.didSelectClosure = { [weak self] in
                self?.collectionViewDidSelectImage(indexPath: indexPath)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (LConstant.screenWidth - 3)/4, height: (LConstant.screenWidth - 3)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataArray[indexPath.item].type == .shooting {
            if allowSelect {
                let imagePicker = LImagePickerController(allowPickingVideo: false, delegate: self)
                present(imagePicker, animated: true, completion: nil)
            }else {
                print("图片已选择完")
            }
            return
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? LPhotographImageCell else { return }
        animationDelegate = LPreviewAnimationDelegate(contentImage: cell.imageView, superView: cell)
        let mediaArray = dataArray.compactMap { $0.media }
        let imageModel = LPreviewImageModel(currentIndex: indexPath.item, dataArray: mediaArray)
        let imagePicker = LImagePickerController(configuration: imageModel, delegate: self)
        imagePicker.transitioningDelegate = animationDelegate
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - LImagePickerProtocol
    func takingPicturesSaveImage(viewController: UIViewController, asset: PHAsset) {
        dataArray.insert(LPhotographModel(media: asset, type: .photo, isSelect: false, selectIndex: 0), at: 1)
        collectionView.reloadData()
    }
    
    func previewImageState(viewController: UIViewController) {
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        imagePicker.selectArray = imagePicker.selectArray.filter { $0.isSelect }
        collectionView.reloadData()
    }
    
    
    // MARK: - LImagePickerBottomProtocl
    func buttonView(view: UIView, buttonType: LImagePickerButtonType) {
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if buttonType == .confirm {
            let hud = LProgressHUDView(style: .darkBlur)
            var timeout = false
            hud.timeoutBlock = { [weak self] in
                // 请求超时
                print("请求超时")
                self?.imageQueue.cancelAllOperations()
                timeout = true
            }
            hud.show(timeout: imagePicker.timeout, showView: self.view)
            
            // 不请求UIimage
            if imagePicker.onlyReturnAsset {
                hud.hide()
                let assets = imagePicker.selectArray.compactMap { $0.media }
                imagePickerDelegate?.photographSelectImage(viewController: self, photos: [], assets: assets)
                dismiss(animated: true, completion: nil)
                return
            }
            
            var images: [UIImage?] = Array(repeating: nil, count: imagePicker.selectArray.count)
            var assets: [PHAsset?] = Array(repeating: nil, count: imagePicker.selectArray.count)
            var errorAssets: [PHAsset] = []
            var errorIndexs: [Int] = []
            
            var sucCount = 0
            let totalCount = imagePicker.selectArray.count
            for (i, item) in imagePicker.selectArray.enumerated() {
                let operation = LImagePickerOperation(photographModel: item, isOriginal: true) { [weak self] (image, asset) in
                    guard !timeout, let `self` = self else { return }
                    
                    sucCount += 1
                    if let image = image {
                        images[i] = image
                        assets[i] = asset ?? item.media
                    }else {
                        errorAssets[i] = item.media
                        errorIndexs[i] = i
                    }
                    guard sucCount >= totalCount else { return }
                    let sucImages = images.compactMap { $0 }
                    let sucAssets = assets.compactMap { $0 }
                    hud.hide()
                    self.imagePickerDelegate?.photographSelectImage(viewController: self, photos: sucImages, assets: sucAssets)
                    self.dismiss(animated: true, completion: nil)
                }
                imageQueue.addOperation(operation)
            }
        }else if buttonType == .preview {
            let previeVC = LImagePickerController(configuration: LPreviewImageModel(currentIndex: 0, dataArray: imagePicker.selectArray), delegate: self)
            animationDelegate = LPreviewAnimationDelegate()
            previeVC.transitioningDelegate = animationDelegate
            present(previeVC, animated: true, completion: nil)
        }else if buttonType == .cancle {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard var fetchResult = albumModel?.fetchResult else { return }
        DispatchQueue.main.sync {
            if let changes = changeInstance.changeDetails(for: fetchResult) {
                // Keep the new fetch result for future use.
                fetchResult = changes.fetchResultAfterChanges
                if changes.hasIncrementalChanges {
                    // If there are incremental diffs, animate them in the collection view.
                    collectionView.performBatchUpdates({
                        // For indexes to make sense, updates must be in this order:
                        // delete, insert, reload, move
                        // The first is the take picture button
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            let deleteIndexs = removed.map { IndexPath(item: $0 + 1, section: 0) }
                            for index in deleteIndexs {
                                dataArray.remove(at: index.item)
                            }
                            collectionView.deleteItems(at: deleteIndexs)
                        }
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            let insertIndexs = inserted.map { IndexPath(item: $0 + 1, section: 0) }
                            for index in insertIndexs {
                                let photographModel = LPhotographModel(media: fetchResult.object(at: index.item - 1), type: .photo, isSelect: false, selectIndex: 0)
                                dataArray.insert(photographModel, at: index.item)
                            }
                            collectionView.insertItems(at: insertIndexs)
                        }
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            let changedIndexs = changed.map { IndexPath(item: $0 + 1, section: 0) }
                            for index in changedIndexs {
                                let photographModel = LPhotographModel(media: fetchResult.object(at: index.item - 1), type: .photo, isSelect: false, selectIndex: 0)
                                dataArray[index.item] = photographModel
                            }
                            collectionView.reloadItems(at: changedIndexs)
                        }
                        changes.enumerateMoves { fromIndex, toIndex in
                            self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                         to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                } else {
                    // Reload the collection view if incremental diffs are not available.
                    collectionView.reloadData()
                }
            }
        }
    }
    
}
