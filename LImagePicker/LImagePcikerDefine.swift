//
//  LImagePcikerDefine.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit


struct LConstant {
    /** 屏幕宽度 */
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    /** 屏幕高度 */
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    /** 状态栏高度 */
    static var statusHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    /** navtiveTitleView高度 */
    static var topBarHeight: CGFloat {
        return 44.0
    }
    /** 头部高度 */
    static var navbarAndStatusBar: CGFloat {
        return (statusHeight + topBarHeight)
    }
    /** 标签栏 */
    static var bottomBarHeight: CGFloat {
        return UIDevice.isIphone_X ? 83.0 : 49.0
    }
    /** 安全边界 */
    static var barHeight: CGFloat {
        return UIDevice.isIphone_X ? 34.0 : 0.0
    }
    static var barMargin: CGFloat {
        return UIDevice.isIphone_X ? 20.0 : 0.0
    }
    /** 不同设备的屏幕比例 */
    static var sizeScale: CGFloat {
        return screenWidth > 375.0 ? screenWidth/375.0 : 1
    }
    /** 线高 */
    static var lineHeight: CGFloat {
        return 0.5
    }
}

extension UIDevice {
    /** 是否带刘海 */
    static var isIphone_X: Bool {
        if #available(iOS 11, *) {
            guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                return false
            }
            if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }
}

struct LApp {
    
    private static var info: Dictionary<String, Any> {
        return Bundle.main.infoDictionary ?? [String: Any]()
    }
    
    /** 名称 */
    static var appName: String {
        return info["CFBundleDisplayName"] as? String ?? ""
    }
    
    /** 路径 */
    static var cocumentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
    }
}
