//
//  LImagePicker+Extension.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import Foundation

extension NSObject {
    
    class var lnameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    // 用于获取cell的reuse identifire
    public class var l_identifire: String {
        return String(format: "%@_identifire", self.lnameOfClass)
    }
    
}
