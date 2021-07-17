//
//  ImagePicker+Extension.swift
//  LImagePicker
//
//  Created by L on 2021/7/9.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

extension NSObject {
    
    class var lnameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    // 用于获取cell的reuse identifire
    class var l_identifire: String {
        return String(format: "%@_identifire", self.lnameOfClass)
    }
    
}

extension UIView {
    
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
    
    func l_showOscillatoryAnimation() {
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
    
    func viewController() -> UIViewController? {
        var next = self.next
        while next != nil {
            if next is UIViewController {
                return next as? UIViewController
            }
            next = next?.next
        }
        return  nil
    }
}

extension UIButton {
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if l_width < 44 && l_height < 44 {
            var bounds1 = bounds
            let widthDelta: CGFloat = 44.0 - l_width
            let heightDelta: CGFloat = 44.0 - l_height
            bounds1 = bounds.insetBy(dx: -widthDelta * 0.5, dy: -heightDelta * 0.5)
            return bounds1.contains(point)
        }
        return super.point(inside: point, with: event)
    }
    
}

extension Array {
    subscript (safe index: Index) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
    
    func safeObjectAtIndex(index: Int) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
    
    mutating func insertToFirst(newElement: Element) {
        insert(newElement, at: 0)
    }
    
    func isLastIndex(index: Index) -> Bool {
        return index == count - 1
    }
    
    func isNotLastIndex(index: Int) -> Bool {
        return !isLastIndex(index: index)
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


extension UIColor {
    
    /** 随机颜色 */
    class var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
    }
    
    // 背景色
    class var backColor: UIColor {
        return UIColor.white
    }
    
    // 拍摄背景色
    class var shootingBackColor: UIColor {
        return UIColor.withHex(hexString: "#B1BDCB")
    }
    
    // 拍摄字体颜色
    class var shootingTextColor: UIColor {
        return UIColor.white
    }
    
    // 选中颜色
    class var mediaSelectColor: UIColor {
        return UIColor.withHex(hexString: "#007AFD")
    }
    
    // 选中字体颜色
    class var mediaSelectTextColor: UIColor {
        return UIColor.white
    }
    
    // 导航栏背景色
    class var navViewBackColor: UIColor {
        return UIColor.white
    }
    
    // 预览导航栏背景色
    class var previewNavBackColor: UIColor {
        return UIColor.withHex(hexString: "#222425")
    }
    
    // 预览标题颜色
    class var previewNavTitleColor: UIColor {
        return UIColor.white
    }
    
    // 导航栏标题颜色
    class var navViewTitleColor: UIColor {
        return UIColor.withHex(hexString: "#2A2A2A")
    }
    
    // 便签栏
    class var bottomViewBackColor: UIColor {
        return UIColor.white
    }
    
    // 便签栏预览颜色
    class var bottomViewPreviewColor: UIColor {
        return UIColor.withHex(hexString: "#242A39")
    }
    
    // 标签栏未选中颜色
    class var buttonViewPreviewNorColor: UIColor {
        return UIColor.withHex(hexString: "#DAE0E6")
    }
    
    // 标签栏确定颜色
    class var bottomViewConfirmColor: UIColor {
        return UIColor.white
    }
    
    // 标签栏确定背景颜色
    class var bottomViewConfirmBackColor: UIColor {
        return UIColor.withHex(hexString: "#007AFD")
    }
    
    // 标签栏确定不能点击背景颜色
    class var bottomViewConfirmNorBackColor: UIColor {
        return UIColor.withHex(hexString: "#D4DAE0")
    }

    // 标签栏数量颜色
    class var bottomViewTitleColor: UIColor {
        return UIColor.withHex(hexString: "#B1BDCB")
    }
    
    // 分割线颜色
    class var dividerLineColor: UIColor {
        return UIColor.withHex(hexString: "#F7F9FC")
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


extension UIImage {
    
    class func lImageNamedFromMyBundle(name: String) -> UIImage? {
        
        let imageBundle = Bundle.lImagePickerBundle()
        let imageName = name + "@2x"
        let imagePath = imageBundle.path(forResource: imageName, ofType: "png") ?? ""
        if let image = UIImage(contentsOfFile: imagePath) {
            return image
        }
        return UIImage(named: name)
    }
    
}

extension Bundle {
    
    class func lImagePickerBundle() -> Bundle {
        var bundle = Bundle(for: ImagePickerController.self)
        let urlStr = bundle.path(forResource: "LImagePicker", ofType: "bundle") ?? ""
        bundle = Bundle(path: urlStr) ?? Bundle()
        return bundle
    }
}
