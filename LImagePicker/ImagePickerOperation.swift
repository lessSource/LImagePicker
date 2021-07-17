//
//  ImagePickerOperation.swift
//  LImagePicker
//
//  Created by L on 2021/7/6.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit
import Photos

class ImagePickerOperation: Operation {
    
    typealias Completion = ((UIImage? , PHAsset?) -> ())

    fileprivate let isOriginal: Bool
    
    fileprivate let photographModel: PhotographModel
    
    fileprivate let progress: PHAssetImageProgressHandler?
    
    fileprivate let completion: Completion
    
    init(photographModel: PhotographModel, isOriginal: Bool, progress: PHAssetImageProgressHandler? = nil, completion: @escaping Completion) {
        self.photographModel = photographModel
        self.isOriginal = isOriginal
        self.progress = progress
        self.completion = completion
        super.init()
    }
    
    deinit {
        print(self, "+++++++释放")
    }
    
    // 手动触发KVO
    fileprivate var pri_isExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    fileprivate var pri_isFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    fileprivate var pri_isCancelled = false {
        willSet {
            self.willChangeValue(forKey: "isCancelled")
        }
        didSet {
            self.didChangeValue(forKey: "isCancelled")
        }
    }
    
    override var isExecuting: Bool {
        return pri_isExecuting
    }
    
    override var isFinished: Bool {
        return pri_isFinished
    }
    
    override var isCancelled: Bool {
        return pri_isCancelled
    }
    
    override func cancel() {
        super.cancel()
        pri_isCancelled = true
    }
    
    
    override func start() {
        guard !isCancelled else {
            fetchFinish()
            return
        }
        pri_isExecuting = true
                
        // gif
        
        // 图片
        if isOriginal {
            ImagePickerManager.shared.getOriginalPhotoWithAsset(asset: photographModel.media, progressHandler: progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    self?.completion(self?.scaleImage(image), nil)
                    self?.fetchFinish()
                }
            }
        }else {
            let w = min(UIScreen.main.bounds.width, ImagePickerManager.shared.photoPreviewMaxWidth) * 2
            let aspectRatio = CGFloat(photographModel.media.pixelHeight) / CGFloat(photographModel.media.pixelWidth)
            ImagePickerManager.shared.getPhotoWithAsset(photographModel.media, size: CGSize(width: w, height: w * aspectRatio), resizeMode: .fast, progress: self.progress) { [weak self] (image, isDegraded) in
                if !isDegraded {
                    self?.completion(self?.scaleImage(image), nil)
                    self?.fetchFinish()
                }
            }
        }
    }

    fileprivate func scaleImage(_ image: UIImage?) -> UIImage? {
        guard let `image` = image else { return nil }
        
        guard let data = image.jpegData(compressionQuality: 1) else {
            return image
        }
        let mUnit: CGFloat = 1024 * 1024
        if data.count < Int(0.2 * mUnit) {
            return image
        }
        let scale: CGFloat = isOriginal ? (data.count > Int(mUnit) ? 0.7 : 0.9) : (data.count > Int(mUnit) ? 0.5 : 0.7)
        guard let scaleData = image.jpegData(compressionQuality: scale) else {
            return image
        }
        return UIImage(data: scaleData)
    }
    
    fileprivate func fetchFinish() {
        pri_isExecuting = false
        pri_isFinished = true
    }
    
}
