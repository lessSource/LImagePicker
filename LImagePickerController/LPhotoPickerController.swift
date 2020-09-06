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

    public var albumMode: LAlbumPickerModel = LAlbumPickerModel()
    
    fileprivate var dataArray: Array = [PHAsset]()
    
    fileprivate var delegate: ModelAnimationDelegate?

    fileprivate lazy var navView: LImagePickerNavView = {
        let view = LImagePickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        view.backgroundColor = UIColor.lBackGround
        view.isBackHidden = false
        return view
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.itemSize = CGSize(width: (LConstant.screenWidth - 13)/4, height: (LConstant.screenWidth - 13)/4)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        let collection = UICollectionView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar), collectionViewLayout: flowLayout)
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
        view.addSubview(navView)
        
        fetchAssetModels()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatusBarOrientationNotification(_ :)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        
    }
    
    deinit {
        print(self, "++++++释放")
        NotificationCenter.default.removeObserver(self)
    }
    

    
}

@objc
extension LPhotoPickerController {
    
    fileprivate func didChangeStatusBarOrientationNotification(_ orientationNotification: Notification) {
        let deviceOrientation = UIDevice.current.orientation
        

        navView.frame = CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar)
        collectionView.frame = CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar)
        
        
        switch deviceOrientation {
        case .faceUp:
            print("屏幕超上平躺")
        case .faceDown:
            print("屏幕超下平躺")
        case .unknown:
            print("未知方向")
        case .landscapeLeft:
            print("屏幕向左横置")
        case .landscapeRight:
            print("屏幕向右横置")
        case .portrait:
            print("屏幕直立")
        case .portraitUpsideDown:
            print("屏幕直立，上下颠倒")
        default:
            print("无法识别")
        }
        
        print(UIDevice.current.orientation)
    }
    
}

extension LPhotoPickerController {
    
    func fetchAssetModels() {
        LImagePickerManager.shared.getPhotoAlbumResources(.image) { (assetsFetchResult) in
            
            assetsFetchResult.enumerateObjects { (mediaAsset, indeo, stop) in
                self.dataArray.append(mediaAsset)
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: self.dataArray.count, section: 0), at: .bottom, animated: false)
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
        
        
        delegate = ModelAnimationDelegate(contentImage: cell.imageView, superView: cell.superview)

        let showImageVC = LImageShowViewController(configuration: LImagePickerConfiguration(currentIndex: indexPath.item, dataArray: dataArray))
        showImageVC.transitioningDelegate = delegate
        showImageVC.modalPresentationStyle = .custom
        showImageVC.modalTransitionStyle = .crossDissolve
        present(showImageVC, animated: true, completion: nil)
        
    }
    

}


extension LPhotoPickerController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        completeButtonClick()
    }
    
    fileprivate func completeButtonClick() {
//        LImagePickerManager.shared.getPhotoWithAsset(<#T##asset: PHAsset##PHAsset#>, photoWidth: <#T##CGFloat#>, completion: <#T##(UIImage, Dictionary<AnyHashable, Any>, Bool) -> ()#>, progressHandler: <#T##PHAssetImageProgressHandler##PHAssetImageProgressHandler##(Double, Error?, UnsafeMutablePointer<ObjCBool>, [AnyHashable : Any]?) -> Void#>, networkAccessAllowed: <#T##Bool#>)
        
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        var array: Array = [UIImage]()
        
        queue.async(group: group) {
            
            for i in 0..<20 {
                LImagePickerManager.shared.getPhotoWithAsset(self.dataArray[i], photoWidth: LConstant.screenHeight, completion: { (image, info, isDegraded) in
                    guard let `image` = image else { return }
                    
                    array.append(image)
                    print(Thread.current)
                    
                }, progressHandler: { (progress, error, objc, info) in
                    print(Thread.current)
                }, networkAccessAllowed: true)
            }
        }
        
        // 超期时间
        switch group.wait(timeout: DispatchTime.now() + 15) {
        case .success:
            print("success")
            // 任务执行完成
        case .timedOut:
            print("timedOut")
            // 任务超时
            
        }
        
        
    }
    
    
}

