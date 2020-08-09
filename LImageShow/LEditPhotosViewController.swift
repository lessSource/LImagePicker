//
//  LEditPhotosViewController.swift
//  LImageShow
//
//  Created by L j on 2020/6/22.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

enum FilterType {
    case normal  // 默认
    case gray    // 灰度
    case split2  // 二分屏
    
    var filterName: String {
        switch self {
        case .normal:
            return "Normal"
        case .gray:
            return "Gray"
        case .split2:
            return "SplitScreen2"
        }
    }
    
}

public class LEditPhotosViewController: UIViewController {

    fileprivate lazy var navView: LEditPickerNavView = {
        let navView = LEditPickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        return navView
    }()
    
    fileprivate var dataArray = [FilterType]()
    
    fileprivate var myView: FilterView!
    
    public var contentImage: UIImage?
    
    deinit {
        myView.removeDisplayLink()
        print("++++++++", self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "修改"
        view.backgroundColor = UIColor.white
        
        view.addSubview(navView)
        dataArray = [.normal, .gray, .split2]

        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.myView = FilterView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar - 100), contentImage: self.contentImage!)
            self.view.addSubview(self.myView)
            
            
            let filerBarView = LShowImageFilterBar(frame: CGRect(x: 0, y: LConstant.screenHeight - 100, width: LConstant.screenWidth, height: 100))
            filerBarView.delegate = self
            self.view.addSubview(filerBarView)
            
            filerBarView.itemList = self.dataArray
        }
        
        
        
    }


}

extension LEditPhotosViewController: LShowImageFilterBarDelegate {
    
    func filterBar(_ filterBar: LShowImageFilterBar, index: Int) {
        self.myView.setupsetupShaderProgram(dataArray[index].filterName)
    }
}
