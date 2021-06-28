//
//  LImagePickerProtocol.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

public protocol LImagePickerProtocol1: AnyObject { }

public protocol LImageSelectProtocol: LImagePickerProtocol1 {
    /** 选择图片 */
    func imagePickerSelect(viewController: UIViewController, photos: [UIImage], assets: [PHAsset])
}

public protocol LImageEditProtocol: LImagePickerProtocol1 {
    /** 编辑图片 */
    func imagePickerEdit(viewController: UIViewController, cropping: UIImage?, original: UIImage?)
}

public protocol LImageTakingProtocol: LImagePickerProtocol1 {
    /** 拍照 */
    func imagePickerTaking(viewController: UIViewController, image: UIImage?)
    /** 保存图片 */
    func imagePickerSave(viewController: UIViewController, asset: PHAsset)
}

public protocol LImagePreviewProtocol: LImagePickerProtocol1 {
    /** 预览图片 */
    func imagePickerPreview(viewController: UIViewController, mediaProtocol: LImagePickerMediaProtocol)
    /** 外部加载预览图片 */
    func imagePickerPreviewLoading(viewController: UIViewController, urlStr: String, imageView: UIImageView, competionHandler: @escaping (() -> Void))
    
}


public protocol LImagePickerProtocol: AnyObject {

    // 编辑图片
    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?)

    // 拍照
    func takingPictures(viewController: UIViewController, image: UIImage?)

    // 保存照片
    func takingPicturesSaveImage(viewController: UIViewController, asset: PHAsset)

    // 选中图片
    func photographSelectImage(viewController: UIViewController, photos: [UIImage], assets: [PHAsset])

    // 预览图片状态改变
    func previewImageState(viewController: UIViewController, mediaProtocol: LImagePickerMediaProtocol)

    // 预览图片加载
    func previewImageLoading(viewController: UIViewController, urlStr: String, imageView: UIImageView, completionHandler: @escaping (() -> Void))

    // 删除图片
    func previewImageDelete(viewController: UIViewController, index: Int)

    // 删除图片
    func previewImageDeleteImages(viewController: UIViewController, images: [LImagePickerMediaProtocol])

}


public extension LImagePickerProtocol {

    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?) { }

    func takingPictures(viewController: UIViewController, image: UIImage?) { }

    func takingPicturesSaveImage(viewController: UIViewController, asset: PHAsset) { }

    func photographSelectImage(viewController: UIViewController, photos: [UIImage], assets: [PHAsset]) { }

    func previewImageState(viewController: UIViewController, mediaProtocol: LImagePickerMediaProtocol) { }

    func previewImageLoading(viewController: UIViewController, urlStr: String, imageView: UIImageView, completionHandler: @escaping (() -> Void)) { }

    func previewImageDelete(viewController: UIViewController, index: Int) { }

    func previewImageDeleteImages(viewController: UIViewController, images: [LImagePickerMediaProtocol]) { }
}



protocol LPreviewImageProtocol: AnyObject {

    func previewImageDidSelect(cell: UICollectionViewCell)

}

extension LPreviewImageProtocol {

    func previewImageDidSelect(cell: UICollectionViewCell) { }

}

protocol LPreviewBottomProtocol: AnyObject {

    func previewBottomView(view: UIView, didSelect index: Int)

}

protocol LPhotoAlbumViewProtocol: AnyObject {

    func photoAlbumView(view: LPhotoAlbumView, albumModel: LPhotoAlbumModel)

    func photoAlbumAnimation(view: LPhotoAlbumView, isShow: Bool)

}


