//
//  LImagePickerModel.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import Foundation
import Photos

// 媒体类型
enum LImagePickerMediaType {
    /** 拍照icon */
    case shooting
    /** 图片 */
    case photo
    /** 动态图 */
    case livePhoto
    /** gif */
    case photoGif
    /** 视频 */
    case video
    /** 音频 */
    case audio
}

// 相册模型
struct LPhotoAlbumModel {
    /** 标题 */
    var title: String = ""
    /** first PHAsset */
    var asset: PHAsset?
    /** 媒体资源 */
    var fetchResult: PHFetchResult<PHAsset>?
    /** 选中数量 */
    var selectCount: Int = 0
}

// 图片模型
class LPhotographModel: Equatable {
    
    /** 媒体资源 */
    var media: PHAsset
    /** 媒体类型 */
    var type: LImagePickerMediaType
    /** 是否选中 */
    var isSelect: Bool
    /** 选中序号 */
    var selectIndex: Int
    
    init(media: PHAsset, type: LImagePickerMediaType, isSelect: Bool = false, selectIndex: Int = 0) {
        self.media = media
        self.type = type
        self.isSelect = isSelect
        self.selectIndex = selectIndex
    }
    
}


func == (lhs: LPhotographModel, rhs: LPhotographModel) -> Bool {
    return lhs.media.localIdentifier == rhs.media.localIdentifier
}
