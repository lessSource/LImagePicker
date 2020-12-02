//
//  UIImage+LImagePicker.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

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
        var bundle = Bundle(for: LImagePickerController.self)
        let urlStr = bundle.path(forResource: "LImagePicker", ofType: "bundle") ?? ""
        bundle = Bundle(path: urlStr) ?? Bundle()
        return bundle
    }
}
