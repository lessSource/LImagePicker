//
//  LImagePickerViewExtensions.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit


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
    
}

extension UIView {
    
    typealias PromptViewClosure = (_ promptView: LImagePickerPromptView) -> ()
    
    func placeholderShow(_ show: Bool,_ promptViewClosure: PromptViewClosure? = nil) {
        if show {
            showPromptView()
            if let closure = promptViewClosure {
                closure(promptView)
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
    
    private var promptView: LImagePickerPromptView {
        get {
            guard let view = objc_getAssociatedObject(self, &AssociatedKeys.PromptViewKey) as? LImagePickerPromptView else {
                return generatePromptView()
            }
            return view
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.PromptViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func generatePromptView() -> LImagePickerPromptView {
        let view: LImagePickerPromptView = LImagePickerPromptView(frame: bounds)
        promptView = view
        return view
    }
    
}

extension UIView {
    
    func getControllerFromView() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next, responder is UIViewController {
                return responder as? UIViewController
            }
        }
        return nil
    }
    
}
