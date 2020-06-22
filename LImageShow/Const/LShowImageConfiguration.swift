//
//  LShowImageConfiguration.swift
//  LImageShow
//
//  Created by L j on 2020/6/19.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

/** 选择类型 */
enum LImagePickerSelectEnum {
    case `default`
    case image
    case video
}


public struct LShowImageConfiguration {
    /** 数据源 */
    var dataArray: [LMediaResourcesModel]
    /** 当前数据 */
    var currentIndex: Int
    /** 最多可以选择 */
    var maxCount: Int
    /** 选中数量 */
    var selectCount: Int
    /** 是否加载原图 */
    var isOriginalImage: Bool
    /** 选择类型 */
    var selectType: LImagePickerSelectEnum
    
    /** 是否可以删除 */
    var isDelete: Bool
    /** 是否可以选择 */
    var isSelect: Bool
    /** 是否保存 */
    var isSave: Bool

    
    init(dataArray: [LMediaResourcesModel] = [], currentIndex: Int = 0, isDelete: Bool = false, isSelect: Bool = false, isSave: Bool = false,selectCount: Int = 0, maxCount: Int = 0, isOriginalImage: Bool = false, selectType: LImagePickerSelectEnum = .default) {
        self.dataArray = dataArray
        self.currentIndex = currentIndex
        self.isDelete = isDelete
        self.isSelect = isSelect
        self.isSave = isSave
        self.selectCount = selectCount
        self.maxCount = maxCount
        self.isOriginalImage = isOriginalImage
        self.selectType = selectType
    }
}
