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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.setTitle("测试", for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        view.addSubview(button)
    }
    
    
    @objc func buttonClick() {
        print("buttonClick")
        let imagePicker = LImagePickerController(delegate: self)
        imagePicker.modalPresentationStyle = .custom
        imagePicker.allowPickingVideo = true
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
}

extension ViewController: LImagePickerDelegate {
    func imagePickerController(_ picker: LImagePickerController, photos: [UIImage], asset: [PHAsset]) {
    }
}
