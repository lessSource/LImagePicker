//
//  LImagePickerContrller.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

public class LImagePickerController: LImagePickerNavigationController {

    /** 最多可选数量，默认9 */
    fileprivate(set) var maxImageCount: Int = 9
    /** 最少可选数量，默认1 */
    public var minImageCount: Int = 1
    /** 让完成按钮一直可以点击，无须至少选一张图片 */
    public var alwaysEnableDoneBtn: Bool = false
    /** 相簿显示样式 */
    internal var photoAlbumType: LPhotoAlbumAccordingType = .photoAlbumBack
    /** 是否使用UIImagePickerController进行拍照 */
    public var allowSystemCamera: Bool = true
    
    /** 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个 */
    public var sortAscendingByModificationDate: Bool = true {
        didSet {
            LImagePickerManager.shared.sortAscendingByModificationDate = sortAscendingByModificationDate
        }
    }
    /** 导出图片的宽度，默认宽度828像素宽，你需要同时设置photoPreviewMaxWidth的值 */
    public var photoWidth: CGFloat = 828
    /** 默认600像素宽 */
    public var photoPreviewMaxWidth: CGFloat = 600
    /** 获取图片的超时时间, 当取图片时间超过15.0秒还没有取成功时，会自动dismiss HUD */
    public var timeout: TimeInterval = 15.0
    /** 默认为true, 如果设置为false，原图按钮将隐藏，用户不能选择发送原图 */
    public var allowPickingOriginalPhoto: Bool = true
    /** 默认为true，如果设置为false，用户将不能选择视频 */
    public var allowPickingVideo: Bool = true
    /** 默认为false，为true时可以多选视频/gif/图片, 和照片共享最大可选张数maxImagesCount的限制 */
    public var allowPickingMultipleVideo = false
    /** 默认为false，如果为true，用户可以选择gif图片 */
    public var allowPickingGif: Bool = false
    /** 默认为true，如果为false，用户将不能选择发送图片 */
    public var allowPickingImage: Bool = true
    /** 是否允许拍摄照片 */
    public var allowTakePicture: Bool = true
    /** 默认为true，如果设置为false, 用户将不能拍摄视频 */
    public var allowTakeVideo: Bool = true
    /** 视频最大拍摄时间，默认是10分钟，单位是秒 */
    public var videoMaximumDuration: TimeInterval = 10
    /** 默认为true，如果设置为false, 预览按钮将隐藏，用户将不能去预览照片 */
    public var allowPreview: Bool = true
    /** 默认为true，如果设置为false，选择器将不会自己dismiss */
    public var autoDismiss: Bool = true
    /** 默认为false，如果设置为true，代理方法里photos中没有数据 */
    public var onlyReturnAsset: Bool = false
    /** 默认为false，如果设置为true，会显示照片的选中序号 */
    public var showSelectedIndex: Bool = false
    /** 默认是true，如果设置为YES，当照片选择张数达到maxImagesCount时，其它照片会显示颜色为cannotSelectLayerColor的浮层 */
    public var showPhotoCannotSelectLayer: Bool = true
    /** Default is white color with 0.8 alpha */
    public var cannotSelectLayerColor: UIColor = UIColor(white: 1.0, alpha: 0.8)
    /** 默认是true，如果设置为false，内部会缩放图片到photoWidth像素宽 */
    public var notScaleImage: Bool = true
    /** 默认是false，如果设置为true，导出视频时会修正转向（慎重设为true，可能导致部分安卓下拍的视频导出失败） */
    public var needFixComposition: Bool = false
    /** 选中资源 */
    internal var selectArray: [LPhotographModel] = []
    /** 是否是查看大图 */
    public var isViewLargerImage: Bool = true
    /** 查看大图编辑 */
    public var isViewLargerEditorImage: Bool = true
    /** 查看大图返回时需要修改定位的数量，例如前面过滤一个拍照按钮 */
    public var correctionNumber: Int = 0
    
    // MARK: - 裁剪
    // 单选模式，maxImagesCount为1时才生效
    /** 在单选模式下，照片列表页中，显示选择按钮,默认为false */
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
    
    


    
    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    fileprivate override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.backColor
        self.modalPresentationStyle = .custom
        delegate = self
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(self, "++++++释放")
    }
}

extension LImagePickerController {
    
    /** 选择图片 */
    public convenience init(withMaxImage count: Int = 9, delegate: LImagePickerProtocol? = nil, photoAlbumType: LPhotoAlbumAccordingType = .photoAlbumBack) {
        if photoAlbumType == .dropDown {
            let photographVC = LPhotographController()
            photographVC.imagePickerDelegate = delegate
            self.init(rootViewController: photographVC)
        }else {
            let photoAlbumVC = LPhotoAlbumController()
            self.init(rootViewController: photoAlbumVC)
            let photographVC = LPhotographController()
            photographVC.imagePickerDelegate = delegate
            pushViewController(photographVC, animated: true)
        }
        self.maxImageCount = count
        self.photoAlbumType = photoAlbumType
    }
    
    /** 显示大图 */
    public convenience init(configuration: LPreviewImageModel, delegate: LImagePickerProtocol? = nil, isPreview: Bool = true, correctionNumber: Int = 0) {
        let previewImageVC = LPreviewImageController(configuration: configuration)
        previewImageVC.imagePickerDelegate = delegate
        previewImageVC.isPreview = isPreview
        previewImageVC.correctionNumber = correctionNumber
        self.init(rootViewController: previewImageVC)
    }
    
    /** 拍照 */
    public convenience init(allowPickingVideo: Bool, maxDuration: TimeInterval = 15, delegate: LImagePickerProtocol? = nil) {
        let takingPicturesVC = LTakingPicturesController(allowPickingVideo: allowPickingVideo, maxDuration: maxDuration)
        takingPicturesVC.imagePickerDelegate = delegate
        self.init(rootViewController: takingPicturesVC)
    }
    
    /** 编辑 */
    public convenience init(contentMedia: LImagePickerMediaProtocol, delegate: LImagePickerProtocol? = nil) {
        let editPicturesVC = LEditPicturesController(mediaProtocol: contentMedia)
        editPicturesVC.imagePickerDelegate = delegate
        self.init(rootViewController: editPicturesVC)
    }
    
    /** 显示视频 */
    public convenience init(videoUrl: URL, delegate: LImagePickerProtocol? = nil) {
        let previewVideoVC = LPreviewVideoController()
        previewVideoVC.imagePickerDelegate = delegate
        self.init(rootViewController: previewVideoVC)
    }
    
    
}
 
extension LImagePickerController: UIGestureRecognizerDelegate, UINavigationControllerDelegate, LPromptViewDelegate {
    
    func promptViewImageClick(_ promptView: LImagePickerPromptView) {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [: ], completionHandler: nil)
        }
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count != 1
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
        if navigationController.viewControllers.count == 1 {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
            navigationController.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
        super.pushViewController(viewController, animated: true)
    }
}
