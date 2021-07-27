//
//  VideoOperationView.swift
//  LImagePicker
//
//  Created by L on 2021/7/26.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

class VideoOperationView: UIView {
    
    
    fileprivate lazy var navView: VideoNavView = {
        let view = VideoNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        return view
    }()
    
    fileprivate lazy var bottomView: VideoBottomView = {
        let view = VideoBottomView(frame: CGRect(x: 0, y: LConstant.screenHeight - 210, width: LConstant.screenWidth, height: 210))
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        addSubview(navView)
    }

}
