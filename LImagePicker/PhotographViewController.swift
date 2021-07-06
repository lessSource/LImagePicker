//
//  PhotographViewController.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotographViewController: UIViewController {

    public weak var imagePickerDelegate: ImagePhotographProtocol?
    
    public var albumModel: PhotoAlbumModel?

    fileprivate var dataArray: [PhotographModel] = []
    
    /** 是否允许选择 */
    fileprivate var allowSelect: Bool = true
    
    fileprivate var imageQueue: OperationQueue = OperationQueue()

    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar), collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.backColor
        collection.showsVerticalScrollIndicator = false
        collection.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        return collection
    }()
    
    fileprivate lazy var navView: PhotographNavView = {
        let navView = PhotographNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.backgroundColor = UIColor.white
        return navView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PHPhotoLibrary.shared().register(self)
        initView()
        ImagePickerManager.shared.requestsPhotosAuthorization { authorized in
            if authorized {
                self.initData()
                if #available(iOS 14, *) {
//                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
                } else {
                    // Fallback on earlier versions
                }
            }else { self.placeholderShow() }
            self.lateralSpreadsReturn(isSideslipping: authorized)
        }
    }
    
    deinit {
        print(self, "++++++释放")
        NotificationCenter.default.removeObserver(self)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

extension PhotographViewController {
    
    // MARK:- initView
    fileprivate func initView() {
        collectionView.register(PhotographImageCell.self, forCellWithReuseIdentifier: PhotographImageCell.l_identifire)
        collectionView.register(PhotographVideoCell.self, forCellWithReuseIdentifier: PhotographVideoCell.l_identifire)
        collectionView.register(PhotographGifCell.self, forCellWithReuseIdentifier: PhotographGifCell.l_identifire)
        collectionView.register(PhotographLivePhotoCell.self, forCellWithReuseIdentifier: PhotographLivePhotoCell.l_identifire)
        collectionView.register(PhotographShootingCell.self, forCellWithReuseIdentifier: PhotographShootingCell.l_identifire)
        view.addSubview(collectionView)
        view.addSubview(navView)
        if let imagePickerVC = navigationController as? ImagePickerController {
            if imagePickerVC.configuration.photoAlbumType == .dropDown {
                navView.cancleButton.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_close_white"), for: .normal)
            }else {
                navView.cancleButton.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_back_white"), for: .normal)
            }
        }
        
        imagePickerDelegate?.imagePickerCustomPhotograph(navView: navView)
        initData()
    }
    
    // MARK:- initData
    fileprivate func initData() {
        guard let `albumModel` = albumModel else {
            ImagePickerManager.shared.getPhotoAlbumResources(.image) { [weak self] model in
                self?.albumModel = model
                self?.initData()
            }
            return
        }
        
        navView.titleLabel.text = albumModel.title
        
        ImagePickerManager.shared.getAssetsFromFetchResult(albumModel.fetchResult) { [weak self] array in
            guard let `self` = self, let imagePicker = navigationController as? ImagePickerController else { return }
            self.dataArray = array
            for item in imagePicker.selectArray {
                if let index = array.firstIndex(of: item) {
                    self.dataArray[index] = item
                }
            }
            
            let configuration = imagePicker.configuration
            if (configuration.allowTakeVideo || configuration.allowTakePicture) && albumModel.isAllPhotos {
                let photographModel = PhotographModel(media: PHAsset(), type: .shooting)
                if configuration.sortAscendingByModificationDate {
                    self.dataArray.insert(photographModel, at: 0)
                }else {
                    self.dataArray.append(photographModel)
                }
            }
            self.allowSelect = imagePicker.selectArray.count != imagePicker.maxCount
            self.collectionView.reloadData()
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
    
    fileprivate func collectionViewDidSelectImage(indexPath: IndexPath) -> Bool {
        guard let imagePicker = navigationController as? ImagePickerController else { return false }
        
        if imagePicker.selectArray.count == imagePicker.maxCount && !imagePicker.selectArray.contains(dataArray[indexPath.item]) {
            let hub = LProgressHUDView(style: .dark, prompt: "最多能选\(imagePicker.maxCount)张照片")
            hub.showPromptInfo(showView: self.view)
            return false
        }
        if dataArray[indexPath.row].isSelect {
            imagePicker.selectArray.remove(at: dataArray[indexPath.item].selectIndex - 1)
            dataArray[indexPath.row].selectIndex = 0
            for (i, item) in imagePicker.selectArray.enumerated() {
                item.selectIndex = i + 1
            }
        }else {
            imagePicker.selectArray.append(dataArray[indexPath.item])
            dataArray[indexPath.item].selectIndex = imagePicker.selectArray.count
        }
        allowSelect = imagePicker.selectArray.count != imagePicker.maxCount
        collectionView.reloadData()
        return true
    }
    
}


extension PhotographViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataArray[indexPath.item].type {
        case .livePhoto:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotographLivePhotoCell.l_identifire, for: indexPath) as! PhotographShootingCell
            return cell
        case .gif:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotographGifCell.l_identifire, for: indexPath) as! PhotographGifCell
            return cell
        case .video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotographVideoCell.l_identifire, for: indexPath) as! PhotographVideoCell
            return cell
        case .shooting:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotographShootingCell.l_identifire, for: indexPath) as! PhotographShootingCell
            cell.selectSerialNumber(allowSelect: allowSelect)
            return cell
        case .photo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotographImageCell.l_identifire, for: indexPath) as! PhotographImageCell
            cell.loadingResourcesModel(dataArray[indexPath.row])
            if let imagePicker = navigationController as? ImagePickerController {
                if imagePicker.maxCount != 1 || imagePicker.configuration.showSelectBtn {
                    cell.selectSerialNumber(index: dataArray[indexPath.row].selectIndex, allowSelect: allowSelect)
                    cell.didSelectClosure =  { [weak self] in
                        guard let `self` = self else { return false }
                        return self.collectionViewDidSelectImage(indexPath: indexPath)
                    }
                }
            }
            cell.selectSerialNumber(index: dataArray[indexPath.item].selectIndex, allowSelect: allowSelect)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (LConstant.screenWidth - 7)/4, height: (LConstant.screenWidth - 7)/4)
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
        guard let imagePicker = navigationController as? ImagePickerController else { return }

        if imagePicker.configuration.onlyReturnAsset {
            
        }
        
        
    }
    
}

extension PhotographViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    
    
}

extension PhotographViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
}

extension PhotographViewController: LPromptViewDelegate {
    
    func promptViewImageClick(_ promptView: LImagePickerPromptView) {
        let urlStr = UIApplication.openSettingsURLString
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [: ], completionHandler: nil)
        }
    }
}
