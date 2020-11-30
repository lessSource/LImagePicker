//
//  LPhotographController.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LPhotographController: UIViewController {

    public var albumModel: LPhotoAlbumModel?

    fileprivate var dataArray: Array = [LPhotographModel]()
    
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.itemSize = CGSize(width: (LConstant.screenWidth - 13)/4, height: (LConstant.screenWidth - 13)/4)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
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
    }
    
    
    // MARK: - initView
    // MARK: - initView
    fileprivate func initView() {
        collectionView.register(LPhotographGifCell.self, forCellWithReuseIdentifier: LPhotographGifCell.layerClass)
        
        collectionView.register(LPhotoPickerViewCell.self, forCellWithReuseIdentifier: LPhotoPickerViewCell.l_identifire)
        if let navPicker = imageNavPicker, (navPicker.maxSelectCount > 1 || (navPicker.maxSelectCount == 1 && navPicker.showSelectBtn == true))  {
            view.addSubview(bottomView)
            collectionView.frame = CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar - LConstant.bottomBarHeight)
        }else {
            collectionView.frame = CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar)
        }
        view.addSubview(collectionView)
        view.addSubview(photoAlbumView)
        view.addSubview(navView)
        photoAlbumView.didSelectClosure = { [weak self] albumModel in
            self?.albumModel = albumModel
            self?.initData()
        }
        
    }
    
    
}

extension LPhotographController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}
