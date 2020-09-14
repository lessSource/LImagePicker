//
//  ViewController.swift
//  LImagePickerDemo
//
//  Created by Lj on 2020/5/6.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
//import LImagePicker
//import Photos
import LImageShow
//import LPublicImageParameter
//import Kingfisher
import LImagePickerController


class TestClass {
    
    var name: String
    
    var content: String
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
    
}

class ViewController: UIViewController {
    
//    fileprivate var delegate: ModelAnimationDelegate?
    
    fileprivate lazy var contentImage: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 100, y: 300, width: 200, height: 200))
        image.backgroundColor = UIColor.red
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    fileprivate let semaphore = DispatchSemaphore(value: 1)
    
    fileprivate var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let galleryButton = UIButton(type: .custom)
        galleryButton.frame = CGRect(x: 50, y: 100, width: 100, height: 50)
        galleryButton.backgroundColor = UIColor.red
        galleryButton.setTitle("图库", for: .normal)
        galleryButton.addTarget(self, action: #selector(galleryButtonClick), for: .touchUpInside)
        view.addSubview(contentImage)
        view.addSubview(galleryButton)
        
        let cameraButton = UIButton(type: .custom)
        cameraButton.frame = CGRect(x: UIScreen.main.bounds.width - 150, y: 100, width: 100, height: 50)
        cameraButton.backgroundColor = UIColor.red
        cameraButton.setTitle("相机", for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonClick), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        contentImage.isUserInteractionEnabled = true
        contentImage.image = UIImage(named: "123456")
        contentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentImageClick)))
        
//        let
        
    }
    
    
    
    func calculateStructSize(_ size: Int) -> Int {
        return 1
    }
    
    
}


@objc
extension ViewController {
    
    // 图库
    func galleryButtonClick() {
        let imagePicker = LImagePickerController(withMaxImage: 10, delegate: nil)
//        imagePicker.isDarkMode = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 相机
    func cameraButtonClick() {
        let imagePicker = LImagePickerController(ddd: 0, delegate: nil)
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 查看大图
    func contentImageClick() {
//        delegate = ModelAnimationDelegate(contentImage: contentImage, superView: view)
//
//        let showImageVC = LImagePickerController(configuration: LImagePickerConfiguration(currentIndex: 0, dataArray: [contentImage.image!]))
//        showImageVC.transitioningDelegate = delegate
//        showImageVC.modalTransitionStyle = .crossDissolve
//        present(showImageVC, animated: true, completion: nil)
        let editPhotosVC = TestViewController()
//        editPhotosVC.contentImage = contentImage
//        editPhotosVC.c
//        pushAndHideTabbar(editPhotosVC)
//        navigationController?.present(editPhotosVC, animated: true, completion: nil)
        editPhotosVC.modalPresentationStyle = .custom

        editPhotosVC.contentImage = contentImage.image
        present(editPhotosVC, animated: true, completion: nil)

    }
    
}
