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

    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    /** 最多可选数量，默认9 */
    fileprivate(set) var maxImageCount: Int = 9
    /** 选中资源 */
    internal var selectArray: [LPhotographModel] = []
    /** 相簿显示样式 */
    internal var photoAlbumType: LPhotoAlbumAccordingType = .photoAlbumBack
    /** 是否允许拍摄照片 */
    public var allowTakePicture: Bool = true
    /** 默认为YES，如果设置为NO, 用户将不能拍摄视频 */
    public var allowTakeVideo: Bool = true
    /** 视频最大拍摄时间，默认是10分钟，单位是秒 */
    public var videoMaximumDuration: TimeInterval = 10
    
    /** 获取图片的超时时间 */
    public var timeout: TimeInterval = 15.0
    /** 默认为NO，如果设置为YES，代理方法里photos中没有数据 */
    public var onlyReturnAsset: Bool = false    
    
    /** 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个 */
    public var sortAscendingByModificationDate: Bool = true {
        didSet {
            LImagePickerManager.shared.sortAscendingByModificationDate = sortAscendingByModificationDate
        }
    }
    /** 是否是查看大图 */
    public var isViewLargerImage: Bool = true
    /** 查看大图返回时需要修改定位的数量，例如前面过滤一个拍照按钮 */
    public var correctionNumber: Int = 0
    
    /** 在单选模式下，照片列表页中，显示选择按钮,默认为false */
    public var showSelectBtn: Bool = false
    /** 允许裁剪,默认为YES，showSelectBtn为false才生效 */
    public var allowCrop: Bool = true
    /** 剪裁框的尺寸 */
    public var cropRect: CGRect = CGRect(x: 0, y: (LConstant.screenHeight - LConstant.screenWidth)/2, width: LConstant.screenWidth, height: LConstant.screenWidth)
    /** 需要圆形剪裁框 */
    public var needCircleCrop: Bool = true
    /** 剪裁的图形是否是圆形 */
    public var cropCircle: Bool = false
    
    
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
    public convenience init(configuration: LPreviewImageModel, delegate: LImagePickerProtocol? = nil) {
        let previewImageVC = LPreviewImageController(configuration: configuration)
        previewImageVC.imagePickerDelegate = delegate
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
