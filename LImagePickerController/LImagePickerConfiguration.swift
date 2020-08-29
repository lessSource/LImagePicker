//
//  LImagePickerConfiguration.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/29.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

struct LImagePickerConfiguration {
    
    /** 当前数据 */
    var currentIndex: Int
    
    init(currentIndex: Int = 0) {
        self.currentIndex = currentIndex
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
    
}




