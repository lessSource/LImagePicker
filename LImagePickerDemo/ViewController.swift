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
//import LImageShow
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
        contentImage.image = UIImage(named: "123456")
        contentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentImageClick)))
        
        
        
    }
    
    @objc func buttonClick() {
        //        print("buttonClick")
        //        let imagePicker = LImagePickerController(withMacImage: 100, delegate: self)
        //        imagePicker.modalPresentationStyle = .custom
        ////        imagePicker.allowTakePicture = true
        ////        imagePicker.allowTakeVideo = true
        ////        imagePicker.allowPickingVideo = true
        //        self.present(imagePicker, animated: true, completion: nil)
        //        let imagePicker = LImagePickerController(withMaxImage: 10, delegate: nil)
//        let imagePicker = LImagePickerController(viewController: self, delegate: nil)
//        let imagePicker = LImagePickerController(
//        let imagePicker = LImagePickerController(ddd: 12, delegate: nil)
//        imagePicker.modalPresentationStyle = .custom
//        present(imagePicker, animated: true, completion: nil)
//
        
        let imagePicker = LImagePickerController(withMaxImage: 10, delegate: nil)
        imagePicker.modalPresentationStyle = .custom
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
}

//extension ViewController: LImagePickerDelegate {
//    func imagePickerController(_ picker: LImagePickerController, photos: [UIImage], asset: [LMediaResourcesModel]) {
//        print("ddd")
//        contentImage.image = photos[0]
//        if asset[0].dataEnum == .audio {
//            print("dsd")
//        }
//    }
//}


extension ViewController: UIViewControllerTransitioningDelegate {
    
    @objc func contentImageClick() {
        print("12345")
        guard let image = contentImage.image else {
            return
        }
        //    let configuration = LShowImageConfiguration(dataArray: [LMediaResourcesModel(dataProtocol: image, dataEnum: .image)], currentIndex: 0)
        delegate = ModelAnimationDelegate(contentImage: contentImage, superView: view)
        //    showImage(configuration, delegate: delegate, formVC: self)
        
        //    let configuration = LShowImageConfiguration(dataArray: ["22"], currentIndex: 0)
        
        //    showImage(configuration, formVC: nil)
        //    showImage(configuration, delegate: delegate, formVC: self)
        
        //    showImage;(LShowImageConfiguration(dataArray: ["22"], currentIndex: 0))
        
        let showImageVC = LImagePickerController(viewController: self, delegate: nil)
        //        showImageVC.imageDelegate = formVC as? LShowImageVCDelegate
        showImageVC.transitioningDelegate = delegate
        showImageVC.modalPresentationStyle = .custom
        if let _ = delegate {
        }else {
        }
        showImageVC.modalTransitionStyle = .crossDissolve
        
        present(showImageVC, animated: true, completion: nil)
        
        
        
        
        
        
    }
    
}












extension ViewController {
    
    fileprivate func ddddd() {
        
        //        let testClass1 = TestClass(name: "name1", content: "conetnt1")
        //        let testClass2 = TestClass(name: "name2", content: "conetnt2")
        //        let testClass3 = TestClass(name: "name3", content: "conetnt3")
        //
        ////        let array1 = [testClass1, testClass2, testClass3]
        //        let array1 = ["1", "2", "3"]
        ////        testClass1.name = "name"
        //
        //        var array2 = array1
        //        array2[0] = "name"
        //
        //
        //        print(array1, array2)
        
        // Swift 数组里面放入值类型数据，复制时不会开辟新的内存空间，修改后原数组不变，新数组从新开辟新的空间，写时复制。
        // 数组放入引用类型是，复制时不会开辟新的内存空间，修改后两个数组都改变，指向同一个内存地址
        
        // 数组中的一下高阶函数
        let array = [1, 2, 3, 4, 5]
        
        // map 变换  --->  对数组中每个元素进行操作 生成新的数组   ---> 内部实现声明一个数组，遍历原数组对每个元素操作后加入新数组 最后返回新数组
        let mapArr = array.map { (row) -> Int in
            return row * 2
        }
        print("mapArr:", mapArr)
        
        // flatMap（变换）  遍历原数组, 降维数组
        let aaa = [[1, 2, 3], [4, 5, 6]]
        let flatMap = aaa.flatMap { (row) -> [Int] in
            return row
        }
        print("flatMap:", flatMap)
        
        // compactMap （变换） 遍历原数组 过滤非空
        let bbb = [1, 2, 3, nil, 5]
        let compactMap = bbb.compactMap { (row) -> Int? in
            return row
        }
        print("compactMap:", compactMap)
        
        // reduce 将数组元素叠加到初始值上
        let _ = array.reduce(1) { (res, value) -> Int in
            return res + value
        }
        // 简便写法
        let reduce = array.reduce(1) { $0 + $1 }
        print("reduce:", reduce)
        
        // filter 过滤数组
        let _ = array.filter { (row) -> Bool in
            return row > 2
        }
        // 简便写法
        let filter = array.filter { $0 > 2 }
        print("filter:", filter)
        
        
        // contains 判断是否包含某元素
        let _ = array.contains { (row) -> Bool in
            return row == 3
        }
        // 简便写法
        let contains = array.contains(3)
        print("contains:", contains)
        
        // first 返回第一个符合闭包条件的元素可选值
        let first = array.first { (row) -> Bool in
            return row == 3
        }
        print("first:", first)
        
        // firstIndex 返回第一个符合闭包条件的元素下标值
        let firstIndex = array.firstIndex(of: 3)
        print("firstIndex:", firstIndex)
        
        
        // sorted 排序
        let sorted = array.sorted { (row1, row2) -> Bool in
            return row1 > row2
        }
        print("sorted:", sorted)
        
        // forEach  遍历数组
        array.forEach { (row) in
            print("forEach:", row)
        }
        
        //        array.split(maxSplits: , omittingEmptySubsequences: <#T##Bool#>, whereSeparator: <#T##(Int) throws -> Bool#>)
        
    }
    
}
