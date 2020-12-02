////
////  ViewController.swift
////  LImagePickerDemo
////
////  Created by Lj on 2020/5/6.
////  Copyright © 2020 L. All rights reserved.
////
//
import UIKit
import LImagePicker
import Kingfisher
import Photos

////import LImagePicker
////import Photos
////import LImageShow
////import LPublicImageParameter
////import Kingfisher
////import LImagePickerController
//
//
//
class ViewController: UIViewController {
//
////    fileprivate var delegate: ModelAnimationDelegate?
//
    fileprivate lazy var contentImage: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 100, y: 300, width: 200, height: 200))
        image.backgroundColor = UIColor.orange
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    fileprivate lazy var originalImageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 100, y: 600, width: 200, height: 200))
        image.backgroundColor = UIColor.orange
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
//        // Do any additional setup after loading the view.
        let galleryButton = UIButton(type: .custom)
        galleryButton.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
        galleryButton.backgroundColor = UIColor.red
        galleryButton.setTitle("图库", for: .normal)
        galleryButton.addTarget(self, action: #selector(galleryButtonClick), for: .touchUpInside)
        view.addSubview(contentImage)
        view.addSubview(originalImageView)

        view.addSubview(galleryButton)
//
        
//        https://timgsa.baidu.com/timg?image&amp;quality=80&amp;size=b9999_10000&amp;sec=1606815366947&amp;di=8024e218b3d4a26d15869fcfb60a639e&amp;imgtype=0&amp;src=http%3A%2F%2Fa4.att.hudong.com%2F27%2F67%2F01300000921826141299672233506.jpg
        
        let originalImageViewTap = UITapGestureRecognizer(target: self, action: #selector(originalImageViewTapClick))
        originalImageView.isUserInteractionEnabled = true
        originalImageView.addGestureRecognizer(originalImageViewTap)
        
        
        originalImageView.kf.setImage(with: ImageResource(downloadURL: URL(string: "https://pic4.zhimg.com/v2-827a81b70a2d6bd3b683f4006a1e0938_1200x500.jpg")!))
        
        
//        let cameraButton = UIButton(type: .custom)
//        cameraButton.frame = CGRect(x: UIScreen.main.bounds.width - 150, y: 100, width: 100, height: 50)
//        cameraButton.backgroundColor = UIColor.red
//        cameraButton.setTitle("相机", for: .normal)
//        cameraButton.addTarget(self, action: #selector(cameraButtonClick), for: .touchUpInside)
//        view.addSubview(cameraButton)
//
//        contentImage.isUserInteractionEnabled = true
//        contentImage.image = UIImage(named: "123456")
//        contentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentImageClick)))
//
////        let
//
    }
//
//
//
//    func calculateStructSize(_ size: Int) -> Int {
//        return 1
//    }
//
//
}
//
//
extension ViewController: LImagePickerProtocol {
//    func takingPicturesSaveImage(viewController: UIViewController, asset: PHAsset) {
//
//    }
    
    
    func editPictures(viewConttroller: UIViewController, croppingImage: UIImage?, originalImage: UIImage?) {
        print("11")
        contentImage.image = croppingImage
        originalImageView.image = originalImage
        
    }
    
    func takingPictures(viewController: UIViewController, image: UIImage?) {
//        image.remov
        originalImageView.image = image
    }
    
    func photographSelectImage(viewController: UIViewController, photos: [UIImage], assets: [PHAsset]) {
        contentImage.image = photos[0]
        originalImageView.image = photos[1]
    }
    
    
}

@objc
extension ViewController {
//
    // 图库
    func galleryButtonClick() {
        let imagePicker = LImagePickerController(withMaxImage: 20, delegate: self)
        imagePicker.sortAscendingByModificationDate = false
        present(imagePicker, animated: true, completion: nil)
        print(111)
        
//        let imagePicker = LImagePickerController(contentMedia: "https://pic4.zhimg.com/v2-827a81b70a2d6bd3b683f4006a1e0938_1200x500.jpg", delegate: self)
//        present(imagePicker, animated: true, completion: nil)
        
//        let imagePicker = LImagePickerController(allowPickingVideo: false, delegate: self)
//        present(imagePicker, animated: true, completion: nil)
    }
    
    func originalImageViewTapClick() {
        let imagePicker = LImagePickerController(contentMedia: originalImageView.image! , delegate: self)
        present(imagePicker, animated: true, completion: nil)
        
    }
    
////
////    // 相机
////    func cameraButtonClick() {
////        let imagePicker = LImagePickerController(ddd: 0, delegate: nil)
////        present(imagePicker, animated: true, completion: nil)
////    }
////
////    // 查看大图
////    func contentImageClick() {
//////        delegate = ModelAnimationDelegate(contentImage: contentImage, superView: view)
//////
//////        let showImageVC = LImagePickerController(configuration: LImagePickerConfiguration(currentIndex: 0, dataArray: [contentImage.image!]))
//////        showImageVC.transitioningDelegate = delegate
//////        showImageVC.modalTransitionStyle = .crossDissolve
//////        present(showImageVC, animated: true, completion: nil)
////        let editPhotosVC = TestViewController()
//////        editPhotosVC.contentImage = contentImage
//////        editPhotosVC.c
//////        pushAndHideTabbar(editPhotosVC)
//////        navigationController?.present(editPhotosVC, animated: true, completion: nil)
////        editPhotosVC.modalPresentationStyle = .custom
////
////        editPhotosVC.contentImage = contentImage.image
////        present(editPhotosVC, animated: true, completion: nil)
////
////    }
////
}
