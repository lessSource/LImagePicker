//
//  LPhotographController.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

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
        bottomView.isHidden = true
        return bottomView
    }()
    
    fileprivate lazy var photoAlbumView: LPhotoAlbumView = {
        let photoAlbumView = LPhotoAlbumView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar))
        photoAlbumView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        photoAlbumView.isHidden = true
        photoAlbumView.delegate = self
        return photoAlbumView
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
        LImagePickerManager.shared.requestsPhotosAuthorization { (authorized) in
            if authorized { self.initData()
            }else { self.placeholderShow() }
            self.bottomView.isHidden = !authorized
            self.lateralSpreadsReturn(isSideslipping: authorized)
        }
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
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if imagePicker.maxImageCount != 1 || imagePicker.showSelectBtn {
            view.addSubview(bottomView)
        }else {
            collectionView.l_height = LConstant.screenHeight - LConstant.navbarAndStatusBar
        }
        view.addSubview(photoAlbumView)
    }
    
    // MARK: - initData
    public func initData() {
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
                if imagePicker.allowTakePicture && albumModel.isAllPhotos {
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
    
    // 提示
    fileprivate func placeholderShow() {
        collectionView.placeholderShow(true) { (promptView) in
            promptView.title("请在iPhone的\'设置-隐私-照片'选项中\r允许\(LApp.appName)访问你的手机相册")
            promptView.imageName("icon_permissions")
            promptView.delegate = self
        }
    }
    
    // 是否能够用侧滑返回
    fileprivate func lateralSpreadsReturn(isSideslipping: Bool) {
        if isSideslipping {
            if let _ = navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
                navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }
        }else {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
    }
    
    fileprivate func collectionViewDidSelectImage(indexPath: IndexPath) {
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if imagePicker.selectArray.count == imagePicker.maxImageCount && !imagePicker.selectArray.contains(dataArray[indexPath.item]) {
            let hub = LProgressHUDView(style: .dark, prompt: "最多能选\(imagePicker.maxImageCount)张照片")
            hub.showPromptInfo(showView: self.view)
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
        bottomView.isConfirmSelect = imagePicker.selectArray.count > 0
        allowSelect = imagePicker.selectArray.count != imagePicker.maxImageCount
        collectionView.reloadData()
    }
    
}

extension LPhotographController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            guard let imagePicker = navigationController as? LImagePickerController else { return cell }
            if imagePicker.maxImageCount != 1 || imagePicker.showSelectBtn {
                cell.selectSerialNumber(index: dataArray[indexPath.row].selectIndex, allowSelect: allowSelect)
                cell.didSelectClosure = { [weak self] in
                    self?.collectionViewDidSelectImage(indexPath: indexPath)
                }
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
        guard let imageNavPicker = navigationController as? LImagePickerController else { return }

        if dataArray[indexPath.item].type == .shooting {
            if allowSelect {
                if imageNavPicker.allowSystemCamera {
                    let pickerVC = UIImagePickerController()
                    pickerVC.sourceType = .camera
                    pickerVC.mediaTypes.append(kUTTypeImage as String)
                    pickerVC.delegate = self
                    if imageNavPicker.allowTakeVideo {
                        pickerVC.mediaTypes.append(kUTTypeMovie as String)
                        pickerVC.videoQuality = .typeHigh
                        pickerVC.videoMaximumDuration = imageNavPicker.videoMaximumDuration
                    }
                    present(pickerVC, animated: true, completion: nil)
                }else {
                    let imagePicker = LImagePickerController(allowPickingVideo: imageNavPicker.allowTakeVideo, maxDuration: imageNavPicker.videoMaximumDuration , delegate: self)
                    present(imagePicker, animated: true, completion: nil)
                }
            }else {
                guard let imageNavPicker = navigationController as? LImagePickerController else { return }
                let hub = LProgressHUDView(style: .dark, prompt: "最多能选\(imageNavPicker.maxImageCount)张照片")
                hub.showPromptInfo(showView: self.view)
            }
            return
        }
        if !imageNavPicker.showSelectBtn && imageNavPicker.maxImageCount == 1 {
            // 剪切
            let editPicturesVC = LEditPicturesController(mediaProtocol: dataArray[indexPath.item].media)
            editPicturesVC.imagePickerDelegate = imagePickerDelegate
            navigationController?.pushViewController(editPicturesVC, animated: true)
            return
        }
        // 显示大图
        guard let cell = collectionView.cellForItem(at: indexPath) as? LPhotographImageCell else { return }
        if imageNavPicker.maxImageCount == imageNavPicker.selectArray.count { return }
        animationDelegate = LPreviewAnimationDelegate(contentImage: cell.imageView, superView: cell.superview)
        let isOffset = imageNavPicker.allowTakePicture && albumModel?.isAllPhotos == true
        var mediaArray: [LPhotographModel] = dataArray
        if isOffset { mediaArray = dataArray.filter { $0.type != .shooting } }
        let imageModel = LPreviewImageModel(currentIndex: isOffset ? indexPath.item - 1 : indexPath.item, dataArray: mediaArray)
        let imagePicker = LImagePickerController(configuration: imageModel, delegate: self, correctionNumber: isOffset ? 1 : 0)
        imagePicker.transitioningDelegate = animationDelegate
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard var fetchResult = albumModel?.fetchResult else { return }
        DispatchQueue.main.sync {
            if let changes = changeInstance.changeDetails(for: fetchResult) {
                fetchResult = changes.fetchResultAfterChanges
                if changes.hasIncrementalChanges {
                    collectionView.performBatchUpdates({
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
                    albumModel?.fetchResult = fetchResult
                    initData()
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeMovie {
            print("视频")
        }else if info[UIImagePickerController.InfoKey.mediaType] as! CFString == kUTTypeImage {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                LImagePickerManager.shared.savePhotoWithImage(image: image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
        
    }

}

extension LPhotographController: LImagePickerProtocol, LImagePickerButtonProtocl, LPromptViewDelegate, LPhotoAlbumViewProtocol {
    
    // MARK: - LImagePickerProtocol
    func previewImageState(viewController: UIViewController, mediaProtocol: LImagePickerMediaProtocol) {
        guard let imagePicker = navigationController as? LImagePickerController, let photographModel = mediaProtocol as? LPhotographModel else { return }
        if photographModel.isSelect {
            imagePicker.selectArray.append(photographModel)
        }else {
            imagePicker.selectArray.removeAll(where: { $0 == photographModel } )
        }
        for (i, item) in imagePicker.selectArray.enumerated() {
            item.selectIndex = i + 1
        }
        bottomView.isConfirmSelect = imagePicker.selectArray.count > 0
        allowSelect = imagePicker.selectArray.count != imagePicker.maxImageCount
        collectionView.reloadData()
    }
    
    
    // MARK: - LImagePickerButtonProtocl
    func buttonView(view: UIView, buttonType: LImagePickerButtonType) {
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if buttonType == .confirm {
            // 不请求UIImage
            if imagePicker.onlyReturnAsset {
                let assets = imagePicker.selectArray.compactMap { $0.media }
                dismiss(animated: true) {
                    self.imagePickerDelegate?.photographSelectImage(viewController: self, photos: [], assets: assets)
                }
                return
            }
                        
            let hud = LProgressHUDView(style: .darkBlur)
            var timeout = false
            hud.timeoutBlock = { [weak self] in
                // 请求超时
                print("请求超时")
                self?.imageQueue.cancelAllOperations()
                timeout = true
            }
            hud.show(timeout: imagePicker.timeout, showView: self.view)
            
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
                    self.dismiss(animated: true) {
                        self.imagePickerDelegate?.photographSelectImage(viewController: self, photos: sucImages, assets: sucAssets)
                    }
                }
                imageQueue.addOperation(operation)
            }
        }else if buttonType == .preview {
            let previeVC = LImagePickerController(configuration: LPreviewImageModel(currentIndex: 0, dataArray: imagePicker.selectArray), delegate: self, isPreview: false)
            animationDelegate = LPreviewAnimationDelegate()
            previeVC.transitioningDelegate = animationDelegate
            present(previeVC, animated: true, completion: nil)
        }else if buttonType == .cancle {
            dismiss(animated: true, completion: nil)
        }else if buttonType == .title {
            if photoAlbumView.isHidden {
                photoAlbumView.showView()
            }else {
                photoAlbumView.hideView()
            }
        }
    }
    
    
    
    // MARK: - LPromptViewDelegate
    func promptViewImageClick(_ promptView: LImagePickerPromptView) {
        let urlStr = UIApplication.openSettingsURLString
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [: ], completionHandler: nil)
        }
    }
    
    // MARK: - LPhotoAlbumViewProtocol
    func photoAlbumView(view: LPhotoAlbumView, albumModel: LPhotoAlbumModel) {
        self.albumModel = albumModel
        initData()
    }
    
    func photoAlbumAnimation(view: LPhotoAlbumView, isShow: Bool) {
        navView.dropDownImageAnimation(isShow: isShow)
    }
    
}
