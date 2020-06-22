//
//  LAlbumPickerModel.swift
//  LPublicImageParameter
//
//  Created by L j on 2020/6/18.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos


public protocol LImageDataProtocol { }

extension UIImage: LImageDataProtocol { }

extension String: LImageDataProtocol { }

extension PHAsset: LImageDataProtocol { }

public enum LImageDataEnum {
    case image
    case video
    case audio
    case livePhoto
    case gif
}

public struct LMediaResourcesModel: Equatable {
    /** 资源 */
    public var dataProtocol: LImageDataProtocol
    /** 类型 */
    public var dataEnum: LImageDataEnum
    /** 是否选中 */
    public var isSelect: Bool
    /** 视频时间 */
    public var videoTime: String
    /** 视频封面 */
    public var videoCover: String
    /** 选中序号 */
    public var selectIndex: Int
    /** 描述 */
    public var message: String
    
    init(dataProtocol: LImageDataProtocol, dataEnum: LImageDataEnum, isSelect: Bool = false, videoTime: String = "", videoCover: String = "", selectIndex: Int = 0, message: String = "") {
        self.dataProtocol = dataProtocol
        self.dataEnum = dataEnum
        self.isSelect = isSelect
        self.videoTime = videoTime
        self.videoCover = videoCover
        self.selectIndex = selectIndex
        self.message = message
    }
    
}

public func == (lhs: LMediaResourcesModel, rhs: LMediaResourcesModel) -> Bool {
    if let lhsStr = lhs.dataProtocol as? String, let rhsStr = rhs.dataProtocol as? String {
        return lhsStr == rhsStr
    }else if let lhsAss = lhs.dataProtocol as? PHAsset, let rhsAss = rhs.dataProtocol as? PHAsset {
        return lhsAss.localIdentifier == rhsAss.localIdentifier
    }else if let lhsImg = lhs.dataProtocol as? UIImage, let rhsImg = rhs.dataProtocol as? UIImage {
        return lhsImg == rhsImg
    }
    return false
}
