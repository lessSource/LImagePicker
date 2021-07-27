//
//  VideoContentView.swift
//  LImagePicker
//
//  Created by L on 2021/7/26.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit


class VideoNavView: UIView {
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 5, y: LConstant.statusHeight + 2, width: 40, height: 40))
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_video_back"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        addSubview(backButton)
        
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
    }
    
    @objc fileprivate func backButtonClick() {
        viewController()?.dismiss(animated: true, completion: nil)
    }
    
}

class VideoBottomView: UIView {
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
 
    }

    
}

