//
//  LPreviewCollectionViewCell.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LPreviewCollectionViewCell: UICollectionViewCell {
    
    public weak var delegate: LPreviewImageProtocol?
    
    fileprivate lazy var imageRequestID: PHImageRequestID = PHInvalidImageRequestID

    fileprivate lazy var representedAssetIdentifier: String = ""
    
    fileprivate var mediaAsset: PHAsset?

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = contentView.bounds
        scrollView.l_width -= 20
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
    
    public lazy var imageContainerView: UIView = {
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
        resizeSubviews()
    }
    
    public func getPhotoString(imageStr: String) {
        currentImage.image = UIImage(named: imageStr)
        resizeSubviews()
    }
    
    
    func requestPhotoSize(asset: PHAsset) -> CGSize {
        let scale = 2
        let w = min(Int(UIScreen.main.bounds.width), Int(LImagePickerManager.shared.photoPreviewMaxWidth)) * scale
        return CGSize(width: CGFloat(w), height: CGFloat(w) * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth))
    }
    
    public func getPhotoAsset(asset: PHAsset) {
        self.mediaAsset = asset
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        representedAssetIdentifier = asset.localIdentifier
        imageRequestID = LImagePickerManager.shared.getPhotoWithAsset(asset, size: requestPhotoSize(asset: asset), resizeMode: .fast, progress: { (progress, _, _, _) in
            print(progress)
        }, completion: { [weak self] (image, isDegraded) in
            guard self?.representedAssetIdentifier == asset.localIdentifier else { return }
            self?.currentImage.image = image
            self?.resizeSubviews()
            if !isDegraded {
                self?.imageRequestID = PHInvalidImageRequestID
            }
        })
    }
    
    public func resizeSubviews() {
        imageContainerView.frame.origin = .zero
        imageContainerView.l_width = scrollView.l_width
        guard let image = currentImage.image else { return }
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
}


extension LPreviewCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshImageContainerViewCenter()
    }
}

@objc
extension LPreviewCollectionViewCell {
    
    // 点击
    fileprivate func tapAction() {
        delegate?.previewImageDidSelect(cell: self)
    }
    
    // 长按
    fileprivate func longGetstureAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        didSelectClosure?(.longGetsture)
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
