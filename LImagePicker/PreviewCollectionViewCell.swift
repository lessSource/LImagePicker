//
//  PreviewCollectionViewCell.swift
//  LImagePicker
//
//  Created by L on 2021/7/9.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit
import Photos

class PreviewCollectionViewCell: UICollectionViewCell {
    
    typealias MoveImageClosure = (CGPoint, UIPanGestureRecognizer) -> ()
    
    public var moveSelectClouse: MoveImageClosure?
    
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
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        
        scrollView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
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
    
    public lazy var copyCurrentImage: UIImageView = {
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
        let scale = UIScreen.main.scale
        let w = min(UIScreen.main.bounds.width, ImagePickerManager.shared.photoPreviewMaxWidth) * scale
        let size = CGSize(width: w, height: w * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth))
        if size.height.isNaN || size.height == 0 {
            return CGSize(width: w, height: w)
        }
        return CGSize(width: CGFloat(w), height: CGFloat(w) * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth))
    }
    
    public func getPhotoAsset(asset: PHAsset) {
        self.mediaAsset = asset
        if imageRequestID > PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(imageRequestID)
        }
        representedAssetIdentifier = asset.localIdentifier
        imageRequestID = ImagePickerManager.shared.getPhotoWithAsset(asset, size: requestPhotoSize(asset: asset), resizeMode: .fast, progress: { (progress, _, _, _) in
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
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureClick(_ :)))
        swipeUpGesture.direction = .up
        currentImage.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureClick(_:)))
        swipeDownGesture.direction = .down
        currentImage.addGestureRecognizer(swipeDownGesture)
    }
    
    fileprivate func refreshImageContainerViewCenter() {
        let offsetX = (scrollView.l_width > scrollView.contentSize.width) ? ((scrollView.l_width - scrollView.contentSize.width) * 0.5) : 0.0
        let offsetY = (scrollView.l_height > scrollView.contentSize.height) ? ((scrollView.l_height - scrollView.contentSize.height) * 0.5) : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}



extension PreviewCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshImageContainerViewCenter()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        panGestureClick(scrollView.panGestureRecognizer)
    }
}

@objc
extension PreviewCollectionViewCell {
    
    // 点击
    fileprivate func tapAction() {
        if scrollView.zoomScale == 1 {
            copyCurrentImage.frame = currentImage.frame
            copyCurrentImage.l_y = LConstant.screenHeight/2 - copyCurrentImage.l_height/2
            viewController()?.dismiss(animated: true, completion: nil)
        }
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
        let point: CGPoint = gestureRecognizer.location(in: currentImage)
        
        switch gestureRecognizer.direction {
        case .down:
            print("down\(point)")
        case .up:
            print("up")
        default: break
        }
    }
    
    // 移动
    fileprivate func panGestureClick(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point: CGPoint = gestureRecognizer.translation(in: currentImage)
        print("\(point)")
        if scrollView.zoomScale != 1 { return }
        moveSelectClouse?(point, gestureRecognizer)
        
        switch gestureRecognizer.state {
        case .began:
            print("began")
            copyCurrentImage.image = currentImage.image
            copyCurrentImage.frame = currentImage.frame
            copyCurrentImage.l_y = LConstant.screenHeight/2 - copyCurrentImage.l_height/2
            currentImage.isHidden = true
            copyCurrentImage.isHidden = false
            scrollView.addSubview(copyCurrentImage)
        case .changed:
            copyCurrentImage.l_y = point.y + LConstant.screenHeight/2 - copyCurrentImage.l_height/2
            copyCurrentImage.l_width = LConstant.screenWidth - point.y/3
            copyCurrentImage.l_x = point.x
            scrollView.backgroundColor = UIColor(white: 0.0, alpha: point.y < 0 ? 1 : 70/point.y)
        default:
            if point.y < 50 {
                UIView.animate(withDuration: 0.2) {
                    self.copyCurrentImage.frame = self.currentImage.frame
                    self.copyCurrentImage.l_y = LConstant.screenHeight/2 - self.copyCurrentImage.l_height/2
                } completion: { finish in
                    self.currentImage.isHidden = false
                    self.copyCurrentImage.isHidden = true
                }
            }else {
                viewController()?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}


class PreviewImageCell: PreviewCollectionViewCell { }

class PreviewVideoCell: PreviewCollectionViewCell { }

class PreviewGifCell: PreviewCollectionViewCell { }

class PreviewLivePhoteCell: PreviewCollectionViewCell { }
