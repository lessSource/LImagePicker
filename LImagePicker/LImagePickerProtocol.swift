//
//  LImagePickerProtocol.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

public protocol LImagePickerProtocol: class {
    
    // 编辑图片
    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?)
    
    // 拍照
    func takingPictures(viewController: UIViewController, image: UIImage?)
    
    // 保存照片
    func takingPicturesSaveImage(viewController: UIViewController, asset: PHAsset)
    
}

public extension LImagePickerProtocol {
    
    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?) { }
    
    func takingPictures(viewController: UIViewController, image: UIImage?) { }
    
    func takingPicturesSaveImage(viewController: UIViewController, asset: PHAsset) { }
}


