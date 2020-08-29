//
//  LImagePickerAboutApp.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
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

struct App {
    
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
