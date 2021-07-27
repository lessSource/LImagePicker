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
    /** 默认为false，如果设置为true，代理方法里photos中没有数据 */
    public var onlyReturnAsset: Bool = false
    /** 获取图片的超时时间, 当取图片时间超过15.0秒还没有取成功时，会自动dismiss HUD */
    public var timeout: TimeInterval = 15.0
    
    // MARK：- 权限
    /** 默认为true，如果为false，用户将不能拍摄照片 */
    public var allowTakePicture: Bool = true
    /** 默认为true，如果设置为false, 用户将不能拍摄视频 */
    public var allowTakeVideo: Bool = true
    /** 默认为false, 如果设置为true,完成按钮一直可以点击，无须至少选一张图片 */
    public var alwaysEnableDoneBtn: Bool = false
    /** 默认为true，如果设置为false, 预览按钮将隐藏，用户将不能去预览照片 */
    public var allowPreview: Bool = true
    /** 默认为false, 如果设置为false，原图按钮将隐藏，用户不能选择发送原图 */
    public var allowPickingOriginalPhoto: Bool = false
    /** 默认为false，如果设置为false，用户将不能选择视频 */
    public var allowPickingVideo: Bool = false
    
    
    // MARK:- 裁剪 (单选模式，maxCount为1时才生效)
    /** 默认是false，如果设置为ture，照片列表显示选择按钮 */
    public var showSelectBtn: Bool = false
    
    public init() { }
    
}

/** 相簿显示样式 */
public enum PhotoAlbumAccordingType {
    /** 标题下拉 */
    case dropDown
    /** 相册返回 */
    case photoAlbumBack
    
}
