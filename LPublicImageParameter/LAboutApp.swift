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

public struct App {
    
    private static var info: Dictionary<String, Any> {
        return Bundle.main.infoDictionary ?? [String: Any]()
    }
    
    /** 名称 */
    public static var appName: String {
        return info["CFBundleDisplayName"] as? String ?? ""
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
}

extension UIColor {
    
    /** 字体颜色 */
    public class var lLabelColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
        
//        return UIColor(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)

    }
    
    /** 白色背景色 */
    public class var lBackWhite: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (trailCollection) -> UIColor in
                if trailCollection.userInterfaceStyle == .light {
                    return UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
                }else {
                    return UIColor(hue: 240.0, saturation: 0.067, brightness: 0.118, alpha: 1.0)
                }
            }
        } else {
            return UIColor.white
        }
    }
    
    // 返回HSBA模式颜色值
    public var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h * 360, s, b, a)
    }
    
    class func withHex(hexString hex: String, alpha: CGFloat = 1) -> UIColor {
        // 去除空格
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        // 去除#
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0
        Scanner(string: cString[0..<2]).scanHexInt32(&red)
        Scanner(string: cString[2..<4]).scanHexInt32(&green)
        Scanner(string: cString[4..<6]).scanHexInt32(&blue)
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

extension String {
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
}

extension UIView {
    
    public typealias ViewBlock = (_ view: LPromptView) -> ()
    
    public func getControllerFromView() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next, responder is UIViewController {
                return responder as? UIViewController
            }
        }
        return nil
    }
    
    public func showOscillatoryAnimation() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.layer.setValue(0.90, forKeyPath: "transform.scale")
        }) { (finished) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.layer.setValue(0.90, forKeyPath: "transform.scale")
            }) { (finished) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            }
        }
    }
    
    public func placeholderShow(_ show: Bool,_ viewBlock: ViewBlock? = nil) {
        if show {
            showPromptView()
            if let block = viewBlock {
                block(promptView)
            }
        }else {
            promptView.removeFromSuperview()
        }
    }
    
    // MARK:- private
    private func showPromptView() {
        if self.subviews.count > 0 {
            var t_v = self
            for v in self.subviews {
                if v.isKind(of: UITableView.self) {
                    t_v = v
                }
            }
            t_v.insertSubview(promptView, aboveSubview: t_v.subviews[0])
            promptView.backgroundColor = t_v.backgroundColor
        }else {
            self.addSubview(promptView)
        }
    }
    
    private struct AssociatedKeys {
        static var PromptViewKey: String = "PromptViewKey"
    }
    
    private var promptView: LPromptView {
        get {
            guard let view = objc_getAssociatedObject(self, &AssociatedKeys.PromptViewKey) as? LPromptView else {
                return generatePromptView()
            }
            return view
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.PromptViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func generatePromptView() -> LPromptView {
        let view: LPromptView = LPromptView(frame: bounds)
        promptView = view
        return view
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


extension Bundle {
    static func imagePickerBundle() -> Bundle? {
        let path = Bundle(for: LPromptView.self).path(forResource: "LPublicImageParameter", ofType: "bundle")
        let bundle = Bundle(path: path ?? "")
        return bundle
    }
}

extension UIImage {
    public static func imageNameFromBundle(_ name: String) -> UIImage? {
        let imageName = name + "@2x"
        let imageBundle  = Bundle.imagePickerBundle()
        let imagePath = imageBundle?.path(forResource: imageName, ofType: "png")
        let image = UIImage(contentsOfFile: imagePath ?? "")
        return image
    }
}

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


