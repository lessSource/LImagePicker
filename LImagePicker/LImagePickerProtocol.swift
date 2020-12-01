//
//  LImagePickerProtocol.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

public protocol LImagePickerProtocol: class {
    
    // 编辑图片
    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?)
    
    // 拍照
    func takingPictures(viewController: UIViewController, image: UIImage?)
}

extension LImagePickerProtocol {
    
    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?) { }
    
    func takingPictures(viewController: UIViewController, image: UIImage?) { }
}


