//
//  ImagePickerModel.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import Foundation
import Photos
import UIKit

public protocol ImagePickerMediaProtocol { }

extension String: ImagePickerMediaProtocol { }

extension PHAsset: ImagePickerMediaProtocol { }

extension UIImage: ImagePickerMediaProtocol { }

extension PhotographModel: ImagePickerMediaProtocol { }

public struct PreviewImageModel {
    /** 当前序号 */
    var currentIndex: Int
    /** 数据源 */
    var dataArray: [ImagePickerMediaProtocol]
    
    public init(currentIndex: Int = 0, dataArray: [ImagePickerMediaProtocol] = []) {
        self.currentIndex = currentIndex
        self.dataArray = dataArray
    }
    
}


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

// HUD样式
enum ProgressHUDStyle: Int {
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
