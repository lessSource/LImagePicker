//
//  LPreviewImageController.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

private let cellMargin: CGFloat = 20

class LPreviewImageController: UICollectionViewController {

    public weak var imagePickerDelegate: LImagePickerProtocol?
    
    /** 数据模型 */
    fileprivate(set) var configuration = LPreviewImageModel()
    
    /** 当前序号 */
    fileprivate(set) var currentIndex: Int = 0
    
    /** 有拍照按钮时需要重新定位 */
    fileprivate(set) var correctionNumber: Int = 0
    
    fileprivate var deleteArray: [LImagePickerMediaProtocol] = []
    
    fileprivate lazy var navView: LImagePickerNavView = {
        let navView = LImagePickerNavView(frame: CGRect(x: 0, y: -LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.cancleImageStr = "icon_close_white"
        navView.isPreviewButton = true
        navView.dropDownImage.isHidden = true
        navView.delegate = self
        navView.titleColor = UIColor.previewNavTitleColor
        return navView
    }()
    
    fileprivate lazy var bottomView: LImagePickerBottomView = {
        let bottomView = LImagePickerBottomView(frame: CGRect(x: 0, y: LConstant.screenHeight, width: LConstant.screenWidth, height: LConstant.bottomBarHeight))
        bottomView.isPreviewHidden = true
        bottomView.isConfirmSelect = true
        bottomView.delegate = self
        return bottomView
    }()
    
    fileprivate lazy var previewView: LPreviewBottomView = {
        let previewView = LPreviewBottomView(frame: CGRect(x: 0, y: LConstant.screenHeight - 76 - LConstant.bottomBarHeight, width: LConstant.screenWidth, height: 76))
        previewView.backgroundColor = UIColor.previewNavBackColor
        previewView.delegate = self
        return previewView
    }()
    
    fileprivate override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init(configuration: LPreviewImageModel) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: LConstant.screenWidth + cellMargin, height: LConstant.screenHeight)
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.init(collectionViewLayout: layout)
        self.configuration = configuration
        assert(!(configuration.currentIndex >= configuration.dataArray.count || configuration.currentIndex < 0), "请输入正确的序号")
        self.currentIndex = configuration.currentIndex
        if configuration.currentIndex < 0 || configuration.currentIndex >= configuration.dataArray.count {
            self.currentIndex = 0
        }
    }
    
    deinit {
        print(self, "++++++释放")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if imagePicker.isViewLargerImage {
            UIView.animate(withDuration: 0.3) {
                self.navView.l_y = 0
                self.bottomView.l_y = LConstant.screenHeight - LConstant.bottomBarHeight
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
    }
    
    // MARK: - initView
    fileprivate func initView() {
        collectionView.frame = UIScreen.main.bounds
        collectionView.l_width = LConstant.screenWidth + cellMargin
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(LPreviewImageCell.self, forCellWithReuseIdentifier: LPreviewImageCell.l_identifire)
        collectionView.register(LPreviewVideoCell.self, forCellWithReuseIdentifier: LPreviewVideoCell.l_identifire)
        collectionView.register(LPreviewGifCell.self, forCellWithReuseIdentifier: LPreviewGifCell.l_identifire)
        collectionView.register(LPreviewLivePhoteCell.self, forCellWithReuseIdentifier: LPreviewLivePhoteCell.l_identifire)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: configuration.currentIndex), at: .left, animated: false)
        if let photographModel = configuration.dataArray[currentIndex] as? LPhotographModel {
            navView.selectSerialNumber(index: photographModel.selectIndex)
        }
        view.addSubview(navView)
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        correctionNumber = imagePicker.correctionNumber
        if imagePicker.isViewLargerImage {
            navView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            navView.title = "\(currentIndex + 1)/\(configuration.dataArray.count)"
            navView.isPreviewButton = false
            navView.completeButton.isHidden = imagePicker.isViewLargerEditorImage
            if !imagePicker.isViewLargerEditorImage {
                // 下载
                let downloadButton = UIButton(frame: CGRect(x: LConstant.screenWidth - 50, y: LConstant.screenHeight - LConstant.barHeight - 50, width: 34, height: 34))
                downloadButton.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_down_pic"), for: .normal)
                downloadButton.addTarget(self, action: #selector(downloadButtonClick), for: .touchUpInside)
                view.addSubview(downloadButton)
                
                // 删除
                let deleteButton = UIButton(frame: CGRect(x: 16, y: LConstant.screenHeight - LConstant.barHeight - 50, width: 34, height: 34))
                deleteButton.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_delete_pic"), for: .normal)
                deleteButton.addTarget(self, action: #selector(deleteButtonClcik), for: .touchUpInside)
                view.addSubview(deleteButton)
                
            }
        }else {
            navView.l_y = 0
            bottomView.l_y = LConstant.screenHeight - LConstant.bottomBarHeight
            navView.backgroundColor = UIColor.previewNavBackColor
            bottomView.backgroundColor = UIColor.previewNavBackColor
            view.addSubview(bottomView)
            bottomView.number = configuration.dataArray.count
            view.addSubview(previewView)
            previewView.dataArray = configuration.dataArray.compactMap { $0 as? LPhotographModel }
            previewView.selectIndex = configuration.currentIndex
        }
        
        
    }
}

extension LPreviewImageController: LImagePickerButtonProtocl, LPreviewImageProtocol, LPreviewBottomProtocol {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return configuration.dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LPreviewImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: LPreviewImageCell.l_identifire, for: indexPath) as! LPreviewImageCell
        cell.delegate = self
        if let asset = configuration.dataArray[indexPath.section] as? PHAsset  {
            cell.getPhotoAsset(asset: asset)
        }else if let image = configuration.dataArray[indexPath.section] as? UIImage {
            cell.getPhotoImage(image: image)
        }else if let photographModel = configuration.dataArray[indexPath.section] as? LPhotographModel {
            cell.getPhotoAsset(asset: photographModel.media)
        }else if let string = configuration.dataArray[indexPath.section] as? String {
            if string.hasPrefix("http") {
                imagePickerDelegate?.previewImageLoading(viewController: self, urlStr: string, imageView: cell.currentImage, completionHandler: { cell.resizeSubviews() })
            }else {
                cell.getPhotoString(imageStr: string)
            }
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let previewImageCell = cell as? LPreviewCollectionViewCell {
            previewImageCell.scrollView.zoomScale = 1.0
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.l_width)
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if imagePicker.isViewLargerImage {
            navView.title = "\(currentIndex + 1)/\(configuration.dataArray.count)"
        }else {
            if let photographModel = configuration.dataArray[safe: currentIndex] as? LPhotographModel {
                navView.selectSerialNumber(index: photographModel.selectIndex)
            }
            previewView.selectIndex = currentIndex
        }
    }
    
    func buttonView(view: UIView, buttonType: LImagePickerButtonType) {
        if buttonType == .cancle {
            guard let imagePicker = navigationController as? LImagePickerController else { return }
            if imagePicker.isViewLargerImage {
                
            }else {
                for (i, itme) in configuration.dataArray.enumerated() {
                    guard let photographModel = itme as? LPhotographModel else { continue }
                    if !photographModel.isSelect {
                        photographModel.isSelect = true
                        imagePickerDelegate?.previewImageState(viewController: self, mediaProtocol: photographModel)
                    }
                }
            }
            dismiss(animated: true, completion: nil)
        }else if buttonType == .confirm {
            guard let imagePicker = navigationController as? LImagePickerController else { return }
            if !imagePicker.isViewLargerEditorImage {
                imagePickerDelegate?.previewImageDeleteImages(viewController: self, images: deleteArray)
                dismiss(animated: true, completion: nil)
            }else {
                dismiss(animated: true, completion: nil)
            }
        }else if buttonType == .previewSelect {
            guard let photographModel = configuration.dataArray[safe: currentIndex] as? LPhotographModel else { return }
            photographModel.isSelect = !photographModel.isSelect
            if !photographModel.isSelect {
                photographModel.selectIndex = 0
            }else {
                photographModel.selectIndex = 1
            }
            navView.selectSerialNumber(index: photographModel.selectIndex)
            previewView.selectIndex = currentIndex
            bottomView.number = configuration.dataArray.compactMap { $0 as? LPhotographModel }.filter { $0.isSelect }.count
            imagePickerDelegate?.previewImageState(viewController: self, mediaProtocol: photographModel)
        }
    }
    
    func previewImageDidSelect(cell: UICollectionViewCell) {
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let imagePicker = navigationController as? LImagePickerController else { return }
        if imagePicker.isViewLargerImage {
            UIView.animate(withDuration: 0.3) {
                self.navView.l_y = self.navView.l_y == 0 ? -LConstant.navbarAndStatusBar : 0
            }
        }
    }
    
    func previewBottomView(view: UIView, didSelect index: Int) {
        currentIndex = index
        collectionView.scrollToItem(at: IndexPath(item: 0, section: currentIndex), at: .left, animated: false)
    }
    
}

@objc
extension LPreviewImageController {
    
    fileprivate func downloadButtonClick() {
        let index = IndexPath(item: currentIndex, section: 0)
        guard let cell = collectionView.cellForItem(at: index) as? LPreviewImageCell, let image = cell.currentImage.image else {
            return
        }
        PHPhotoLibrary.shared().performChanges {
            let _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let hub = LProgressHUDView(style: .dark, prompt: "下载成功")
                    hub.showPromptInfo(showView: self.view)
                }
            }
        }
    }
    
    fileprivate func deleteButtonClcik() {
        if configuration.dataArray.count > 0 {
            let deleteMedia = configuration.dataArray.remove(at: currentIndex)
            deleteArray.append(deleteMedia)
            currentIndex = 0
            navView.title = "0/\(configuration.dataArray.count)"
            collectionView.reloadData()
        }

    }
    
}
