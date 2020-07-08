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
import Kingfisher

class ViewController: UIViewController {

    fileprivate var delegate: ModelAnimationDelegate?
    
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
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.setTitle("测试", for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        view.addSubview(contentImage)
        view.addSubview(button)

        contentImage.isUserInteractionEnabled = true
        contentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentImageClick)))
        
        
//        let base64 = "5aaC5p6c5L2g5ZKM5oiR5Lus5LiA5qC354Ot54ix57yW56CB77yM55e06L+35LqO5bel56iL5oqA5pyv77yM6K+35YaZ5LiA5bCB6YKu5Lu277yM566A5Y2V5LuL57uN5L2g6Ieq5bex5bm26ZmE5LiK5L2g55qE566A5Y6G77yM6Z2e5bi45pyf5b6F5pS25Yiw5L2g55qE5p2l5L+hOiBmcmFua0B5aXpob3VjcC5jbgpIYXBweSBjb2Rpbmch"
//        
////        let str = base64.
//        
//        let base64Data = NSData(base64Encoded:base64, options:NSData.Base64DecodingOptions(rawValue: 0))
//        // 对NSData数据进行UTF8解码
//        let stringWithDecode = NSString(data:base64Data as! Data, encoding:String.Encoding.utf8.rawValue)
//        print("base64String \(stringWithDecode!)")
        
    }

    @objc func buttonClick() {
        print("buttonClick")
        let imagePicker = LImagePickerController(withMacImage: 100, delegate: self)
        imagePicker.modalPresentationStyle = .custom
        imagePicker.allowTakePicture = true
//        imagePicker.allowTakeVideo = true
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


extension ViewController: ShowImageProtocol, UIViewControllerTransitioningDelegate {
    
 @objc func contentImageClick() {
      print("12345")
    let configuration = LShowImageConfiguration(dataArray: [LMediaResourcesModel(dataProtocol: contentImage.image!, dataEnum: .image)], currentIndex: 0)
    delegate = ModelAnimationDelegate(contentImage: contentImage, superView: view)
    showImage(configuration, delegate: delegate, formVC: self)
    
  }
    
}
