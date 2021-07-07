//
//  ImagePickerProtocol.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import Photos
import UIKit

public protocol ImagePickerProtocol: AnyObject {
    
    func imagePickerCustomPhotograph(navView: PhotographNavView)
    
    func imagePickerCustomPhotograph(bottomView: PhotographBottomView)
    
    func imagePickerCustomPhotoAlbum(navView: PhotoAlbumNavView)

}

public extension ImagePickerProtocol {
    
    func imagePickerCustomPhotograph(navView: PhotographNavView) { }
    
    func imagePickerCustomPhotoAlbum(navView: PhotoAlbumNavView) { }
    
    func imagePickerCustomPhotograph(bottomView: PhotographBottomView) { }
}


public protocol ImagePhotographProtocol: ImagePickerProtocol {
    
    /** 选择图片 */
    func imagePickerPhotograph(viewController: UIViewController, photos: [UIImage], assets: [PHAsset])
    
}

public extension ImagePhotographProtocol {
    func imagePickerPhotograph(viewController: UIViewController, photos: [UIImage], assets: [PHAsset]) { }
}

