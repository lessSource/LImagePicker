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
    
    public var albumModel: LPhotoAlbumModel?
    
    fileprivate var dataArray: Array = [LPhotographModel]()
    
    fileprivate var animationDelegate = LPreviewAnimationDelegate()
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        initData()
    }
    
    // MARK: - initView
    fileprivate func initView() {
        collectionView.register(LPhotographGifCell.self, forCellWithReuseIdentifier: LPhotographGifCell.l_identifire)
        collectionView.register(LPhotographImageCell.self, forCellWithReuseIdentifier: LPhotographImageCell.l_identifire)
        collectionView.register(LPhotographVideoCell.self, forCellWithReuseIdentifier: LPhotographVideoCell.l_identifire)
        collectionView.register(LPhotographLivePhotoCell.self, forCellWithReuseIdentifier: LPhotographLivePhotoCell.l_identifire)
        view.addSubview(collectionView)
    }
    
    // MARK: - initData
    fileprivate func initData() {
        if let albumModel = albumModel {
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
    
    
}

extension LPhotographController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographImageCell.l_identifire, for: indexPath) as! LPhotographImageCell
            cell.imageView.backgroundColor = UIColor.white
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographImageCell.l_identifire, for: indexPath) as! LPhotographImageCell
            cell.loadingResourcesModel(dataArray[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (LConstant.screenWidth - 13)/4, height: (LConstant.screenWidth - 13)/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataArray[indexPath.item].type == .shooting {
            let imagePicker = LImagePickerController(allowPickingVideo: false, delegate: nil)
            present(imagePicker, animated: true, completion: nil)
            return
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? LPhotographImageCell else { return }
        animationDelegate = LPreviewAnimationDelegate(contentImage: cell.imageView, superView: cell)
        let mediaArray = dataArray.compactMap { $0.media }
        let imageModel = LPreviewImageModel(currentIndex: indexPath.item, dataArray: mediaArray)
        let imagePicker = LImagePickerController(configuration: imageModel, delegate: nil)
        imagePicker.transitioningDelegate = animationDelegate
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}
