//
//  LAboutApp.swift
//  LImagePicker
//
//  Created by L j on 2020/6/23.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension UIImageView {
    // 获取视频截图
    func l_getNetWorkVidoeImage(urlStr: String, placeholder: String) {
        guard let url = URL(string: urlStr)  else {
            image = UIImage(named: placeholder)
            return
        }
        DispatchQueue.global().async {
            var resultImage: UIImage?
            let asset = AVURLAsset(url: url)
            let gen = AVAssetImageGenerator(asset: asset)
            gen.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 1)
            var actualTime: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
            do {
                let thumbImage = try gen.copyCGImage(at: time, actualTime: &actualTime)
                resultImage = UIImage(cgImage: thumbImage)
            } catch  {
                self.image = UIImage(named: placeholder)
            }
            DispatchQueue.main.async {
                self.image = resultImage
            }
        }
    }
}

struct LAlbumPickerModel {
    /** 标题 */
    var title: String = ""
    /** first PHAsset */
    var asset: PHAsset?
    /** 媒体资源 */
    var fetchResult: PHFetchResult<PHAsset>?
    /** 数量 */
    var count: Int = 0
    /** 选中数量 */
    var selectCount: Int = 0
}
