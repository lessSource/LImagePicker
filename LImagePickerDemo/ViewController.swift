//
//  ViewController.swift
//  LImagePickerDemo
//
//  Created by Lj on 2020/5/6.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LImagePicker
import Photos
import LImageShow
import LPublicImageParameter

class ViewController: UIViewController {

    fileprivate lazy var contentImage: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 100, y: 300, width: 200, height: 200))
        image.backgroundColor = UIColor.red
        image.layer.cornerRadius = 5
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.setTitle("测试", for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        view.addSubview(button)
        
        view.addSubview(contentImage)
    }
    
    
    @objc func buttonClick() {
        print("buttonClick")
        let imagePicker = LImagePickerController(delegate: self)
        imagePicker.modalPresentationStyle = .custom
        imagePicker.allowTakePicture = true
        imagePicker.allowTakeVideo = true
        imagePicker.allowPickingVideo = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: LImagePickerDelegate {
    func imagePickerController(_ picker: LImagePickerController, photos: [UIImage], asset: [LMediaResourcesModel]) {
        print("ddd")
        contentImage.image = photos[0]
        if asset[0].dataEnum == .audio {
            print("dsd")
        }
    }
}
