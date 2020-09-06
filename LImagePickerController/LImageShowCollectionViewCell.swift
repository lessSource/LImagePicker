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
        scrollView.frame = contentView.bounds
        scrollView.l_width -= 20
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
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
        scrollView.addSubview(currentImage)
        
        _addGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func getPhotoImage(image: UIImage) {
        currentImage.image = image
        
    }
    
    public func getPhotoAsset(asset: PHAsset) {
        self.asset = asset
        if let imageRequest = self.imageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequest)
        }
        
        self.imageRequestID = LImagePickerManager.shared.getPhotoWithAsset(asset, completion: { (photo, info, isDegraded) in
            
            if self.asset != asset { return }
            self.currentImage.image = photo
            
            if !isDegraded {
                self.imageRequestID = 0
            }
            
        }, progressHandler: { (progress, error, objc, info) in
            if self.asset != asset { return }
            
            if progress >= 1 {
                self.imageRequestID = 0
            }
            
        }, networkAccessAllowed: true)
        
        
        
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
    
}


extension LImageShowCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImage
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
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        }else {
            let touchPoint = gestureRecognizer.location(in: currentImage)
            let newZoomScale = scrollView.maximumZoomScale
            let sizeX = scrollView.frame.width / newZoomScale
            let sizeY = scrollView.frame.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - sizeX / 2, y: touchPoint.y - sizeY / 2, width: sizeY, height: sizeY), animated: true)
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
