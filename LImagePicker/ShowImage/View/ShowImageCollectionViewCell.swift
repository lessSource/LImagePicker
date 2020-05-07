//
//  ShowImageCollectionViewCell.swift
//  ImitationShaking
//
//  Created by Lj on 2019/6/25.
//  Copyright © 2019 study. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Kingfisher

class ShowImageCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    enum ActionEnum {
        case tap    // 点击
        case long   // 长按
        case play   // 视频播放
    }
    
    typealias actionClosure = (_ actionType: ActionEnum) -> Void
    
    private var isLivePhoto: Bool = false
    
    private(set) var action: actionClosure?

    private(set) var imageRequestID: PHImageRequestID?
    
    private(set) var assetIdentifier: String = ""
    
    private var livePhotoPlay: Bool = false
    
    fileprivate var asset: PHAsset?
    
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
        return image
    }()

    public lazy var livePhoto: PHLivePhotoView = {
        let livePhoto = PHLivePhotoView()
        livePhoto.contentMode = .scaleAspectFit
        livePhoto.frame = self.scrollView.bounds
        livePhoto.delegate = self
        return livePhoto
    }()
    
    fileprivate lazy var playerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width/2 - 25, y: UIScreen.main.bounds.height/2 - 25, width: 80, height: 80))
        button.setImage(UIImage.imageNameFromBundle("icon_video"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func layoutView() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(currentImage)
        scrollView.addSubview(playerButton)
        scrollView.addSubview(livePhoto)
        
        playerButton.addTarget(self, action: #selector(playerButtonClick), for: .touchUpInside)
        addGesture()
    }
    
    // MARK:- Gesture
    fileprivate func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        currentImage.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureClick(_ :)))
        currentImage.addGestureRecognizer(longGesture)
        
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(ShowImageCollectionViewCell.doubleGestureClick(_ :)))
        doubleGesture.numberOfTapsRequired = 2;
        currentImage.addGestureRecognizer(doubleGesture)
        tapGesture.require(toFail: doubleGesture)
        
        livePhoto.playbackGestureRecognizer.addTarget(self, action: #selector(playbackGesture))
    }
    
    
    // MARK:- Event
    // 点击
    @objc func tapAction() {
        guard let action = action else { return }
        action(.tap)
    }
    /** 长按 */
    @objc func longGestureClick(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let action = action else { return }
        if gestureRecognizer.state == .began {
            action(.long)
            playLivePhoto()
        }
    }
    /** 双击 */
    @objc func doubleGestureClick(_ gestureRecognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        }else {
            let touchPoint = gestureRecognizer.location(in: currentImage)
            let newZoomScale = scrollView.maximumZoomScale
            let sizeX = scrollView.frame.width / newZoomScale
            let sizeY = scrollView.frame.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - sizeX / 2, y: touchPoint.y - sizeY / 2, width: sizeX, height: sizeY), animated: true)
        }
    }
    
    @objc func playerButtonClick() {
        if let action = self.action {
            action(.play)
        }
    }
    
    /** LivePhoto */
    @objc func playbackGesture() {
        print("playbackGesture")
    }
    
    // MARK:- public
    public func updateImage(imageData: LMediaResourcesModel) {
        let start = CACurrentMediaTime()
        livePhoto.isHidden = true
        if let image = imageData.dataProtocol as? UIImage {
            currentImage.image = image
        }else if let asset = imageData.dataProtocol as? PHAsset {
            loadImage(asset, dateEnum: imageData.dateEnum)
        }else if let string = imageData.dataProtocol as? String {
            if string.hasPrefix("http") {
                if imageData.dateEnum == .image, let url = URL(string: string) {
                    currentImage.kf.setImage(with: ImageResource(downloadURL: url), placeholder: UIImage(named: ""))
                    print(url)
                }else if imageData.dateEnum == .video {
                    if !imageData.videoCover.isEmpty, let url = URL(string: imageData.videoCover) {
                        currentImage.kf.setImage(with: ImageResource(downloadURL: url), placeholder: UIImage(named: ""))
                        print(url)
                    }else {
                        currentImage.l_getNetWorkVidoeImage(urlStr: string, placeholder: "")
                    }
                }else {
                    currentImage.image = UIImage(named: "")
                }
            }else {
                currentImage.image = UIImage(named: string)
            }
        }
        playerButton.isHidden = imageData.dateEnum != .video
        let end = CACurrentMediaTime()
        print("方法耗时为：\(end-start)")
    }
    
    public func imageClick(action: @escaping actionClosure) {
        self.action = action
    }

    // MARK:- fileprivate
    fileprivate func loadImage(_ asset: PHAsset, dateEnum: ImageDataEnum) {
        if livePhotoPlay { livePhoto.stopPlayback() }
        self.asset = asset
        assetIdentifier = asset.localIdentifier
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.resizeMode = .fast
        option.isSynchronous = true
        let start = CACurrentMediaTime()

        let imageRequestID = PHImageManager.default().requestImageData(for: asset, options: option) { (data, str, orientation, info) in
            let end = CACurrentMediaTime()
            print("方法耗时为11111：\(end-start)")
            let start1 = CACurrentMediaTime()
            print(Thread.current)
            if self.assetIdentifier == asset.localIdentifier, let imageData = data {
                if dateEnum == .gif, let gifImageClass = ImagePickerGifImage(from: imageData)  {
                    self.currentImage.animationImages = gifImageClass.images
                    self.currentImage.animationDuration = gifImageClass.duration
                    self.currentImage.animationRepeatCount = 0 // 循环
                    self.currentImage.startAnimating()
                }else {
                    self.currentImage.image = UIImage(data: imageData)
                }
                let end1 = CACurrentMediaTime()
                print("方法耗时为2222：\(end1-start1)")
            }else {
                if let requestId = self.imageRequestID {
                    PHImageManager.default().cancelImageRequest(requestId)
                }
            }
        }
        self.imageRequestID = imageRequestID
    }
    
    fileprivate func playLivePhoto() {
        if livePhotoPlay { return }
        guard let asset = self.asset else { return }
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        }
        assetIdentifier = asset.localIdentifier
        livePhoto.isHidden = false
        let option: PHLivePhotoRequestOptions = PHLivePhotoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        var size: CGSize = .zero
        let height: CGFloat = CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth) * UIScreen.main.bounds.width
        size = CGSize(width: UIScreen.main.bounds.width, height: height)
        let imageRequestID = PHCachingImageManager().requestLivePhoto(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { (livePhoto, dic) in
            if self.assetIdentifier == asset.localIdentifier {
                self.livePhoto.livePhoto = livePhoto
                if !self.livePhotoPlay {
                    self.livePhoto.startPlayback(with: .full)
                }
            }else {
                if let requestId = self.imageRequestID {
                    PHCachingImageManager().cancelImageRequest(requestId)
                }
            }
        }
        if let requestId = self.imageRequestID, requestId != imageRequestID {
            PHCachingImageManager().cancelImageRequest(requestId)
        }
        self.imageRequestID = imageRequestID
    }
}


extension ShowImageCollectionViewCell: PHLivePhotoViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if livePhotoPlay {
            return livePhoto
        }
        return currentImage
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhoto.isHidden = false
     }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhoto.isHidden = true
        livePhotoPlay = false
    }
}
