//
//  LImagePickerManager.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

final class LImagePickerManager {
    
    /** 默认600像素宽 */
    public var photoPreviewMaxWidth: CGFloat = 600
    
    public var shouldFixOrientation: Bool = false
    
    // 默认4列
    public var columnNumber: Int = 4 {
        didSet {
            configScreenWidth()
            let margin: CGFloat = 4.0
            let itemWH = (LScreenWidth - 2.0 * margin - 4.0) / CGFloat(columnNumber) - margin
            AssetGridThumbnailSize = CGSize(width: itemWH * LScreenScale, height: itemWH * LScreenScale)
        }
    }
    
    fileprivate var LScreenScale: CGFloat = 0.0
    fileprivate var LScreenWidth: CGFloat = 0.0
    fileprivate var AssetGridThumbnailSize: CGSize = .zero
    
    static let shared = LImagePickerManager()
    
    private init() {
        configScreenWidth()
    }
}

extension LImagePickerManager {
    
    fileprivate func configScreenWidth() {
        LScreenWidth = UIScreen.main.bounds.size.width
        
        LScreenScale = 2.0
        if LScreenWidth > 700 {
            LScreenScale = 1.5
        }
    }
    
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
    func getPostImageWithAlbumModel(model: LAlbumPickerModel, completion: @escaping((UIImage?) -> ())) -> PHImageRequestID {
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
    
    
    // MARK: - 获取相册/相册数组
    func getPhotoAlbumResources(_ mediaType: PHAssetMediaType = .unknown, successPHAsset: @escaping (LAlbumPickerModel) -> ()) {
        
        DispatchQueue.global().async {
            var mediaTypePhAsset: PHFetchResult<PHAsset> = PHFetchResult()
            // 获取所有资源
            let allPhotosOptions = PHFetchOptions()
            
            if mediaType == .unknown {
                mediaTypePhAsset = PHAsset.fetchAssets(with: allPhotosOptions)
            }else {
                allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                smartAlbums.enumerateObjects { (collection, row, objc) in
                    if collection.estimatedAssetCount <= 0 { return }
                    if self.isCameraRollAlbm(metadata: collection) {
                        mediaTypePhAsset = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
                        DispatchQueue.main.async {
                            let albumModel = LAlbumPickerModel(title: collection.localizedTitle ?? "", asset: mediaTypePhAsset.lastObject, fetchResult: mediaTypePhAsset, selectCount: 0)
                            successPHAsset(albumModel)
                        }
                        
                    }
                }
            }
        }
    }
    
    // MARK: - 获取照片数组
    func getAssetsFromFetchResult(_ result: PHFetchResult<PHAsset>?, completion: (([LImagePickerResourcesModel]) -> ())) {
        guard let `result` = result else {
            completion([])
            return
        }
        
        var resourcesModelArr: Array = [LImagePickerResourcesModel]()
        result.enumerateObjects { (asset, idx, objc) in
            let resourceModel = LImagePickerResourcesModel(media: asset, type: .photo, isSelect: false, selectIndex: 0)
            resourcesModelArr.append(resourceModel)
        }
        completion(resourcesModelArr)
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
    
    // MARK: - 获取大图
    func requestImageDataForAsset(_ asset: PHAsset, completion: @escaping ((Data?, String?, UIImage.Orientation, [AnyHashable : Any]?) -> ()), progressHandler: PHAssetImageProgressHandler?) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        
        options.progressHandler = { progress, error, stop, info in
            DispatchQueue.main.async {
                progressHandler?(progress, error, stop, info)
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
    
    // MARK: - 获取视频
    func getVideoWithAsset(_ asset: PHAsset, progressHandler: PHAssetVideoProgressHandler?, completion: @escaping ((AVPlayerItem?, [AnyHashable: Any]?) ->())) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.progressHandler = { (progress, error, objc, info) in
            progressHandler?(progress, error, objc, info)
        }
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: option, resultHandler: completion)
    }
    
    // MARK: - 获取图片
    @discardableResult
    func getPhotoWithAsset(_ asset: PHAsset, completion: @escaping (UIImage?, [AnyHashable: Any]?, Bool) -> (), progressHandler: PHAssetImageProgressHandler?, networkAccessAllowed: Bool) -> PHImageRequestID {
        var fullScreenWidth = LScreenWidth
        if photoPreviewMaxWidth > 0 && fullScreenWidth > photoPreviewMaxWidth {
            fullScreenWidth = photoPreviewMaxWidth
        }
        return getPhotoWithAsset(asset, photoWidth: fullScreenWidth, completion: completion, progressHandler: progressHandler, networkAccessAllowed: networkAccessAllowed)
    }
    
    
    @discardableResult
    func getPhotoWithAsset(_ asset: PHAsset, photoWidth: CGFloat, completion: @escaping (UIImage?, [AnyHashable: Any]?, Bool) -> (), progressHandler: PHAssetImageProgressHandler?, networkAccessAllowed: Bool) -> PHImageRequestID {
        var imageSize: CGSize = .zero
        
        if photoWidth < LScreenWidth && photoWidth < photoPreviewMaxWidth {
            imageSize = AssetGridThumbnailSize
        }else {
            let phAsset = asset
            let aspectRation: CGFloat = CGFloat(phAsset.pixelWidth) / CGFloat(phAsset.pixelHeight)
            var pixelWidth = photoWidth * LScreenScale
            
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
            let cancelled: Bool? = info?[PHImageCancelledKey] as? Bool
            if !(cancelled == true) && result != nil {
                let image = self.fixOrientation(aImage: result)
                let isDegraded: Bool = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                completion(image, info, isDegraded)
            }
            
            print(info as Any)
            
            // Dowunload image from iCloud / 从iCloud下载图片
            if (info?[PHImageResultIsInCloudKey] != nil) && result == nil && networkAccessAllowed {
                
                let options = PHImageRequestOptions()
                options.progressHandler = { (progress, error, objc, info) in
                    DispatchQueue.main.async {
                        progressHandler?(progress, error, objc, info)
                    }
                }
                options.isNetworkAccessAllowed = true
                options.resizeMode = .fast
                // iOS 13.0  requestImageDataAndOrientation
                PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
                    guard let `imageData` = imageData else {
                        completion(nil, info, false)
                        return
                    }
                    var resultImage = UIImage(data: imageData)
                    if resultImage == nil && result != nil {
                        resultImage = result
                    }
                    resultImage = self.fixOrientation(aImage: resultImage)
                    completion(resultImage, info, false)
                }
            }
        }
        return imageRequestID
    }
    
    
    // MARK:- 修改图片转向
    fileprivate func fixOrientation(aImage: UIImage?) -> UIImage? {
        if (!shouldFixOrientation) { return aImage }
        guard let `aImage` = aImage else { return nil }
        
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


extension LImagePickerManager {
    // 创建相册

//    eqweqwelj
    
//    static func getCreatPhotoAlbum() -> PHAssetCollection? {
//        let collections: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
//        var assetCollection: PHAssetCollection?
//        collections.enumerateObjects { (collection, i, objc) in
//            if collection.localizedTitle == appName {
//                assetCollection = collection
//            }
//        }
//        if let collection = assetCollection {
//            return collection
//        }
//        var createID: String = ""
//        do {
//            try PHPhotoLibrary.shared().performChangesAndWait {
//                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: appName)
//                createID = request.placeholderForCreatedAssetCollection.localIdentifier
//            }
//            return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [createID], options: nil).firstObject
//        } catch {
//            return nil
//        }
//    }
    
    
    
    // 保存图片
    fileprivate func savePhotoWithImage(image: UIImage, location: CLLocation?, completion: @escaping ((PHAsset, Error?) -> ())) {
        var localIdentifier = ""
        
        PHPhotoLibrary.shared().performChanges({
            let reuqest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIdentifier = reuqest.placeholderForCreatedAsset?.localIdentifier ?? ""
            reuqest.location = location
            reuqest.creationDate = Date()
        }) { (success, error) in
            
            DispatchQueue.main.async {
                if success {
                    self.fetchAssetByIocalIdentifier(localIdentifier: localIdentifier, retryCount: 10, completion: completion)
                }else {
                    // 保存图片出错
                }
            }
            
        }
        
    }
    
//    static func savePhotoCustomAlbum(image: UIImage) {
//        
//    }
    
    fileprivate func savePhotoWithImage(image: UIImage, meta: Dictionary<String, String>, location: CLLocation?, completion: @escaping ((PHAsset, Error?) -> ())) {
        
        guard let imageData: CFData = image.jpegData(compressionQuality: 1.0) as CFData? else {
            return
        }
        
        
        let source = CGImageSourceCreateWithData(imageData, nil)
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH:mm:ss-SSS"
        let urlStr = formater.string(from: Date())
        let path = "\(NSTemporaryDirectory()).image-\(urlStr).jpg"
        let temURL = URL(fileURLWithPath: path)
        
        guard let destination = CGImageDestinationCreateWithURL(temURL as CFURL, kUTTypeJPEG, 1, nil), let source0 = source else {
            return
        }
        CGImageDestinationAddImageFromSource(destination, source0, 0, meta as CFDictionary)
        CGImageDestinationFinalize(destination)
        //        CFreleass
        
        var localIdentifier = ""
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: temURL)
            localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier ?? ""
            request?.location = location
            request?.creationDate = Date()
        }) { (success, error) in
            try? FileManager.default.removeItem(atPath: path)
            
            DispatchQueue.main.async {
                if success {
                    self.fetchAssetByIocalIdentifier(localIdentifier: localIdentifier, retryCount: 10, completion: completion)
                }else {
                    // 保存图片出错
                }
            }
            
        }
        
        
    }
    
    
    
    // 导出视频
    fileprivate func getVideoOutputPathWithAsset(asset: PHAsset, presetName: String) {
        
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avasset, audioMix, info) in
            guard let avAsset = avasset as? AVURLAsset else {
                return
            }
            self.startExportVideoWithAsset(videoAsset: avAsset, presetName: presetName)
        }
        
    }
    
    
    fileprivate func startExportVideoWithAsset(videoAsset: AVURLAsset, presetName: String) {
        
        guard let exportSession = AVAssetExportSession(asset: videoAsset, presetName: presetName) else {
            let errorMessage = "当前设备不支持该预设: \(presetName)"
            return
            
        }
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd-HH:mm:ss-SSS"
        let dateStr = formater.string(from: Date())
        var outputPath = NSHomeDirectory() + "/tem/video-\(dateStr).mp4"
        
        
        exportSession.shouldOptimizeForNetworkUse = true
        
        let supportedTypeArray = exportSession.supportedFileTypes
        if supportedTypeArray.contains(.mp4) {
            exportSession.outputFileType = .mp4
        }else if supportedTypeArray.count == 0 {
            // 失败
            return
        }else {
            exportSession.outputFileType = supportedTypeArray.first
            //            if videoAsset.url && videoAsset.url.lastPathComponent {
            //
            //            }
            // 替换URL
            
            
        }
        exportSession.outputURL = URL(fileURLWithPath: outputPath)
        //
        let filePath = "\(NSHomeDirectory())/tmp"
        
        if !FileManager.default.fileExists(atPath: filePath) {
            
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
        
        // 修改视频转向
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .unknown:
                    print("unknown")
                case .waiting:
                    print("waiting")
                case .exporting:
                    print("exporting")
                case .completed:
                    print("completed")
                // 成功
                case .failed:
                    print("failed")
                // 视频导出失败
                case .cancelled:
                    print("cancelled")
                // 导出任务失败
                default: break
                }
            }
        }
        
    }
    
    fileprivate func fetchAssetByIocalIdentifier(localIdentifier: String, retryCount: Int, completion: @escaping ((PHAsset, Error?) -> ())) {
        
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
        if asset != nil || retryCount <= 0 {
            completion(asset!, nil)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchAssetByIocalIdentifier(localIdentifier: localIdentifier, retryCount: retryCount - 1, completion: completion)
        }
        
    }
    
    
    // 获取优化后的视频转向信息
    fileprivate func fixedCompositionWithAsset(videoAsset: AVAsset) -> AVMutableVideoComposition {
        
        let videoComposition = AVMutableVideoComposition()
        
        let degrees = degressFormVideoFileWithAsset(asset: videoAsset)
        if degrees != 0 {
            var translateToCenter: CGAffineTransform = CGAffineTransform()
            var mixedTransform: CGAffineTransform = CGAffineTransform()
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            
            let tracks = videoAsset.tracks(withMediaType: .video)
            let videoTrack = tracks[0]
            
            let roateInstruction = AVMutableVideoCompositionInstruction()
            roateInstruction.timeRange = CMTimeRange(start: .zero, duration: videoAsset.duration)
            let roateLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            
            if degrees == 90 {
                // 顺时针旋转90度
                translateToCenter = CGAffineTransform(scaleX: videoTrack.naturalSize.height, y: 0.0)
                mixedTransform = translateToCenter.rotated(by: CGFloat.pi/2)
                videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
                roateLayerInstruction.setTransform(mixedTransform, at: .zero)
            }else if (degrees == 180) {
                // 顺时针旋转180°
                translateToCenter = CGAffineTransform(scaleX: videoTrack.naturalSize.width, y: videoTrack.naturalSize.height)
                mixedTransform = translateToCenter.rotated(by: CGFloat.pi)
                videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
                roateLayerInstruction.setTransform(mixedTransform, at: .zero)
                
            }else if (degrees == 270) {
                // 顺时针旋转270°
                translateToCenter = CGAffineTransform(scaleX: 0.0, y: videoTrack.naturalSize.width)
                mixedTransform = translateToCenter.rotated(by: CGFloat.pi/2 * 3.0)
                videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
                roateLayerInstruction.setTransform(mixedTransform, at: .zero)
            }
            
            roateInstruction.layerInstructions = [roateLayerInstruction]
            videoComposition.instructions = [roateInstruction]
        }
        
        return videoComposition
    }
    
    // 获取视频角度
    fileprivate func degressFormVideoFileWithAsset(asset: AVAsset) -> Int {
        
        var degress: Int = 0
        let tracks = asset.tracks(withMediaType: .video)
        if tracks.count > 0 {
            let videoTrack = tracks[0]
            let transform = videoTrack.preferredTransform
            if transform.a == 0.0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0.0 {
                // Portrait
                degress = 90
            }else if transform.a == 0.0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0.0 {
                // PortraitUpsideDown
                degress = 270
            }else if transform.a == 1.0 && transform.b == 0.0 && transform.c == 0.0 && transform.d == 1.0 {
                // LandscapeRight
                degress = 0
            }else if transform.a == -1.0 && transform.b == 0.0 && transform.c == 0.0 && transform.d == -1.0 {
                // LandscapeLeft
                degress = 180
            }
        }
        
        return degress
    }
}
