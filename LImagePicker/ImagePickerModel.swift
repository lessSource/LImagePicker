//
//  ImagePickerModel.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import Foundation
import Photos

// 媒体类型
enum ImagePickerMediaType {
    /** 拍照icon */
    case shooting
    /** 图片 */
    case photo
    /** 动态图 */
    case livePhoto
    /** gif */
    case gif
    /** 视频 */
    case video
}

// 相册模型
struct PhotoAlbumModel {
    /** 标题 */
    var title: String = ""
    /** first PHAsset */
    var asset: PHAsset?
    /** 媒体资源 */
    var fetchResult: PHFetchResult<PHAsset>?
    /** 选中数量 */
    var selectCount: Int = 0
    /** 所有照片 */
    var isAllPhotos: Bool = false
}

class PhotographModel: Equatable {
    /** 媒体资源 */
    var media: PHAsset
    /** 媒体类型 */
    var type: ImagePickerMediaType
    /** 是否选中 */
    var isSelect: Bool
    /** 选中序号 */
    var selectIndex: Int
    
    init(media: PHAsset, type: ImagePickerMediaType, isSelect: Bool = false, selectIndex: Int = 0) {
        self.media = media
        self.type = type
        self.isSelect = isSelect
        self.selectIndex = selectIndex
    }
}

func == (lhs: PhotographModel, rhs: PhotographModel) -> Bool {
    return lhs.media.localIdentifier == rhs.media.localIdentifier
}
