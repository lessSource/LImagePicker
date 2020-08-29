//
//  LImagePickerController.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

public protocol LImagePickerViewDelegate: class {
    
}

extension LImagePickerViewDelegate {
    
}

public class LImagePickerController: UINavigationController {
    // 选择视频图片代理
    fileprivate weak var imageDelegate: LImagePickerViewDelegate?
    /** 最多可选数量，默认9 */
    fileprivate(set) var maxSelectCount: Int = 9

    /** 选择图片 */
    public convenience init(withMaxImage count: Int = 9, delegate: LImagePickerViewDelegate?) {
        let albumPickerVC = LAlbumPickerController()
        self.init(rootViewController: albumPickerVC)
        self.imageDelegate = delegate
        self.maxSelectCount = count
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            let photoPickerVC = LPhotoPickerController()
            pushViewController(photoPickerVC, animated: true)
        }else {
            requestsImagePickerAuthorization()
        }
        
    }
    /** 显示大图 */
    public convenience init(viewController: UIViewController,delegate: LImagePickerViewDelegate?) {
        let imageShowVC = LImageShowViewController(configuration: LImagePickerConfiguration())
        self.init(rootViewController: imageShowVC)
    }
    
    /** 拍照 */
    public convenience init(ddd row:Int, delegate: LImagePickerController?) {
        let cameraPickerVC = LCameraPickerViewController()
        self.init(rootViewController: cameraPickerVC)
        requestsCameraPickerAuthorization()
    }
    
    fileprivate override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.lBackGround
        delegate = self
        if self.responds(to: #selector(getter: interactivePopGestureRecognizer)) {
            self.interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    deinit {
        print(self, "++++++释放")
    }
    
}

extension LImagePickerController {
    fileprivate func requestsImagePickerAuthorization() {
        if !LImagePickerManager.shared.requestsPhotosAuthorization() {
            view.placeholderShow(true) { (promptView) in
                promptView.delegate = self
                promptView.title("请在iPhone的\'设置-隐私-照片'选项中\r允许\(App.appName)访问你的手机相册")
                promptView.image(UIImage.imageNameFromBundle("icon_permissions"))

            }
        }
    }
    
    fileprivate func requestsCameraPickerAuthorization() {
        if !LImagePickerManager.shared.requestsCameraAuthorization(mediaType: .video) {
            view.placeholderShow(true) { (promptView) in
                promptView.delegate = self
                promptView.title("请在iPhone的\'设置-隐私-照片'选项中\r允许\(App.appName)访问你的手机相册")
                promptView.image(UIImage.imageNameFromBundle("icon_permissions"))

            }
        }
    }
    
}


extension LImagePickerController: UIGestureRecognizerDelegate, UINavigationControllerDelegate, LPromptViewDelegate {
    
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
    
    func promptViewImageClick(_ promptView: LImagePickerPromptView) {
        let setUr = URL(string: UIApplication.openSettingsURLString)
        if let url = setUr, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [: ], completionHandler: nil)
        }
    }

}
