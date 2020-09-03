//
//  LImagePickerConfiguration.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/29.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

enum LImagePickerMediaType {
    case photo
    case livePhoto
    case photoGif
    case video
    case audio
}

public protocol LImagePickerMediaProtocol { }

extension String: LImagePickerMediaProtocol { }

extension PHAsset: LImagePickerMediaProtocol { }

extension UIImage: LImagePickerMediaProtocol { }

public struct LImagePickerConfiguration {
    
    /** 当前数据 */
    var currentIndex: Int
    /** 数据源 */
    var dataArray: [LImagePickerMediaProtocol]
    
    public init(currentIndex: Int = 0, dataArray: Array<LImagePickerMediaProtocol> = [LImagePickerMediaProtocol]()) {
        self.currentIndex = currentIndex
        self.dataArray = dataArray
    }
    
}

struct LAlbumPickerModel {
    /** 标题 */
    var title: String = ""
    /** first PHAsset */
    var asset: PHAsset?
    /** 媒体资源 */
    var fetchResult: PHFetchResult<PHAsset>?
    /** 选中数量 */
    var selectCount: Int = 0
}

struct LImagePickerResourcesModel {
    
    /** 媒体资源 */
    var media: LImagePickerMediaProtocol
    /** 媒体类型 */
    var type: LImagePickerMediaType
    /** 是否选中 */
    var isSelect: Bool
    /** 选中序号 */
    var selectIndex: Int
    
    init(media: LImagePickerMediaProtocol, type: LImagePickerMediaType, isSelect: Bool, selectIndex: Int) {
        self.media = media
        self.type = type
        self.isSelect = isSelect
        self.selectIndex = selectIndex
    }
    
    
}




