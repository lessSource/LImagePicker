//
//  LImagePickerManager.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

final class LImagePickerManager {
    
    static let shared = LImagePickerManager()
    
    private init() { }
}

extension LImagePickerManager {
    
    // 获取相册权限
    func requestsPhotosAuthorization() -> Bool {
        var status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            let semaphore = DispatchSemaphore(value: 0)
            self.requestAuthorizationWithCompletion { (authorizationStatus) in
                status = authorizationStatus
                semaphore.signal()
            }
            semaphore.wait()
            return status == .authorized
        }else {
            return status == .authorized
        }
    }
    
    func requestAuthorizationWithCompletion(_ completion: ((PHAuthorizationStatus) -> ())?) {
        PHPhotoLibrary.requestAuthorization { (status) in
            if let closure = completion {
                closure(status)
            }
        }
    }
    
    // 获取相机权限、获取麦克风权限
    func requestsCameraAuthorization(mediaType: AVMediaType) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var status = AVCaptureDevice.authorizationStatus(for: mediaType)
            if status == .notDetermined {
                let semaphore = DispatchSemaphore(value: 0)
                self.requestCameraAuthorizationWithCompletion(mediaType) { (success) in
                    status = success ? .authorized : .denied
                    semaphore.signal()
                }
                semaphore.wait()
                return status == .authorized
            }else {
                return status == .authorized
            }
        }else {
            return false
        }
    }
    
    func requestCameraAuthorizationWithCompletion(_ mediaType: AVMediaType, completion: ((Bool) -> ())?) {
        AVCaptureDevice.requestAccess(for: mediaType) { (success) in
            if let closure = completion {
                closure(success)
            }
        }
    }
    
}


extension LImagePickerManager {
    
    // 获取封面图
    @discardableResult
    func getPostImageWithAlbumModel(model: LAlbumPickerModel, completion: @escaping((UIImage) -> ())) -> PHImageRequestID {
        
        guard let asset = model.asset else {
            return -1
        }
        
        return getPhotoWithAsset(asset, photoWidth: 80, completion: { (image, info, isfof) in
            completion(image)
        }, progressHandler: { (dous, error, objc, info) in
            
        }, networkAccessAllowed: true)
        
    }
    
    
    
    // 获取相册
    func getAlbumResources(_ mediaType: PHAssetMediaType = .unknown, duration: Int = Int.max, complete: @escaping (_ dataArray: [LAlbumPickerModel]) -> ()) {
        
        DispatchQueue.global().async {
            var array: Array = [LAlbumPickerModel]()
            let options = PHFetchOptions()
            let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
            
            smartAlbums.enumerateObjects { (collection, index, stop) in
                let allPhotosOptions = PHFetchOptions()
                if mediaType == .unknown {
                    if duration != Int.max {
                        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d OR duration <= %d", PHAssetMediaType.image.rawValue, duration)
                    }
                }else {
                    allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                }
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
                if collection.assetCollectionSubtype == .smartAlbumAllHidden { return }
                if collection.assetCollectionSubtype.rawValue == 1000000201 { return } // [最近删除] 相册
                
                if fetchResult.count > 0 {
                    let model = LAlbumPickerModel(title: collection.localizedTitle ?? "", asset: fetchResult.lastObject, fetchResult: fetchResult, selectCount: 0)
                    
                    if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                        array.insert(model, at: 0)
                    }else {
                        array.append(model)
                    }
                    
                }
            }
            
            let userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: options)
            userAlbums.enumerateObjects { (collection, index, stop) in
                guard let assetCollection = collection as? PHAssetCollection else { return }
                let allPhotosOptions = PHFetchOptions()
                if mediaType == .unknown {
                    if duration != Int.max {
                        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d OR duration <= %d", PHAssetMediaType.image.rawValue, duration)
                    }
                }else {
                    allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                }
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
                if fetchResult.count > 0 {
                    let model = LAlbumPickerModel(title: collection.localizedTitle ?? "", asset: fetchResult.lastObject, fetchResult: fetchResult, selectCount: 0)
                    array.append(model)
                }
            }
            
            DispatchQueue.main.async {
                complete(array)
            }
        }
    }
    
    
    // 获取相册中资源
    func getPhotoAlbumResources(_ mediaType: PHAssetMediaType = .unknown, successPHAsset: @escaping (PHFetchResult<PHAsset>) -> ()) {
        
        DispatchQueue.global().async {
            var mediaTypePhAsset: PHFetchResult<PHAsset> = PHFetchResult()
            // 获取所有资源
            let allPhotosOptions = PHFetchOptions()
            
            if mediaType == .unknown {
                mediaTypePhAsset = PHAsset.fetchAssets(with: allPhotosOptions)
            }else {
                allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                
                mediaTypePhAsset = PHAsset.fetchAssets(with: mediaType, options: allPhotosOptions)
            }
            
            DispatchQueue.main.async {
                successPHAsset(mediaTypePhAsset)
            }
        }
        
    }
    
    //
    func requestImageDataForAsset(_ asset: PHAsset, completion: @escaping ((Data?, String?, UIImage.Orientation, [AnyHashable : Any]?) -> ()), progressHandler: @escaping PHAssetImageProgressHandler) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        
        options.progressHandler = { progress, error, stop, info in
            DispatchQueue.main.async {
                progressHandler(progress, error, stop, info)
            }
        }
        
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        let imageRequestID = PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: completion)
        
        return imageRequestID
    }
    
    // 获取原图
    func getOriginalPhotoWithAsset(asset: PHAsset, progressHandler: @escaping PHAssetImageProgressHandler, completion: (UIImage, [AnyHashable : Any], Bool) -> ()) -> PHImageRequestID {
        
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = progressHandler
        
        option.resizeMode = .fast
        
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (result, info) in
            
            print(info as Any)
            
        }
        
        return imageRequestID
        
    }
    
    
    // 获取图片
    func getPhotoWithAsset(_ asset: PHAsset, photoWidth: CGFloat, completion: @escaping (UIImage, Dictionary<AnyHashable, Any>, Bool) -> (), progressHandler: @escaping PHAssetImageProgressHandler, networkAccessAllowed: Bool) -> PHImageRequestID {
        var imageSize: CGSize = .zero
        
        if photoWidth < LConstant.screenWidth {
            imageSize = CGSize(width: photoWidth, height: photoWidth)
        }else {
            let phAsset = asset
            let aspectRation: CGFloat = CGFloat(phAsset.pixelWidth) / CGFloat(phAsset.pixelHeight)
            var pixelWidth = photoWidth * 1.5
            
            // 超宽图片
            if aspectRation > 1.8 {
                pixelWidth = pixelWidth * aspectRation
            }
            
            // 超高图片
            if aspectRation < 0.2 {
                pixelWidth = pixelWidth * 0.5
            }
            let pixelHeight = pixelWidth / aspectRation
            imageSize = CGSize(width: pixelWidth, height: pixelHeight)
            
        }
        
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.fast
        
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option) { (result, info) in
            let cancelled: Bool = info?[PHImageCancelledKey] as? Bool ?? false
            
            guard var resultImg = result else { return }
            
            if !cancelled {
                
                resultImg = self.fixOrientation(aImage: resultImg)
                
                completion(resultImg, info!, info?[PHImageResultIsDegradedKey] as! Bool)
                
            }
            
            // Dowunload image from iCloud / 从iCloud下载图片
            if (info?[PHImageResultIsInCloudKey] != nil) && !(result != nil) && networkAccessAllowed {
                
                let options = PHImageRequestOptions()
                
//                DispatchQueue.main.async {
//                    options.progressHandler = progressHandler
//                }
                
                options.progressHandler = { progress, error, stop, info in
                    DispatchQueue.main.async {
                        progressHandler(progress, error, stop, info)
                    }
                }
                
                options.isNetworkAccessAllowed = true
                options.resizeMode = .fast
                PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
                    
                    var resultImage = UIImage(data: imageData!)
                    
                    if !(resultImage != nil) && (result != nil) {
                        resultImage = result
                    }
                    
                    resultImage = self.fixOrientation(aImage: resultImage!)
                    completion(resultImage!, info!, false)
                }
            }
            
            
            
        }
        
        return imageRequestID
        
    }
    
    
    // 修改图片转向
    fileprivate func fixOrientation(aImage: UIImage) -> UIImage {
//        if (!self.shouldFixOrientation) return aImage;

        if aImage.imageOrientation == .up {
            return aImage
        }
        
        var transform: CGAffineTransform = CGAffineTransform()
        
        switch aImage.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: aImage.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
        default: break
        }
        
        switch aImage.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: aImage.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default: break

        }
        
        guard let cgImage = aImage.cgImage, let colorSpace = cgImage.colorSpace, let ctx: CGContext = CGContext(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return aImage
        }
        
        transform.concatenating(ctx.ctm)
        
        switch aImage.imageOrientation {
        case .leftMirrored, .left, .rightMirrored, .right:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
        }
        
        let cgimg = ctx.makeImage()
        let image = UIImage(cgImage: cgimg ?? cgImage)
        
        return image
        
    }
    
    
    // 获取一组图片的大小
    fileprivate func getPhotosBytesWith(assetArray: [LImagePickerResourcesModel], completion: @escaping ((String) -> ())) {
        if assetArray.count == 0 {
            completion("0B")
            return
        }
        
        var dataLength: Int = 0
        for resourcesModel in assetArray {
            
            guard let asset = resourcesModel.media as? PHAsset else {
                continue
            }
            
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            
            if resourcesModel.type == .photoGif {
                options.version = .original
            }
            
            PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, dataUIT, orientation, info) in
                if let data = imageData {
                    dataLength += data.count
                    
                    if asset == assetArray.last?.media as? PHAsset {
                        let bytes = self.getBytesFromData(length: Double(dataLength))
                        completion(bytes)
                    }
                }
            }
        }
        
        
        
    }
    
    // 格式化图片大小
    fileprivate func getBytesFromData(length: Double) -> String {
        var bytes: String = ""
        if length >= 0.1 * (1024.0 * 1024.0) {
            bytes = "\(length/1024.0/1024.0)M"
        }else if length >= 1024.0 {
            bytes = "\(length/1024.0)K"
        }else {
            bytes = "\(length)B"
        }
        return bytes
    }
    
}
