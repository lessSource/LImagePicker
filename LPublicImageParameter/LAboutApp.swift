//
//  LAboutApp.swift
//  LPublicImageParameter
//
//  Created by L j on 2020/6/18.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

public struct LConstant {
    /** 屏幕宽度 */
    public static var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    /** 屏幕高度 */
    public static var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    /** 状态栏高度 */
    public static var statusHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    /** navtiveTitleView高度 */
    public static var topBarHeight: CGFloat {
        return 44.0
    }
    /** 头部高度 */
    public static var navbarAndStatusBar: CGFloat {
        return (statusHeight + topBarHeight)
    }
    /** 标签栏 */
    public static var bottomBarHeight: CGFloat {
        return UIDevice.isIphone_X ? 83.0 : 49.0
    }
    /** 安全边界 */
    public static var barHeight: CGFloat {
        return UIDevice.isIphone_X ? 34.0 : 0.0
    }
    public static var barMargin: CGFloat {
        return UIDevice.isIphone_X ? 20.0 : 0.0
    }
    /** 不同设备的屏幕比例 */
    public static var sizeScale: CGFloat {
        return screenWidth > 375.0 ? screenWidth/375.0 : 1
    }
    /** 线高 */
    public static var lineHeight: CGFloat {
        return 0.5
    }
}


extension UIDevice {
    /** iPhoneX */
    static var isIphoneX: Bool {
        return LConstant.screenHeight * UIScreen.main.scale == 2436 ? true : false
    }
    /** iPhoneXS MAX */
    static var isIphoneXM: Bool {
        return LConstant.screenHeight * UIScreen.main.scale == 2688 ? true : false
    }
    /** iPhoneXR */
    static var isIphoneXR: Bool {
        return LConstant.screenHeight * UIScreen.main.scale == 1792 ? true : false
    }
    /** 是否带刘海 */
    static var isIphone_X: Bool {
        return (isIphoneX || isIphoneXM || isIphoneXR) ? true : false
    }
    
}


public extension UIView {
    var l_width: CGFloat {
        get { return self.frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var l_height: CGFloat {
        get { return self.frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var l_x: CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var l_y: CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    
    func getControllerFromView() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next, responder is UIViewController {
                return responder as? UIViewController
            }
        }
        return nil
    }
}

extension UIView {
    
    func showOscillatoryAnimation() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.layer.setValue(0.92, forKeyPath: "transform.scale")
        }) { (finished) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.layer.setValue(0.92, forKeyPath: "transform.scale")
            }) { (finished) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            }
        }
    }

}


extension NSObject {
    
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    // 用于获取cell的reuse identifire
    public class var l_identifire: String {
        return String(format: "%@_identifire", self.nameOfClass)
    }
    
}


//extension Bundle {
//    static func imagePickerBundle() -> Bundle? {
//        let path = Bundle(for: LPublicImageParameter.self).path(forResource: "LImagePicker", ofType: "bundle")
//        let bundle = Bundle(path: path ?? "")
//        return bundle
//    }
//}
//
//extension UIImage {
//    static func imageNameFromBundle(_ name: String) -> UIImage? {
//        let imageName = name + "@2x"
//        let imageBundle  = Bundle.imagePickerBundle()
//        let imagePath = imageBundle?.path(forResource: imageName, ofType: "png")
//        let image = UIImage(contentsOfFile: imagePath ?? "")
//        return image
//    }
//}

extension UIViewController {
    
    public func showAlertController(_ title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, actionTitles: [String], complete: ((Int) -> ())? ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        for (i, item) in actionTitles.enumerated() {
            let alertAction = UIAlertAction(title: item, style: item == "取消" ? .cancel : .default) { (action) in
                guard let `complete` = complete else { return }
                complete(i)
            }
            alertVC.addAction(alertAction)
        }
        present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func pushViewController(_ viewController: UIViewController, animated: Bool, hideTabbar: Bool) {
        viewController.hidesBottomBarWhenPushed = hideTabbar
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /** push */
    public func pushAndHideTabbar(_ viewController: UIViewController) {
        pushViewController(viewController, animated: true, hideTabbar: true)
    }
}


