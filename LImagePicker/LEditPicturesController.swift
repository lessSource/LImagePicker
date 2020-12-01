//
//  LEditPicturesControllerViewController.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos
//import l

class LEditPicturesController: UIViewController {

    public weak var imagePickerDelegate: LImagePickerProtocol?
    
    fileprivate var mediaProtocol: LImagePickerMediaProtocol
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
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
    
    fileprivate lazy var currentImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.frame = self.scrollView.bounds
        image.isUserInteractionEnabled = true
        return image
    }()
    
    fileprivate lazy var croppingView: LImageCroppingView = {
        let croppingView = LImageCroppingView(frame: self.view.bounds)
        return croppingView
    }()
    
    init(mediaProtocol: LImagePickerMediaProtocol) {
        self.mediaProtocol = mediaProtocol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        LImagePickerManager.shared.shouldFixOrientation = true
        _addGestureRecognizer()
        initView()
        initData()
    }
    
    // MARK: - initView
    fileprivate func initView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(currentImage)
        view.addSubview(croppingView)
    }
    
    func requestPhotoSize(asset: PHAsset) -> CGSize {
        let scale = 2
        let w = min(Int(UIScreen.main.bounds.width), Int(LImagePickerManager.shared.photoPreviewMaxWidth)) * scale
        return CGSize(width: CGFloat(w), height: CGFloat(w) * CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth))
    }
    
    // MARK: - initData
    fileprivate func initData() {
        if let mediaAsset = mediaProtocol as? PHAsset {
            LImagePickerManager.shared.getPhotoWithAsset(mediaAsset, size: requestPhotoSize(asset: mediaAsset), progress: nil) { [weak self]  (image, isDegraded) in
                self?.currentImage.image = image
                self?.resizeSubviews()
            }
        }else if let mediaStr = mediaProtocol as? String {
            if mediaStr.hasPrefix("http") {
                guard let url = URL(string: mediaStr) else { return }
                DispatchQueue.global().async {
                    guard let data = try? Data(contentsOf: url) else { return }
                    DispatchQueue.main.async {
                        self.currentImage.image = UIImage(data: data)
                        self.resizeSubviews()
                    }
                }
            }else {
                currentImage.image = UIImage(named: mediaStr)
                resizeSubviews()
            }
        }else if let mediaImage = mediaProtocol as? UIImage {
            currentImage.image = mediaImage
            resizeSubviews()
        }
    }
    
    
    fileprivate func resizeSubviews() {
        imageContainerView.frame.origin = .zero
        imageContainerView.l_width = scrollView.l_width
        
        guard let image = currentImage.image else {
            return
        }
        if image.size.height / image.size.width > view.l_height / view.l_width {
            imageContainerView.l_height = floor(image.size.height / (image.size.width / scrollView.l_width))
        }else {
            var height = image.size.height / image.size.width * scrollView.l_width
            if height < 1 || height.isNaN {
                height = view.l_height
            }
            height = floor(height)
            imageContainerView.l_height = height
            imageContainerView.center.y = view.l_height / 2
        }
        
        if imageContainerView.l_height > view.l_height && imageContainerView.l_height - view.l_height <= 1 {
            imageContainerView.l_height = view.l_height
        }
        let contentSizeH = max(imageContainerView.l_height, view.l_height)
        scrollView.contentSize = CGSize(width: scrollView.l_width, height: contentSizeH)
        scrollView.scrollRectToVisible(view.bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.l_height <= view.l_height ? false : true
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
    
    fileprivate func refreshScrollViewContentSize() {
//        // 裁剪
//        let cropRect = CGRect(x: 0, y: 0, width: 200, height: 200)
//
//        let contentWidthAdd = scrollView.l_width - cropRect.maxX
//        let contentHeightAdd = (min(imageContainerView.l_height, l_height) - cropRect.height)/2
//
//        let newSizeW = scrollView.contentSize.width + contentWidthAdd
//        let newSizeH = max(scrollView.contentSize.height, l_height) + contentHeightAdd
//        scrollView.contentSize = CGSize(width: newSizeW, height: newSizeH)
//        scrollView.alwaysBounceVertical = true
//
//        // 让scrollView新增滑动区域（裁剪框左上角的图片部分）
//        if contentHeightAdd > 0 || contentWidthAdd > 0 {
//            scrollView.contentInset = UIEdgeInsets(top: contentHeightAdd, left: cropRect.origin.x, bottom: 0, right: 0)
//        }else {
//            scrollView.contentInset = .zero
//        }
    }
}


extension LEditPicturesController: UIScrollViewDelegate {
    
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
extension LEditPicturesController {
    
    // 点击
    fileprivate func tapAction() {        
        var corPedImage = LImagePickerManager.shared.tz_cropImageView(imageView: currentImage, rect: croppingView.cropRect , zoomScale: scrollView.zoomScale, containerView: view)
        corPedImage = LImagePickerManager.shared.tz_circularClipImage(image: corPedImage)
        imagePickerDelegate?.editPictures(viewConttroller: self, croppingImage: corPedImage, originalImage: currentImage.image)
        dismiss(animated: true, completion: nil)
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
