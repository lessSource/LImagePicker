//
//  LImagePicker+Extension.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
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
