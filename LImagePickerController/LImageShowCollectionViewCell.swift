//
//  LImageShowCollectionViewCell.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LImageShowCollectionViewCell: UICollectionViewCell {
    
//    fileprivate var representedAssetIdentifier: String = ""
    
    fileprivate var imageRequestID: PHImageRequestID?
    
    fileprivate var asset: PHAsset?

//
//    fileprivate var bigImageRequestID: PHImageRequestID?
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
//        scrollView.frame = contentView.bounds
//        scrollView.l_width -= 20
        scrollView.bouncesZoom = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.isMultipleTouchEnabled = true
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.delaysContentTouches = true
        scrollView.alwaysBounceVertical = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    fileprivate lazy var imageContainerView: UIView = {
        let imageView = UIView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public lazy var currentImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.frame = self.scrollView.bounds
        image.isUserInteractionEnabled = true
        image.image = UIImage.imageNameFromBundle("icon_permissions")
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    fileprivate func initView() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(currentImage)
        
        _addGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, width: l_width - 20, height: l_height)
    }
    
    public func getPhotoImage(image: UIImage) {
        currentImage.image = image
        
    }
    
    public func getPhotoAsset(asset: PHAsset) {
        self.asset = asset
        if let imageRequest = self.imageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequest)
        }
        
        self.imageRequestID = LImagePickerManager.shared.getPhotoWithAsset
        
//        self.imageRequestID = LImagePickerManager.shared.getPhotoWithAsset(asset,Cs completion: { (photo, info, isDegraded) in
//            
//            if self.asset != asset { return }
//            self.currentImage.image = photo
//            
//            if !isDegraded {
//                self.imageRequestID = 0
//            }
//            
//            self.resizeSubviews()
//            
//        }, progressHandler: { (progress, error, objc, info) in
//            if self.asset != asset { return }
//            
//            if progress >= 1 {
//                self.imageRequestID = 0
//            }
//            
//        }, networkAccessAllowed: true)
        
        
        
    }
    
    fileprivate func resizeSubviews() {
        imageContainerView.frame.origin = .zero
        imageContainerView.l_width = scrollView.l_width
        
        guard let image = currentImage.image else {
            return
        }
        
        if image.size.height / image.size.width > l_height / l_width {
            imageContainerView.l_height = floor(image.size.height / (image.size.width / scrollView.l_width))
        }else {
            var height = image.size.height / image.size.width * scrollView.l_width
            if height < 1 || height.isNaN {
                height = l_height
            }
            height = floor(height)
            imageContainerView.l_height = height
            imageContainerView.center.y = l_height / 2
        }
        
        if imageContainerView.l_height > l_height && imageContainerView.l_height - l_height <= 1 {
            imageContainerView.l_height = l_height
        }
        let contentSizeH = max(imageContainerView.l_height, l_height)
        scrollView.contentSize = CGSize(width: scrollView.l_width, height: contentSizeH)
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.l_height <= l_height ? false : true
        currentImage.frame = imageContainerView.bounds
        
        
    }
    
}

extension LImageShowCollectionViewCell {
    
    fileprivate func _addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        currentImage.addGestureRecognizer(tapGesture)
        
        let longGetsture = UILongPressGestureRecognizer(target: self, action: #selector(longGetstureAction(_ :)))
        currentImage.addGestureRecognizer(longGetsture)
        
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(doubleGestureClick(_ :)))
        doubleGesture.numberOfTapsRequired = 2
        currentImage.addGestureRecognizer(doubleGesture)
        tapGesture.require(toFail: doubleGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureClick(_ :)))
        swipeGesture.direction = [.up, .down]
        currentImage.addGestureRecognizer(swipeGesture)
        
    }
    
    
    fileprivate func refreshImageContainerViewCenter() {
        let offsetX = (scrollView.l_width > scrollView.contentSize.width) ? ((scrollView.l_width - scrollView.contentSize.width) * 0.5) : 0.0
        let offsetY = (scrollView.l_height > scrollView.contentSize.height) ? ((scrollView.l_height - scrollView.contentSize.height) * 0.5) : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    fileprivate func refreshScrollViewContentSize() {
        
    }
}


extension LImageShowCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshImageContainerViewCenter()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("完成")
        refreshScrollViewContentSize()
    }
}

@objc
extension LImageShowCollectionViewCell {
    
    // 点击
    fileprivate func tapAction() {
        getControllerFromView()?.dismiss(animated: true, completion: nil)
    }
    
    // 长按
    fileprivate func longGetstureAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
    }
    
    // 双击
    fileprivate func doubleGestureClick(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.contentInset = .zero
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }else {
            let touchPoint = gestureRecognizer.location(in: currentImage)
            let newZoomScale = scrollView.maximumZoomScale
            let sizeX = scrollView.frame.width / newZoomScale
            let sizeY = scrollView.frame.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - sizeX / 2, y: touchPoint.y - sizeY / 2, width: sizeX, height: sizeY), animated: true)
        }
    }
    
    // 上下滑动
    fileprivate func swipeGestureClick(_ gestureRecognizer: UISwipeGestureRecognizer) {
        
        switch gestureRecognizer.direction {
        case [.up, .down]:
            print("up, down")
        default: break
        }
        
    }
}
