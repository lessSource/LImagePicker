//
//  LImagePickerContrller.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

public class LImagePickerContrller: LImagePickerNavigationController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /** 选择图片 */
    public convenience init(withMaxImage count: Int = 9, delegate: LImagePickerProtocol? = nil) {
        let photographVC = LPhotographController()
        self.init(rootViewController: photographVC)
    }
    
    /** 显示大图 */
    public convenience init(images: [UIImage], delegate: LImagePickerProtocol? = nil) {
        let previewImageVC = LPreviewImageController()
        self.init(rootViewController: previewImageVC)
    }
    
    /** 拍照 */
    public convenience init(allowTakePicture: Bool = false, timeout: Int = 15, delegate: LImagePickerProtocol? = nil) {
        let takingPicturesVC = LTakingPicturesController()
        self.init(rootViewController: takingPicturesVC)
    }
    
    /** 编辑 */
    public convenience init(contentImage: UIImage, delegate: LImagePickerProtocol? = nil) {
        let editPicturesVC = LEditPicturesController()
        self.init(rootViewController: editPicturesVC)
    }
    
    /** 显示视频 */
    public convenience init(videoUrl: URL, delegate: LImagePickerProtocol? = nil) {
        let previewVideoVC = LPreviewVideoController()
        self.init(rootViewController: previewVideoVC)
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
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    deinit {
        print(self, "++++++释放")
    }
}

extension LImagePickerContrller: UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
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
