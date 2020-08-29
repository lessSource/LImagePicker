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
    
    
}
