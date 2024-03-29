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
        option.isNetworkAccessAllowed = true
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
    
    // 获取原图
    @discardableResult
    func getOriginalPhotoWithAsset(asset: PHAsset, progressHandler: PHAssetImageProgressHandler?, completion: @escaping (UIImage?, Bool) -> ()) -> PHImageRequestID {
        return getPhotoWithAsset(asset, size: PHImageManagerMaximumSize, resizeMode: .fast, progress: progressHandler, completion: completion)
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
            var timeLength = ""
            if self.getAssetType(asset) == .video {
                timeLength = self.getNewTimeFromDurationSecond(duration: Int(asset.duration))
            }
            let resourceModel = PhotographModel(media: asset, type: self.getAssetType(asset), timeLength: timeLength)
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
    
    // MARK:- Get Video 获取视频
    public func getVideoWithAsset(asset: PHAsset, progressHandler: PHAssetImageProgressHandler? = nil, resultHandler: @escaping (AVPlayerItem?, [AnyHashable: Any]?) -> ()) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (progress, error, stop, info) in
            DispatchQueue.main.async {
                progressHandler?(progress, error, stop, info)
            }
        }
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: option, resultHandler: resultHandler)
    }
    
    // MARK:- Export video
//    public func getVideoOutputPathWithAsset(asset: PHAsset, success: (NSString, Error))
    
    
    public func getVideoOutputPathWithAsset(asset: PHAsset, presetName: NSString, timeRange: CMTimeRange) {
        
        
        
    }
    
    public func requestVideoOutputPathWithAsset(asset: PHAsset, presetName: String, timeRange: CMTimeRange, success: ((String) -> ())?, failure: ((String, Error?) -> ())? = nil) {
        var preset = presetName
        if preset != "" {
            preset = AVAssetExportPresetMediumQuality
        }
        PHImageManager.default().requestExportSession(forVideo: asset, options: getVideoRequestOptions(), exportPreset: preset) { exportSeccion, info in
            let outputPath = self.getVideoOutputPath()
            exportSeccion?.outputURL = URL(fileURLWithPath: outputPath)
            exportSeccion?.shouldOptimizeForNetworkUse = false
            exportSeccion?.outputFileType = .mp4
            if !CMTimeRangeEqual(timeRange, CMTimeRange.zero) {
                exportSeccion?.timeRange = timeRange
            }
            exportSeccion?.exportAsynchronously(completionHandler: {
                self.handleVideoExportResult(session: exportSeccion, outputPath: outputPath, success: success, failure: failure)
            })
        }
        
    }
    
    fileprivate func handleVideoExportResult(session: AVAssetExportSession?, outputPath: String, success: ((String) -> ())?, failure: ((String, Error?) -> ())? = nil) {
        DispatchQueue.main.async {
            guard let `session` = session else {
                failure?("视频导出失败", session?.error)
                return
            }
            
            switch session.status {
            case .unknown:
                print("unknown")
            case .waiting:
                print("waiting")
            case .exporting:
                print("exporting")
            case .completed:
                print("completed")
                success?(outputPath)
            case .failed:
                print("failed")
                failure?("视频导出失败", session.error)
            case .cancelled:
                print("cancelled")
                failure?("导出任务已取消", session.error)
            default: break
            }
        }
    }
    
    
    fileprivate func getVideoRequestOptions() -> PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        return options
    }
    
    fileprivate func getVideoOutputPath() -> String {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
        let outputPath = NSHomeDirectory().appending("/tem/video-\(formater.string(from: Date()))-\(arc4random_uniform(1000000))")
        return outputPath
    }
    
    fileprivate func getNewTimeFromDurationSecond(duration: Int) -> String {
        var newTime = "00:00"
        switch duration {
        case 0..<10:
            newTime = "00:0\(duration)"
        case 10...60:
            newTime = "00:\(duration)"
        default:
            let min = duration/60
            let sec = duration - (min * 60)
            if min < 10 {
                if sec < 10  {
                    newTime = "0\(min):0\(sec)"
                }else {
                    newTime = "0\(min):\(sec)"
                }
            }else {
                if sec < 10  {
                    newTime = "\(min):0\(sec)"
                }else {
                    newTime = "\(min):\(sec)"
                }
            }
        }
        return newTime
    }
    
    /// 视频分解成帧
    /// - Parameters:
    ///   - fileAsset: 视频资源
    ///   - fps: 自定义帧数，每秒内取得帧数
    func splitVideoFileUrlFps(fileAsset: AVAsset, fps: Double) {
        
        // 视频总秒数
        let durationSeconds = fileAsset.duration.seconds
        
        var times = [NSValue]()
        let totalFrames: Int = Int(durationSeconds * fps)
        
        for i in 0...totalFrames {
            let timeFrame = CMTimeMake(value: Int64(i), timescale: Int32(fps))
            let value = NSValue(time: timeFrame)
            times.append(value)
        }
        
        let imgGenerator = AVAssetImageGenerator(asset: fileAsset)
        imgGenerator.requestedTimeToleranceBefore = .zero // 防止时间出现偏差
        imgGenerator.requestedTimeToleranceAfter = .zero
        
        let timesCount = times.count
        
        // 获取每一帧的图片
        imgGenerator.generateCGImagesAsynchronously(forTimes: times) { requestedTime, image, actualTime, result, error in
            print("current-----\(requestedTime.value)   timesCount == \(timesCount)")
            print("timeScale-----\(requestedTime.timescale) requestedTime:\(requestedTime.value)")

//            var isSuccess = false
            switch result {
            case .cancelled:
                print("cancelled")
            case .failed:
                print("failed")
            case .succeeded:
                guard let cgImage = image else {
                    return
                }
                let framImg = UIImage(cgImage: cgImage)
                print(framImg)
            default: break
            
            
            }
            
        }
        
        
        
    }
    
    
}



