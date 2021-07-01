//
//  ImagePickerController.swift
//  LImagePicker
//
//  Created by L on 2021/6/29.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

public class ImagePickerController: ImagePickerNavigationController {

    /** 最多可选数量，默认9 */
    fileprivate var maxCount: Int = 9
    
    /** 配置 */
    fileprivate(set) var configuration: ImagePickerConfiguration = ImagePickerConfiguration()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

extension ImagePickerController {
    
    /** 选择图片/相册 */
    public convenience init(withMaxImage count: Int = 9, photographDelegate: ImagePhotographProtocol? = nil, configuration: ImagePickerConfiguration = ImagePickerConfiguration()) {
        if configuration.photoAlbumType == .dropDown {
            let photographVC = PhotographViewController()
            photographVC.imagePickerDelegate = photographDelegate
            self.init(rootViewController: photographVC)
        }else {
            let photoAlbumVC = PhotoAlbumViewController()
            self.init(rootViewController: photoAlbumVC)
            let photographVC = PhotographViewController()
            photographVC.imagePickerDelegate = photographDelegate
            pushViewController(photographVC, animated: true)
        }
        self.maxCount = count
        self.configuration = configuration
    }


    /** 显示大图 */
    // PreviewViewController
    
    /** 拍照/拍视频 */
    // ShootingViewController
    
    /** 编辑 */
    // EditorViewController
    
    /** 视频 */
    // VideoViewController
}


extension ImagePickerController: UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
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
