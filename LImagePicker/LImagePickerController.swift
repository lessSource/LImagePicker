//
//  LImagePickerController.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

public protocol LImagePickerDelegate: class {
    func imagePickerController(_ picker: LImagePickerController, photos: [UIImage], asset: [LMediaResourcesModel])
}

extension LImagePickerDelegate {
    func imagePickerController(_ picker: LImagePickerController, photos: [UIImage], asset: [LMediaResourcesModel]) { }
}


public class LImagePickerController: UINavigationController {

    weak var imageDelegete: LImagePickerDelegate?
    /** 最多可选数量 默认9 */
    var maxSelectCount: Int = 0
    /** 选中的数据 */
    var selectArray = [LMediaResourcesModel]()
    /** 是否允许选取视频 默认false */
    public var allowPickingVideo: Bool = false
    /** 选择视频最大时间 */
    public var videoSelectMaxDuration: Int = Int.max
    /** 是否允许多选视频/图片 默认false */
    public var allowPickingMultipleVideo: Bool = false
    /** 是否允许拍照 默认false */
    public var allowTakePicture: Bool = false
    /** 是否允许拍摄视频 默认false */
    public var allowTakeVideo: Bool = false
    


    /** 视频最大拍摄时间 默认30s */
    public var videoMaximumDuration: Double = 30.0
    /** 超时时间 默认15秒，当选取图片时间超过15还没取成功时，会自动dismiss */
    public var timeout: Int = 15
    
    deinit {
        print(self, "++++++释放")
    }
    
    public convenience init(withMacImage count: Int = 9, delegate: LImagePickerDelegate?) {
        let albumPickerVC = LAlbumPickerController()
        self.init(rootViewController: albumPickerVC)
        self.imageDelegete = delegate
        self.maxSelectCount = count < 1 ? 1 : count
    }
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.delegate = self
        }
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            let photoPicker = LPhotoPickerController()
            self.pushViewController(photoPicker, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavigationBarHidden(true, animated: true)
        reuquetsPhotosAuthorization()

    }
    
    private func reuquetsPhotosAuthorization() {
        if !LImagePickerManager.shared.reuquetsPhotosAuthorization() {
////            view.placeholderShow(true) { (promptView) in
////                promptView.viewFrame(CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar))
////                promptView.imageName(R.image.icon_permissions.name)
////                promptView.title("请在iPhone的\'设置-隐私-照片'选项中\r允许\(App.appName)访问你的手机相册")
////                promptView.titleLabel.height = 60
////                promptView.imageTop(LConstant.screenHeight/2 - 150)
        ////                promptView.delegate = self
        //            }
                }
    }
    
}

extension LImagePickerController: UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
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
