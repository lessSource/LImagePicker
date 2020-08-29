//
//  LPhotoPickerController.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LPhotoPickerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.lBackGround

        title = "测试"
        
        let cancleItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancleItemClick))
        navigationItem.rightBarButtonItem = cancleItem
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
    @objc func cancleItemClick() {
        dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
}
