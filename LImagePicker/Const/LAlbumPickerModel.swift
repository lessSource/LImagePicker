//
//  LAlbumPickerModel.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

public protocol ImageDataProtocol { }

extension UIImage: ImageDataProtocol { }

extension String: ImageDataProtocol { }

extension PHAsset: ImageDataProtocol { }

enum ImageDataEnum {
    case image
    case video
    case audio
    case livePhoto
    case gif
}

/** 选择类型 */
enum LImagePickerSelectEnum {
    case `default`
    case image
    case video
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

struct ShowImageConfiguration {
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

struct LMediaResourcesModel: Equatable {
    /** 资源 */
    public var dataProtocol: ImageDataProtocol
    /** 类型 */
    var dateEnum: ImageDataEnum
    /** 是否选中 */
    var isSelect: Bool
    /** 视频时间 */
    var videoTime: String
    /** 视频封面 */
    var videoCover: String
    /** 选中序号 */
    var selectIndex: Int
    /** 描述 */
    var message: String
    
    init(dataProtocol: ImageDataProtocol, dateEnum: ImageDataEnum,isSelect: Bool = false, videoTime: String = "", videoCover: String = "", selectIndex: Int = 0, message: String = "") {
        self.dataProtocol = dataProtocol
        self.dateEnum = dateEnum
        self.isSelect = isSelect
        self.videoTime = videoTime
        self.videoCover = videoCover
        self.selectIndex = selectIndex
        self.message = message
    }
}

func ==(lhs: LMediaResourcesModel, rhs: LMediaResourcesModel) -> Bool {
    if let lhsStr = lhs.dataProtocol as? String, let rhsStr = rhs.dataProtocol as? String {
        return lhsStr == rhsStr
    }else if let lhsAss = lhs.dataProtocol as? PHAsset, let rhsAss = rhs.dataProtocol as? PHAsset {
        return lhsAss.localIdentifier == rhsAss.localIdentifier
    }else if let lhsImg = lhs.dataProtocol as? UIImage, let rhsImg = rhs.dataProtocol as? UIImage {
        return lhsImg == rhsImg
    }
    return false
}
