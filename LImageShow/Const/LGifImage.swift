//
//  LGifImage.swift
//  LImageShow
//
//  Created by L j on 2020/6/19.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import ImageIO
import CoreServices


//class ImagePickerGifImage {
//    let images: [UIImage]
//    let duration: TimeInterval
//    
//    init?(from imageData: Data) {
//        /***/
//        // kCGImageSourceShouldCache : 表示是否在存储的时候就解码
//        // kCGImageSourceTypeIdentifierHint : 指明source type
//        let options: [String: Any] = [
//            kCGImageSourceShouldCache as String: true,
//            kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
//        ]
//        
//        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, options as CFDictionary) else {
//            return nil
//        }
//        
//        let frameCount = CGImageSourceGetCount(imageSource)
//        var images = [UIImage]()
//        var gifDuration = 0.0
//        
//        for i in 0..<frameCount {
//            guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, options as CFDictionary) else { return nil }
//            
//            if frameCount == 1 {
//                gifDuration = .infinity
//            }else {
//                // 获取当前动画GIF帧的持续时间
//                gifDuration += ImagePickerGifImage.getFrameDuration(from: imageSource, at: i)
//            }
//            images.append(UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: .up))
//            
//        }
//        self.images = images
//        self.duration = gifDuration
//    }
//    
//    // 从“imageSource”中为gif计算特定索引处的帧持续时间。
//    static func getFrameDuration(from imageSourece: CGImageSource, at index: Int) -> TimeInterval {
//        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSourece, index, nil) as? [String: Any] else { return 0.0 }
//        let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any]
//        return getFrameDuration(from: gifInfo)
//    }
//    
//    // 计算gif每帧持续时间
//    static func getFrameDuration(from gifInfo: [String: Any]?) -> TimeInterval {
//        let defaultFrameDuration = 0.1
//        guard let gifInfo = gifInfo else { return defaultFrameDuration }
//        let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
//        let delatTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber
//        let duration = unclampedDelayTime ?? delatTime
//        guard let frameDuration = duration else { return defaultFrameDuration }
//        return frameDuration.doubleValue > 0.011 ? frameDuration.doubleValue : defaultFrameDuration
//    }
//}
