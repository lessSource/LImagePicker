//
//  PreviewViewController.swift
//  LImagePicker
//
//  Created by L on 2021/7/7.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit
import Photos

private let cellMargin: CGFloat = 20

class PreviewViewController: UICollectionViewController {

    public weak var imagePickerDelegate: ImagePreviewProtocol?
    /** 查看大图返回时需要修改定位的数量，例如前面过滤一个拍照按钮 */
    public var correctionNumber: Int = 0
    
    /** 数据模型 */
    fileprivate(set) var previewModel = PreviewImageModel()
    /** 当前序号 */
    fileprivate(set) var currentIndex: Int = 0
    
    fileprivate var deleteArray: [ImagePickerMediaProtocol] = []

    
    fileprivate override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(previewModel: PreviewImageModel) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: LConstant.screenWidth + cellMargin, height: LConstant.screenHeight)
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.init(collectionViewLayout: layout)
        self.previewModel = previewModel
        self.modalPresentationStyle = .currentContext
        assert(!(previewModel.currentIndex >= previewModel.dataArray.count || previewModel.currentIndex < 0), "请输入正确的序号")
        self.currentIndex = previewModel.currentIndex
        if previewModel.currentIndex < 0 || previewModel.currentIndex >= previewModel.dataArray.count {
            self.currentIndex = 0
        }
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        
        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
    }
    
    // MARK:- initView
    fileprivate func initView() {
        collectionView.frame = UIScreen.main.bounds
        collectionView.l_width = LConstant.screenWidth + cellMargin
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: previewModel.currentIndex), at: .left, animated: false)
        
        collectionView.register(PreviewImageCell.self, forCellWithReuseIdentifier: PreviewImageCell.l_identifire)
        collectionView.register(PreviewVideoCell.self, forCellWithReuseIdentifier: PreviewVideoCell.l_identifire)
        collectionView.register(PreviewGifCell.self, forCellWithReuseIdentifier: PreviewGifCell.l_identifire)
        collectionView.register(PreviewLivePhoteCell.self, forCellWithReuseIdentifier: PreviewLivePhoteCell.l_identifire)
    }

    fileprivate func previewCellPanRecognizer(_ gesture: UIPanGestureRecognizer, point: CGPoint) {
        switch gesture.state {
        case .began:
            collectionView.isScrollEnabled = false
        case .changed:
            collectionView.isScrollEnabled = false
            view.backgroundColor = UIColor(white: 0.0, alpha: point.y < 0 ? 1 : 25 / point.y)
        default:
            collectionView.isScrollEnabled = true
            if point.y < 50 {
                UIView.animate(withDuration: 0.2) {
                } completion: { finished in
                    self.view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
                }
            }
        }
    }
    
}

extension PreviewViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return previewModel.dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PreviewImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageCell.l_identifire, for: indexPath) as! PreviewImageCell
        cell.moveSelectClouse = { [weak self] (point, gesture) in
            self?.previewCellPanRecognizer(gesture, point: point)
        }
        if let asset = previewModel.dataArray[indexPath.section] as? PHAsset  {
            cell.getPhotoAsset(asset: asset)
        }else if let image = previewModel.dataArray[indexPath.section] as? UIImage {
            cell.getPhotoImage(image: image)
        }else if let photographModel = previewModel.dataArray[indexPath.section] as? PhotographModel {
            cell.getPhotoAsset(asset: photographModel.media)
        }else if let string = previewModel.dataArray[indexPath.section] as? String {
            if string.hasPrefix("http") {
                imagePickerDelegate?.imagePickerPreview(viewController: self, urlStr: string, imageView: cell.currentImage, completionHandler: { cell.resizeSubviews() })
            }else {
                cell.getPhotoString(imageStr: string)
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let previewImageCell = cell as? PreviewCollectionViewCell {
            previewImageCell.scrollView.zoomScale = 1.0
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.l_width)
//        guard let imagePicker = navigationController as? ImagePickerController else { return }
    }
    
}
