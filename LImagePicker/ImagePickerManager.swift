//
//  ImagePickerManager.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices
import UIKit

final class ImagePickerManager {
    
    /** 默认600像素宽 */
    public var photoPreviewMaxWidth: CGFloat = 600
    /// 对照片排序，按修改时间升序，默认是YES
    public var sortAscendingByModificationDate: Bool = true
    /** 是否修正图片 */
    public var shouldFixOrientation: Bool = false
    
    static let shared = ImagePickerManager()
    
    private init() { }
    
}

extension ImagePickerManager {
    
    // 获取相册权限
    func requestsPhotosAuthorization(allow: @escaping ((Bool) -> ())) {
        let state = PHPhotoLibrary.authorizationStatus()
        if state == .notDetermined {
            PHPhotoLibrary.requestAuthorization { authorizationStatus in
                DispatchQueue.main.async {
                    if authorizationStatus == .denied || authorizationStatus == .restricted { allow(false) }
                    else { allow(true) }
                }
            }
        }else if state == .denied || state == .restricted { allow(false) }
        else { allow(true) }
    }
    
    // 获取相机、麦克风权限
    func requestsCameraAuthorization(mediaType: AVMediaType, allow: @escaping ((Bool) -> ())) {
        let states = AVCaptureDevice.authorizationStatus(for: mediaType)
        if states == .notDetermined {
            AVCaptureDevice.requestAccess(for: mediaType) { (success) in
                DispatchQueue.main.async { allow(success) }
            }
        }else if states == .authorized { allow(true)
        }else { allow(false) }
    }
    
}

extension ImagePickerManager {
    
    // 获取图片
    @discardableResult
    func getPhotoWithAsset(_ asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode = .fast, progress: PHAssetImageProgressHandler? = nil, completion: @escaping (UIImage?, Bool) -> ()) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode;
//        option.isNetworkAccessAllowed = true
        option.progressHandler = progress
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { image, info in
            var downloadFinished = false
            if let info = info {
                downloadFinished = !(info[PHImageCancelledKey] as? Bool ?? false) && (info[PHImageErrorKey] == nil)
            }
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool ?? false)
            if downloadFinished {
                let result = self.fixOrientation(aImage: image)
                completion(result, isDegraded)
            }
        }
    }
    
    // 获取相册
    func getAlbumResources(_ mediaType: PHAssetMediaType = .unknown, duration: Int = Int.max, complete: @escaping(_ dataArray: [PhotoAlbumModel]) -> ()) {
        
        DispatchQueue.global().async {
            var array: [PhotoAlbumModel] = []
            let options = PHFetchOptions()
            let smartAlbums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: options)
            
            smartAlbums.enumerateObjects { collection, index, stop in
                let allPhotosOptions = PHFetchOptions()
                if mediaType == .unknown {
                    allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d OR duration <= %d", PHAssetMediaType.image.rawValue, duration)
                }else {
                    allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                }
                if !self.sortAscendingByModificationDate {
                    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
                }
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
                if collection.assetCollectionSubtype == .smartAlbumAllHidden { return }
                if collection.assetCollectionSubtype.rawValue == 1000000201 { return } // [最近删除] 相册

                if fetchResult.count > 0 {
                    let model = PhotoAlbumModel(title: collection.localizedTitle ?? "", asset: fetchResult.lastObject, fetchResult: fetchResult, selectCount: 0, isAllPhotos: collection.assetCollectionSubtype == .smartAlbumUserLibrary)
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
                    allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d OR duration <= %d", PHAssetMediaType.image.rawValue, duration)
                }else {
                    allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                }
                if !self.sortAscendingByModificationDate {
                    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
                }
                
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
                if fetchResult.count > 0 {
                    let model = PhotoAlbumModel(title: collection.localizedTitle ?? "", asset: fetchResult.lastObject, fetchResult: fetchResult, selectCount: 0)
                    array.append(model)
                }
            }
            
            DispatchQueue.main.async {
                complete(array)
            }
            
        }
        
    }
    
    func getPhotoAlbumResources(_ mediaType: PHAssetMediaType = .unknown, successPHAsset: @escaping (PhotoAlbumModel) -> ()) {
        
        DispatchQueue.global().async {
            var mediaTypePhAsset: PHFetchResult<PHAsset> = PHFetchResult()
            // 获取所有资源
            let allPhotosOptions = PHFetchOptions()
            
            if !self.sortAscendingByModificationDate {
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
            }
            if mediaType == .unknown {
                mediaTypePhAsset = PHAsset.fetchAssets(with: allPhotosOptions)
            }else {
                allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
                smartAlbums.enumerateObjects { (collection, row, objc) in
                    if collection.estimatedAssetCount <= 0 { return }
                    if self.isCameraRollAlbm(metadata: collection) {
                        mediaTypePhAsset = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
                        DispatchQueue.main.async {
                            let albumModel = PhotoAlbumModel(title: collection.localizedTitle ?? "", asset: mediaTypePhAsset.lastObject, fetchResult: mediaTypePhAsset, selectCount: 0, isAllPhotos: true)
                            successPHAsset(albumModel)
                        }
                        
                    }
                }
            }
        }
        
    }
    
    fileprivate func isCameraRollAlbm(metadata: PHAssetCollection) -> Bool {
        var versionStr: String = UIDevice.current.systemVersion
        versionStr = versionStr.replacingOccurrences(of: ".", with: "")
        if versionStr.count <= 1 {
            versionStr = "\(versionStr)00"
        }else if versionStr.count <= 2 {
            versionStr = "\(versionStr)0"
        }
        let version: Double =  Double(versionStr) ?? 0.0
        if version >= 800 && version <= 802 {
            return metadata.assetCollectionSubtype == .smartAlbumRecentlyAdded
        }else {
            return metadata.assetCollectionSubtype == .smartAlbumUserLibrary
        }
    }
    
    // MARK:- 获取照片数组
    func getAssetsFromFetchResult(_ result: PHFetchResult<PHAsset>?, completion: (([PhotographModel]) -> ())) {
        guard let `result` = result else {
            completion([])
            return
        }
        var resourcesModelArr: [PhotographModel] = []
        result.enumerateObjects { asset, index, objc in
            let resourceModel = PhotographModel(media: asset, type: self.getAssetType(asset))
            resourcesModelArr.append(resourceModel)
        }
        completion(resourcesModelArr)
    }
    
    func getAssetType(_ asset: PHAsset) -> ImagePickerMediaType {
        var type: ImagePickerMediaType = .photo
        
        if #available(iOS 11, *) {
            switch asset.playbackStyle {
            case .video:
                type = .video
            case .livePhoto:
                type = .livePhoto
            case .imageAnimated:
                type = .gif
            default:
                type = .photo
            }
        } else {
            if asset.mediaType == .video {
                type = .video
            }else if asset.mediaType == .image {
                if let str: String = asset.value(forKey: "filename") as? String, str.hasSuffix("GIF") {
                    type = .gif
                }
            }
        }
        return type
    }
    
    // MARK:- 修改图片转向
    public func fixOrientation(aImage: UIImage?) -> UIImage? {
        if (!shouldFixOrientation) { return aImage }
        guard let `aImage` = aImage else { return nil }
        
        if aImage.imageOrientation == .up {
            return aImage
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
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
        ctx.concatenate(transform)
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
}

