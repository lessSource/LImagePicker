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
import LPublicImageParameter
import LImageShow

class LPhotoPickerController: UIViewController {

    fileprivate let imageManager = PHCachingImageManager()
    
    public var pickerModel: LAlbumPickerModel?
        
    fileprivate var dataArray = [LMediaResourcesModel]()
    /** 是否显示原图 */
    fileprivate var isOriginalImage: Bool = false
    /** 选择类型 */
    fileprivate var selectType: LImagePickerSelectEnum = .default
    /** 是否允许多选视频/图片 默认false */
    fileprivate var allowPickingMultipleVideo: Bool = false
    
    fileprivate lazy var navView: LImageNavView = {
        let navView = LImageNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.titleLabel.text = "相机胶卷"
        return navView
    }()
    
    fileprivate lazy var tabBarView: LImageTabBarView = {
        let barView: LImageTabBarView = LImageTabBarView(frame: CGRect(x: 0, y: self.collectionView.frame.maxY, width: LConstant.screenHeight, height: LConstant.bottomBarHeight))
        barView.backgroundColor = UIColor.lBackWhite
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
         collectionView.backgroundColor = UIColor.lBackWhite
         return collectionView
     }()
    
    deinit {
        print(self, "++++++释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lBackWhite
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
            if navVC.selectArray[0].dataEnum == .video {
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
        DispatchQueue.global().async {
            self.dataArray = self.dataArray.map {
                var model = $0
                model.isSelect = navVC.selectArray.contains(where: {$0 == model})
                return model
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
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
                    if navVC.selectArray[0].dataEnum == .video {
                        selectType = .video
                    }else {
                        selectType = .image
                    }
                    collectionView.reloadData()
                }
                return true
            }else {
                viewController.showAlertController(nil, message: "最多只能选择\(navVC.maxSelectCount)张照片", preferredStyle: .actionSheet, actionTitles: ["确认"], complete: nil)
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

extension LPhotoPickerController: UICollectionViewDelegate, UICollectionViewDataSource,UIViewControllerTransitioningDelegate, ImageTabBarViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let navVC = navigationController as? LImagePickerController else { return 0 }
        return dataArray.count + ((navVC.allowPickingVideo || navVC.allowTakePicture) ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LImagePickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: LImagePickerCell.l_identifire, for: indexPath) as! LImagePickerCell
        
        if indexPath.item == dataArray.count {
            cell.selectImageView.isHidden = true
            cell.selectButton.isUserInteractionEnabled = false
            cell.imageView.image = UIImage.imageNameFromBundle("icon_addPhoto")
            cell.imageView.contentMode = .center
            cell.backView.isHidden = true
            return cell
        }
        
        switch selectType {
        case .default:
            cell.selectImageView.isHidden = false
            cell.selectButton.isUserInteractionEnabled = true
        case .image:
            cell.backView.isHidden = true
            if dataArray[indexPath.item].dataEnum == .video {
                cell.selectImageView.isHidden = true
                cell.selectButton.isUserInteractionEnabled = false
            }else {
                cell.selectImageView.isHidden = false
                cell.selectButton.isUserInteractionEnabled = true
            }
        case .video:
            cell.backView.isHidden = false
            if dataArray[indexPath.item].dataEnum != .video {
                cell.selectImageView.isHidden = true
                cell.selectButton.isUserInteractionEnabled = false
            }else {
                cell.selectImageView.isHidden = false
                cell.selectButton.isUserInteractionEnabled = true
            }
        }
        cell.assetModel = dataArray[indexPath.item]
        print(indexPath.item)
        cell.didSelectButtonClosure = { [weak self] select in
            guard let `self` = self else { return false }
            return self.resourcesSelect(viewController: self, isSelect: select, selectIndex: indexPath.item)
        }
        return cell
    }
    

    func imageTabBarViewButton(_ buttonType: ImageTabBarButtonType) {
        guard let navVC = navigationController as? LImagePickerController else { return }
        
        switch buttonType {
        case .preview: break
        case .complete:
            LImagePickerManager.shared.getSelectPhotoWithAsset(navVC.selectArray, isOriginal: isOriginalImage) { (imageArr, assetArr) in
                navVC.imageDelegete?.imagePickerController(navVC, photos: imageArr, asset: assetArr)
                self.dismiss(animated: true, completion: nil)
            }
        case .edit: break
        }
    }
    
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        return false
    }
}


