//
//  LImagePickerManger.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

final class LImagePickerManager {
    
    /** 默认600像素宽 */
    public var photoPreviewMaxWidth: CGFloat = 600
    /** 是否修正图片 */
    public var shouldFixOrientation: Bool = false
    /// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
    public var sortAscendingByModificationDate: Bool = true
    
    static let shared = LImagePickerManager()
    
    private init() { }
    
}

extension LImagePickerManager {
    
    // 获取相册权限
    func requestsPhotosAuthorization(allow: @escaping ((Bool) -> ())) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                DispatchQueue.main.async {
                    if authorizationStatus == .denied || status == .restricted { allow(false)
                    }else { allow(true) }
                }
            }
        }else if status == .denied || status == .restricted { allow(false)
        }else { allow(true) }
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

extension LImagePickerManager {
    
    // 获取图片
    @discardableResult
    func getPhotoWithAsset(_ asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode = .fast, progress: PHAssetImageProgressHandler?, completion: @escaping (UIImage?, Bool) -> ()) -> PHImageRequestID {
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode
        option.isNetworkAccessAllowed = true
        option.progressHandler = progress
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { (image, info) in
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
    func getAlbumResources(_ mediaType: PHAssetMediaType = .unknown, duration: Int = Int.max, complete: @escaping (_ dataArray: [LPhotoAlbumModel]) -> ()) {
        
        DispatchQueue.global().async {
            var array: Array = [LPhotoAlbumModel]()
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
                if !self.sortAscendingByModificationDate {
                    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
                }
                
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
                if collection.assetCollectionSubtype == .smartAlbumAllHidden { return }
                if collection.assetCollectionSubtype.rawValue == 1000000201 { return } // [最近删除] 相册
                
                if fetchResult.count > 0 {
                    let model = LPhotoAlbumModel(title: collection.localizedTitle ?? "", asset: fetchResult.lastObject, fetchResult: fetchResult, selectCount: 0, isAllPhotos: collection.assetCollectionSubtype == .smartAlbumUserLibrary)
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
                if !self.sortAscendingByModificationDate {
                    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)]
                }
                
                let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
                if fetchResult.count > 0 {
                    let model = LPhotoAlbumModel(title: collection.localizedTitle ?? "", asset: fetchResult.lastObject, fetchResult: fetchResult, selectCount: 0)
                    array.append(model)
                }
            }
            DispatchQueue.main.async {
                complete(array)
            }
        }
    }
    
    // MARK: - 获取相册/相册数组
    func getPhotoAlbumResources(_ mediaType: PHAssetMediaType = .unknown, successPHAsset: @escaping (LPhotoAlbumModel) -> ()) {
        
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
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                smartAlbums.enumerateObjects { (collection, row, objc) in
                    if collection.estimatedAssetCount <= 0 { return }
                    if self.isCameraRollAlbm(metadata: collection) {
                        mediaTypePhAsset = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
                        DispatchQueue.main.async {
                            let albumModel = LPhotoAlbumModel(title: collection.localizedTitle ?? "", asset: mediaTypePhAsset.lastObject, fetchResult: mediaTypePhAsset, selectCount: 0, isAllPhotos: true)
                            successPHAsset(albumModel)
                        }
                        
                    }
                }
            }
        }
    }
    
    
    // MARK: - 获取照片数组
    func getAssetsFromFetchResult(_ result: PHFetchResult<PHAsset>?, completion: (([LPhotographModel]) -> ())) {
        guard let `result` = result else {
            completion([])
            return
        }
        var resourcesModelArr: Array = [LPhotographModel]()
        result.enumerateObjects { (asset, idx, objc) in
            let resourceModel = LPhotographModel(media: asset, type: .photo, isSelect: false, selectIndex: 0)
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
    
    // MARK: - 获取asset data
    func requestImageDataForAsset(_ asset: PHAsset, completion: @escaping ((Data?, String?, UIImage.Orientation, [AnyHashable : Any]?) -> ()), progressHandler: PHAssetImageProgressHandler?) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
            options.version = .original
        }
        options.progressHandler = progressHandler
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        options.deliveryMode = .highQualityFormat
        let imageRequestID = PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: completion)
        
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
    
    // 获取一组图片的大小
    fileprivate func getPhotosBytesWith(assetArray: [LPhotographModel], completion: @escaping ((String) -> ())) {
        if assetArray.count == 0 {
            completion("0B")
            return
        }
        var dataLength: Int = 0
        for resourcesModel in assetArray {
            let options = PHImageRequestOptions()
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = true
            if resourcesModel.type == .photoGif {
                options.version = .original
            }
            PHImageManager.default().requestImageData(for: resourcesModel.media, options: options) { (imageData, dataUIT, orientation, info) in
                if let data = imageData {
                    dataLength += data.count
                    
                    if resourcesModel.media == assetArray.last?.media {
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
    

    // 获取优化后的视频转向信息
    fileprivate func fixedCompositionWithAsset(videoAsset: AVAsset) -> AVMutableVideoComposition {
        
        let videoComposition = AVMutableVideoComposition()
        
        let degrees = degressFormVideoFileWithAsset(asset: videoAsset)
        if degrees != 0 {
            var translateToCenter: CGAffineTransform = CGAffineTransform.identity
            var mixedTransform: CGAffineTransform = CGAffineTransform.identity
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

// MARK: - 剪裁图片
extension LImagePickerManager {
    // 获的裁剪后的图片
    public func tz_cropImageView(imageView: UIImageView, rect: CGRect, zoomScale: CGFloat, containerView: UIView) -> UIImage? {
        var transform: CGAffineTransform = CGAffineTransform.identity
        // 平移处理
        let imageViewRect = imageView.convert(imageView.bounds, to: containerView)
        let point = CGPoint(x: imageViewRect.origin.x + imageViewRect.size.width / 2, y: imageViewRect.origin.y + imageViewRect.size.height / 2)
        let xMargin = containerView.frame.size.width - rect.maxX - rect.origin.x
        let zeroPoint = CGPoint(x: (containerView.l_width - xMargin) / 2, y: containerView.center.y)
        let translation = CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
        transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        // 缩放处理
        transform = transform.scaledBy(x: zoomScale, y: zoomScale)
        
        let cgImage = newTransformedImage(transform: transform, sourceImage: imageView.image?.cgImage, soureceSize: imageView.image?.size ?? .zero, outputWidth: rect.size.width * UIScreen.main.scale, cropSize: rect.size, imageViewSize: imageView.frame.size)
        if let cgImage = cgImage {
            var cropedImage: UIImage? = UIImage(cgImage: cgImage)
            cropedImage = fixOrientation(aImage: cropedImage)
            return cropedImage
        }
        return nil
    }
    
    
    fileprivate func newTransformedImage(transform: CGAffineTransform, sourceImage: CGImage?, soureceSize: CGSize, outputWidth: CGFloat, cropSize: CGSize, imageViewSize: CGSize) -> CGImage? {
        guard let source = newScaledImage(sourece: sourceImage, size: soureceSize), let colorSpace = source.colorSpace else {
            return nil
        }
        let aspect = cropSize.height/cropSize.width
        let outputSize = CGSize(width: outputWidth, height: outputWidth * aspect)
        
        let context = CGContext(data: nil, width: Int(outputSize.width), height: Int(outputSize.height), bitsPerComponent: source.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: source.bitmapInfo.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
        
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width , y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width / 2.0, y: cropSize.height / 2.0)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.draw(source, in: CGRect(x: -imageViewSize.width / 2, y: -imageViewSize.height / 2.0, width: imageViewSize.width, height: imageViewSize.height))
        let result = context?.makeImage()
        return result
    }
    
    
    fileprivate func newScaledImage(sourece: CGImage?, size: CGSize) -> CGImage? {
        guard let `sourece` = sourece else { return nil }
        let srcSize = size
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let content: CGContext? = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: rgbColorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        content?.interpolationQuality = .none
        content?.translateBy(x: size.width/2, y: size.height/2)
        content?.draw(sourece, in: CGRect(x: -srcSize.width/2, y: -srcSize.height/2, width: srcSize.width, height: srcSize.height))
        let result = content?.makeImage()
        return result
    }
    
    // 获取圆形图片
    public func tz_circularClipImage(image: UIImage?) -> UIImage? {
        guard let `image` = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: .zero, size: image.size)
        ctx?.addEllipse(in: rect)
        ctx?.clip()
        image.draw(in: rect)
        let circleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return circleImage
    }
    
}

// 保存视频 和图片
extension LImagePickerManager {
    public func savePhotoWithImage(image: UIImage) {
        let assetAlbum = getCreatPhotoAlbum()
        PHPhotoLibrary.shared().performChanges {
            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let saveAlbum = assetAlbum {
                let albumChangeRequset = PHAssetCollectionChangeRequest(for: saveAlbum)
                if let assetPlaceholder = result.placeholderForCreatedAsset {
                    albumChangeRequset?.addAssets([assetPlaceholder] as NSArray)
                }                
            }
        } completionHandler: { (isSuccess, error) in
            
        }
    }
    
    
    fileprivate func getCreatPhotoAlbum() -> PHAssetCollection? {
        let collections: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var assetCollection: PHAssetCollection?
        collections.enumerateObjects { (collection, index, objc) in
            if collection.localizedTitle == LApp.appName {
                assetCollection = collection
            }
        }
        if let collection = assetCollection { return collection }
        var createId: String = ""
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: LApp.appName)
                createId = request.placeholderForCreatedAssetCollection.localIdentifier
            }
            return PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [createId], options: nil).firstObject
        } catch {
            return nil
        }
        
    }
    
}

