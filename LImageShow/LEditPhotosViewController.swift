//
//  LEditPhotosViewController.swift
//  LImageShow
//
//  Created by L j on 2020/6/22.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

class LEditPhotosViewController: UIViewController {

    fileprivate lazy var navView: LEditPickerNavView = {
        let navView = LEditPickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        return navView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "修改"
        view.backgroundColor = UIColor.black
        
        view.addSubview(navView)
    }

}
