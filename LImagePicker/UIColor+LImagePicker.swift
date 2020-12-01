//
//  UIColor+LImagePicker.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    /** 随机颜色 */
    class var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
    }
    
    // 背景色
    class var backColor: UIColor {
        return UIColor.withHex(hexString: "#ff0000")
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
