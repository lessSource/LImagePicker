//
//  ImagePickerConfiguration.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import Foundation
import UIKit

public struct ImagePickerConfiguration {
    
    // MARK: - 基础
    /** 相簿显示样式 */
    public var photoAlbumType: PhotoAlbumAccordingType = .photoAlbumBack
    /** 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个 */
    public var sortAscendingByModificationDate: Bool = true {
        didSet {
            ImagePickerManager.shared.sortAscendingByModificationDate = sortAscendingByModificationDate
        }
    }
    
    
    // MARK：- 权限
    /** 默认为true，如果为false，用户将不能拍摄照片 */
    public var allowTakePicture: Bool = true
    /** 默认为true，如果设置为false, 用户将不能拍摄视频 */
    public var allowTakeVideo: Bool = true
    
    
    
    public init() { }
    
}

/** 相簿显示样式 */
public enum PhotoAlbumAccordingType {
    /** 标题下拉 */
    case dropDown
    /** 相册返回 */
    case photoAlbumBack
    
}
