//
//  UIColor+LImagePicker.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
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
