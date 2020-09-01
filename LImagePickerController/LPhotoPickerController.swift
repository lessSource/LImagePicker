//
//  LPhotoPickerController.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LPhotoPickerController: UIViewController {

    fileprivate var dataArray: Array = [PHAsset]()
    
    fileprivate var delegate: ModelAnimationDelegate?

    
    fileprivate lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.itemSize = CGSize(width: (LConstant.screenWidth - 13)/4, height: (LConstant.screenWidth - 13)/4)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight), collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = UIColor.lBackGround
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.register(LPhotoPickerViewCell.self, forCellWithReuseIdentifier: LPhotoPickerViewCell.l_identifire)
        view.addSubview(collectionView)
        
        fetchAssetModels()
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension LPhotoPickerController {
    
    func fetchAssetModels() {
        LImagePickerManager.shared.getPhotoAlbumResources(.image) { (assetsFetchResult) in
            
            assetsFetchResult.enumerateObjects { (mediaAsset, indeo, stop) in
                self.dataArray.append(mediaAsset)
            }
            
            self.collectionView.reloadData()
//            self.collectionView.scrollToItem(at: IndexPath(item: self.dataArray.count, section: 0), at: .bottom, animated: false)
        }
        
    }
    
}


extension LPhotoPickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LPhotoPickerViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotoPickerViewCell.l_identifire, for: indexPath) as! LPhotoPickerViewCell
        cell.backgroundColor = UIColor.red
        cell.photoAsset(asset: dataArray[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LPhotoPickerViewCell else {
            return
        }
        
        
        delegate = ModelAnimationDelegate(contentImage: cell.imageView, superView: cell)

        
        let showImageVC = LImageShowViewController(configuration: LImagePickerConfiguration())
//        showImageVC.t
        showImageVC.transitioningDelegate = delegate
        showImageVC.modalPresentationStyle = .custom
        showImageVC.modalTransitionStyle = .crossDissolve
        present(showImageVC, animated: true, completion: nil)
        
    }
    

}
