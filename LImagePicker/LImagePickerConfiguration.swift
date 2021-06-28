//
//  LImagePickerConfiguration.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import Foundation
import UIKit

public class LImagePickerConfiguration {
    // MARK: -
    /** 最少可选数量，默认1 */
    public var minImageCount: Int = 1
    /** 导出图片的宽度，默认宽度828像素宽，你需要同时设置photoPreviewMaxWidth的值 */
    public var photoWidth: CGFloat = 828
    /** 默认600像素宽 */
    public var photoPreviewMaxWidth: CGFloat = 600
    /** 获取图片的超时时间, 当取图片时间超过15.0秒还没有取成功时，会自动dismiss HUD */
    public var timeout: TimeInterval = 15.0
    /** 视频最大拍摄时间，默认是10分钟，单位是秒 */
    public var videoMaximumDuration: TimeInterval = 10
    /** Default is white color with 0.8 alpha */
    public var cannotSelectLayerColor: UIColor = UIColor(white: 1.0, alpha: 0.8)
    /** 查看大图返回时需要修改定位的数量，例如前面过滤一个拍照按钮 */
    public var correctionNumber: Int = 0
    
    
    // MARK：- 权限
    /** 默认为false, 如果设置为false，原图按钮将隐藏，用户不能选择发送原图 */
    public var allowPickingOriginalPhoto: Bool = false
    /** 默认为false，如果设置为false，用户将不能选择视频 */
    public var allowPickingVideo: Bool = false
    /** 默认为false，为true时可以多选视频/gif/图片, 和照片共享最大可选张数maxImagesCount的限制 */
    public var allowPickingMultipleVideo = false
    /** 默认为false，如果为true，用户可以选择gif图片 */
    public var allowPickingGif: Bool = false
    /** 默认为true，如果为false，用户将不能选择图片 */
    public var allowPickingImage: Bool = true
    /** 默认为true，如果为false，用户将不能拍摄照片 */
    public var allowTakePicture: Bool = true
    /** 默认为true，如果设置为false, 用户将不能拍摄视频 */
    public var allowTakeVideo: Bool = true
    /** 默认为true，如果设置为false, 预览按钮将隐藏，用户将不能去预览照片 */
    public var allowPreview: Bool = true
    
    
    // MARK: -
    /** 默认为true，如果设置为false，选择器将不会自己dismiss */
    public var autoDismiss: Bool = true
    /** 默认为false，如果设置为true，代理方法里photos中没有数据 */
    public var onlyReturnAsset: Bool = false
    /** 默认为false，如果设置为true，会显示照片的选中序号 */
    public var showSelectedIndex: Bool = false
    /** 默认是true，如果设置为true，当照片选择张数达到maxImagesCount时，其它照片会显示颜色为cannotSelectLayerColor的浮层 */
    public var showPhotoCannotSelectLayer: Bool = true
    /** 默认是true，如果设置为false，内部会缩放图片到photoWidth像素宽 */
    public var notScaleImage: Bool = true
    /** 默认是false，如果设置为true，导出视频时会修正转向（慎重设为true，可能导致部分安卓下拍的视频导出失败） */
    public var needFixComposition: Bool = false
    /** 让完成按钮一直可以点击，无须至少选一张图片 */
    public var alwaysEnableDoneBtn: Bool = false
    /** 是否使用UIImagePickerController进行拍照 */
    public var allowSystemCamera: Bool = true
    /** 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个 */
    public var sortAscendingByModificationDate: Bool = true {
        didSet {
            LImagePickerManager.shared.sortAscendingByModificationDate = sortAscendingByModificationDate
        }
    }
    
    // MARK: - 裁剪
    // 单选模式，maxImagesCount为1时才生效
    /** 照片列表页中，显示选择按钮,默认为false */
    public var showSelectBtn: Bool = false
    /** 允许剪裁，默认为true，showSelectBtn为false才生效 */
    public var allowCrop: Bool = false
    /** 是否图片等比缩放填充cropRect区域 */
    public var scaleAspectFillCrop: Bool = true
    /** 剪裁框的尺寸 */
    public var cropRect: CGRect = CGRect(x: 0, y: (LConstant.screenHeight - LConstant.screenWidth)/2, width: LConstant.screenWidth, height: LConstant.screenWidth)
    /** 剪裁框的尺寸(竖屏) */
    public var cropRectPortrait: CGRect = CGRect(x: 0, y: (LConstant.screenHeight - LConstant.screenWidth)/2, width: LConstant.screenWidth, height: LConstant.screenWidth)
    /** 剪裁框的尺寸(横屏) */
    public var cropRectLandscape: CGRect = CGRect(x: 0, y: (LConstant.screenHeight - LConstant.screenWidth)/2, width: LConstant.screenWidth, height: LConstant.screenWidth)
    /** 需要圆形剪裁框 */
    public var needCircleCrop: Bool = true
    /** 剪裁的图形是否是圆形 */
    public var cropCircle: Bool = false
    /** 圆形裁剪框半径大小 */
    public var circleCropRadius: CGFloat = LConstant.screenWidth/2
    
}


