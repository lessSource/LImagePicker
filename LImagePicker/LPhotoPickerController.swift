//
//  LPhotoPickerController.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LPhotoPickerController: UIViewController {

    public var pickerModel: LAlbumPickerModel?
    
    fileprivate var animationDelegate: ModelAnimationDelegate?
    
    fileprivate var dataArray = [LMediaResourcesModel]()
    
    fileprivate var isOriginalImage: Bool = false
    
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
        LImagePickerManager.shared.getPhotoAlbumMedia(navVC.allowPickingVideo ? .unknown : .image,duration: navVC.videoSelectMaxDuration ,fetchResult: pickerModel?.fetchResult) { (dataArray) in
            self.dataArray = dataArray
            if let model = self.pickerModel {
                self.navView.titleLabel.text = "\(model.title)(\(dataArray.count))"
            }else {
                self.navView.titleLabel.text = "相机胶卷(\(dataArray.count))"
            }
            self.checkSelectedMediaResources()
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: dataArray.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    // MARK:- 获取选中资源
    fileprivate func checkSelectedMediaResources() {
        guard let navVC = navigationController as? LImagePickerController else { return }
        tabBarView.maxCount = navVC.maxSelectCount
        tabBarView.currentCount = navVC.selectArray.count
        if navVC.selectArray.count == 0 { return }
        dataArray = dataArray.map {
            var model = $0
            model.isSelect = navVC.selectArray.contains(where: {$0 == model})
            return model
        }
    }
    
    fileprivate func didSelectCellButton(_ isSelect: Bool, indexPath: IndexPath) -> Bool {
        guard let navVC = navigationController as? LImagePickerController else { return false }
        if !isSelect {
            if navVC.selectArray.count < navVC.maxSelectCount {
                navVC.selectArray.append(dataArray[indexPath.item])
                dataArray[indexPath.item].isSelect = !isSelect
                tabBarView.currentCount = navVC.selectArray.count
                return true
            }else {
                self.showAlertWithTitle("最多只能选择\(navVC.maxSelectCount)张照片")
                return false
            }
        }else {
            navVC.selectArray.removeAll(where: { $0 == dataArray[indexPath.item] })
            dataArray[indexPath.item].isSelect = !isSelect
            tabBarView.currentCount = navVC.selectArray.count
            return true
        }
    }
}

extension LPhotoPickerController: UICollectionViewDelegate, UICollectionViewDataSource, ShowImageProtocol,UIViewControllerTransitioningDelegate, ImageTabBarViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LImagePickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: LImagePickerCell.l_identifire, for: indexPath) as! LImagePickerCell
        cell.assetModel = dataArray[indexPath.item]
        cell.didSelectButtonClosure = { [weak self] select in
            return self?.didSelectCellButton(select, indexPath: indexPath) == true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navView.allNumber = 1
        guard let cell = collectionView.cellForItem(at: indexPath) as? LImagePickerCell, let navVC = navigationController as? LImagePickerController else { return }
        animationDelegate = ModelAnimationDelegate(contentImage: cell.imageView, superView: collectionView)
        let configuration = ShowImageConfiguration(dataArray: dataArray, currentIndex: indexPath.item,selectCount: navVC.selectArray.count, maxCount: navVC.maxSelectCount, isOriginalImage: isOriginalImage)
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
        guard let navVC = navigationController as? LImagePickerController else { return false }
        if !imageData.isSelect {
            if navVC.selectArray.count < navVC.maxSelectCount {
                navVC.selectArray.append(dataArray[index])
                dataArray[index].isSelect = !imageData.isSelect
                tabBarView.currentCount = navVC.selectArray.count
                collectionView.reloadData()
                return true
            }else {
                return false
            }
        }else {
            navVC.selectArray.removeAll(where: { $0 == dataArray[index] })
            dataArray[index].isSelect = !imageData.isSelect
            tabBarView.currentCount = navVC.selectArray.count
            collectionView.reloadData()
            return true
        }
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
