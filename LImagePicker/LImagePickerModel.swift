//
//  LImagePickerModel.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
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
}

// 按钮
enum LImagePickerButtonType {
    /** 关闭 */
    case cancle
    /** 标题 */
    case title
    /** 预览 */
    case preview
    /** 确定 */
    case confirm
    /** 预览选择 */
    case previewSelect
}


// HUD样式
enum LProgressHUDStyle: Int {
    /** */
    case light
    /** */
    case lightBlur
    /**  */
    case dark
    /** */
    case darkBlur
    
    var backColor: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return .darkGray
        default:
            return .clear
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .light, .lightBlur:
            return .black
        default:
            return .white
        }
    }
    
    var indicatorStyle: UIActivityIndicatorView.Style {
        switch self {
        case .light, .lightBlur:
            return .gray
        default:
            return .white
        }
    }
    
    var blurEffectStyle: UIBlurEffect.Style? {
        switch self {
        case .light, .dark:
            return nil
        case .lightBlur:
            return .extraLight
        default:
            return .dark
        }
    }
}

// 相簿显示样式
public enum LPhotoAlbumAccordingType {
    /** 标题下拉 */
    case dropDown
    /** 相册返回 */
    case photoAlbumBack
}


public protocol LImagePickerMediaProtocol { }

extension String: LImagePickerMediaProtocol { }

extension PHAsset: LImagePickerMediaProtocol { }

extension UIImage: LImagePickerMediaProtocol { }

extension LPhotographModel: LImagePickerMediaProtocol { }

// 查看大图模型
public struct LPreviewImageModel {
    /** 当前序号 */
    var currentIndex: Int
    /** 数据源 */
    var dataArray: [LImagePickerMediaProtocol]
    
    public init(currentIndex: Int = 0, dataArray: [LImagePickerMediaProtocol] = [LImagePickerMediaProtocol]()) {
        self.currentIndex = currentIndex
        self.dataArray = dataArray
    }
    
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
    /** 所有照片 */
    var isAllPhotos: Bool = false
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
