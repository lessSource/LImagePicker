//
//  LPhotoPickerController.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import CoreServices
import Photos

class LPhotoPickerController: UIViewController {

    public var pickerModel: LAlbumPickerModel?
    
    fileprivate var animationDelegate: ModelAnimationDelegate?
    
    fileprivate var dataArray = [LMediaResourcesModel]()
    // 是否显示原图
    fileprivate var isOriginalImage: Bool = false
    /** 选择类型 */
    fileprivate var selectType: LImagePickerSelectEnum = .default
    /** 是否允许多选视频/图片 默认false */
    fileprivate var allowPickingMultipleVideo: Bool = false
    
    fileprivate lazy var navView: LImageNavView = {
        let navView = LImageNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.titleLabel.text = "相机胶卷"
        navView.backgroundColor = UIColor.white
        return navView
    }()
    
    fileprivate lazy var tabBarView: LImageTabBarView = {
        let barView: LImageTabBarView = LImageTabBarView(frame: CGRect(x: 0, y: self.collectionView.frame.maxY, width: LConstant.screenHeight, height: LConstant.bottomBarHeight))
        barView.backgroundColor = UIColor.white
        barView.delegate = self
        return barView
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
         let flowLayout = UICollectionViewFlowLayout()
         flowLayout.minimumLineSpacing = 1
         flowLayout.minimumInteritemSpacing = 1
         flowLayout.itemSize = CGSize(width: (LConstant.screenWidth - 13)/4, height: (LConstant.screenWidth - 13)/4)
         flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
         
         let collectionView = UICollectionView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar - LConstant.bottomBarHeight), collectionViewLayout: flowLayout)
         collectionView.delegate = self
         collectionView.dataSource = self
         collectionView.backgroundColor = UIColor.white
         return collectionView
     }()
    
    deinit {
        print(self, "++++++释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(navView)
        view.addSubview(collectionView)
        view.addSubview(tabBarView)
        collectionView.register(LImagePickerCell.self, forCellWithReuseIdentifier: LImagePickerCell.l_identifire)
        initData()

    }
    
    // MARK:- initData
    func initData() {
        guard let navVC = navigationController as? LImagePickerController else { return }
        allowPickingMultipleVideo = navVC.allowPickingMultipleVideo
        if allowPickingMultipleVideo || navVC.selectArray.count == 0 || navVC.allowPickingVideo {
            selectType = .default
        }else {
            if navVC.selectArray[0].dateEnum == .video {
                selectType = .video
            }else {
                selectType = .image
            }
        }
        
        LImagePickerManager.shared.getPhotoAlbumMedia(navVC.allowPickingVideo ? .unknown : .image,duration: navVC.videoSelectMaxDuration ,fetchResult: pickerModel?.fetchResult) { (dataArray) in
            self.dataArray = dataArray
            if let model = self.pickerModel {
                self.navView.titleLabel.text = "\(model.title)(\(dataArray.count))"
            }else {
                self.navView.titleLabel.text = "相机胶卷(\(dataArray.count))"
            }
            self.checkSelectedMediaResources()
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: (navVC.allowTakePicture || navVC.allowPickingVideo) ? dataArray.count : dataArray.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    // MARK:- 获取选中资源
    fileprivate func checkSelectedMediaResources() {
        guard let navVC = navigationController as? LImagePickerController else { return }
        tabBarView.maxCount = navVC.maxSelectCount
        tabBarView.currentCount = navVC.selectArray.count
        dataArray = dataArray.map {
            var model = $0
            model.isSelect = navVC.selectArray.contains(where: {$0 == model})
            return model
        }
    }
    
    // MARK:- 选择
    fileprivate func resourcesSelect(viewController: UIViewController,isSelect: Bool, selectIndex: Int) -> Bool {
        guard let navVC = navigationController as? LImagePickerController else { return false }
        if !isSelect {
            if navVC.selectArray.count < navVC.maxSelectCount {
                navVC.selectArray.append(dataArray[selectIndex])
                dataArray[selectIndex].isSelect = !isSelect
                tabBarView.currentCount = navVC.selectArray.count
                if navVC.selectArray.count == 1 && !allowPickingMultipleVideo && navVC.allowPickingVideo {
                    if navVC.selectArray[0].dateEnum == .video {
                        selectType = .video
                    }else {
                        selectType = .image
                    }
                    collectionView.reloadData()
                }
                return true
            }else {
                viewController.showAlertWithTitle("最多只能选择\(navVC.maxSelectCount)张照片")
                return false
            }
        }else {
            navVC.selectArray.removeAll(where: { $0 == dataArray[selectIndex] })
            dataArray[selectIndex].isSelect = !isSelect
            tabBarView.currentCount = navVC.selectArray.count
            if navVC.selectArray.count == 0 && !allowPickingMultipleVideo && navVC.allowPickingVideo {
                selectType = .default
                collectionView.reloadData()
            }
            return true
        }
    }
    
}

extension LPhotoPickerController: UICollectionViewDelegate, UICollectionViewDataSource, ShowImageProtocol,UIViewControllerTransitioningDelegate, ImageTabBarViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let navVC = navigationController as? LImagePickerController else { return 0 }
        
        return dataArray.count + ((navVC.allowPickingVideo || navVC.allowTakePicture) ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LImagePickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: LImagePickerCell.l_identifire, for: indexPath) as! LImagePickerCell
        
        if indexPath.item == dataArray.count {
            cell.backgroundColor = UIColor.red
            cell.selectImageView.isHidden = true
            cell.selectButton.isUserInteractionEnabled = false
            return cell
        }
        
        switch selectType {
        case .default:
            cell.selectImageView.isHidden = false
            cell.selectButton.isUserInteractionEnabled = true
        case .image:
            if dataArray[indexPath.item].dateEnum == .video {
                cell.selectImageView.isHidden = true
                cell.selectButton.isUserInteractionEnabled = false
            }else {
                cell.selectImageView.isHidden = false
                cell.selectButton.isUserInteractionEnabled = true
            }
        case .video:
            if dataArray[indexPath.item].dateEnum != .video {
                cell.selectImageView.isHidden = true
                cell.selectButton.isUserInteractionEnabled = false
            }else {
                cell.selectImageView.isHidden = false
                cell.selectButton.isUserInteractionEnabled = true
            }
        }
        
        cell.assetModel = dataArray[indexPath.item]
        cell.didSelectButtonClosure = { [weak self] select in
            guard let `self` = self else { return false }
            return self.resourcesSelect(viewController: self, isSelect: select, selectIndex: indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        navView.allNumber = 1
        guard let cell = collectionView.cellForItem(at: indexPath) as? LImagePickerCell, let navVC = navigationController as? LImagePickerController else { return }
        if indexPath.item == dataArray.count {
            var mediaTypes = [String]()
            if navVC.allowTakeVideo {
                mediaTypes.append(kUTTypeMovie as String)
            }
            if navVC.allowTakePicture {
                mediaTypes.append(kUTTypeImage as String)
            }

            showAlertController(preferredStyle: .actionSheet, actionTitles: ["相机","取消"]) { (row) in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.mediaTypes = mediaTypes
                if navVC.allowPickingVideo {
                    picker.videoMaximumDuration = navVC.videoMaximumDuration
                }
                picker.delegate = self
                picker.cameraDevice = .rear
                self.present(picker, animated: true, completion: nil)
            }
            
            return
        }
        
        animationDelegate = ModelAnimationDelegate(contentImage: cell.imageView, superView: collectionView)
        let configuration = ShowImageConfiguration(dataArray: dataArray, currentIndex: indexPath.item,selectCount: navVC.selectArray.count, maxCount: navVC.maxSelectCount, isOriginalImage: isOriginalImage, selectType: selectType)
        showImage(configuration, delegate: animationDelegate, formVC: self)
    }
    
    // ImageTabBarViewDelegate
    func imageTabBarViewButton(_ buttonType: ImageTabBarButtonType) {
        guard let navVC = navigationController as? LImagePickerController else { return }
        if buttonType == .preview {
            animationDelegate = ModelAnimationDelegate()
            showImage(ShowImageConfiguration(dataArray: navVC.selectArray, currentIndex: 0, maxCount: navVC.maxSelectCount), delegate: animationDelegate)
        }else if buttonType == .complete {
            LImagePickerManager.shared.getSelectPhotoWithAsset(navVC.selectArray, isOriginal: isOriginalImage) { (imageArr, assetArr) in
                navVC.imageDelegete?.imagePickerController(navVC, photos: imageArr, asset: assetArr)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension LPhotoPickerController: ShowImageVCDelegate {
    
    func showImageDidSelect(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool {
        let select = resourcesSelect(viewController: viewController, isSelect: imageData.isSelect, selectIndex: index)
        collectionView.reloadData()
        return select
    }
    
    func showImageGetOriginalImage(_ viewController: ShowImageViewController, isOriginal: Bool) {
        isOriginalImage = isOriginal
    }
    
    func showImageDidDisappear(_ viewController: ShowImageViewController) {
        print("老子走了")
    }
    
    func showImageDidComplete(_ viewController: ShowImageViewController) {
        guard let navVC = navigationController as? LImagePickerController else { return }
        LImagePickerManager.shared.getSelectPhotoWithAsset(navVC.selectArray, isOriginal: isOriginalImage) { (imageArr, assetArr) in
            navVC.imageDelegete?.imagePickerController(navVC, photos: imageArr, asset: assetArr)
            self.dismiss(animated: true, completion: nil)
        }
    }
}


extension LPhotoPickerController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
            
        }else if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print("sds")
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { (boo, error) in
                if boo {
                    let option = PHFetchOptions()
                    option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let result = PHAsset.fetchAssets(with: .video, options: option)
                    let phasset = result.firstObject
                    if let imageAsset = phasset {
                        let model = LMediaResourcesModel(dataProtocol: imageAsset, dateEnum: .video, videoTime: LImagePickerManager.shared.getNewTimeFromDurationSecond(duration: Int(imageAsset.duration)))
                        self.dataArray.append(model)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                    }
                    
                }
            }
            
            

        }
        
        
        switch mediaType {
        case kUTTypeMovie:
            print("kUTTypeMovie")
        case kUTTypeImage:
            print("kUTTypeImage")
            
        default: break
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: AnyObject) {
        let option = PHFetchOptions()
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: .image, options: option)
        let phasset = result.firstObject
        if let imageAsset = phasset {
            let model = LMediaResourcesModel(dataProtocol: imageAsset, dateEnum: .image)
            dataArray.append(model)
            collectionView.reloadData()
        }
    }
}
