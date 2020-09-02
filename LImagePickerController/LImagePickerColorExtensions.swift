//
//  LImagePickerColorExtensions.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

extension UIColor {
    
    /** 背景色 */
    class var lBackGround: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        }
        return UIColor(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
    }
    
    /** 字体颜色 */
    class var lLabelColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        }
        return UIColor.black
    }
    
    // 线的颜色
    public class var lLineColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (trailCollection) -> UIColor in
                if trailCollection.userInterfaceStyle == .light {
                    return groupTableViewBackground
                }else {
                    return UIColor.black
                }
            }
            
        } else {
            return UIColor.groupTableViewBackground
        }
    }
    
    
}
