//
//  LImagePickerAboutExtensions.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

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
        let path = Bundle(for: LImagePickerController.self).path(forResource: "LImagePickerController", ofType: "bundle")
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
