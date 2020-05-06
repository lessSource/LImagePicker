//
//  ShowImageTabBarView.swift
//  ImagePicker
//
//  Created by Lj on 2019/10/5.
//  Copyright © 2019 Less. All rights reserved.
//

import UIKit

class ShowImageTabBarView: UIView {

    public var maxCount: Int = 1
    
    public var currentCount: Int = 0 {
        didSet {
            if currentCount == 0 {
                completeButton.setTitle("完成", for: .normal)
                completeButton.isUserInteractionEnabled = false
                completeButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
            }else {
                completeButton.setTitle("完成(\(currentCount)/\(maxCount))", for: .normal)
                completeButton.isUserInteractionEnabled = true
                completeButton.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
            }
            completeButton.l_width = completeButton.titleLabel?.intrinsicContentSize.width ?? 0
            completeButton.l_x = LConstant.screenWidth - 15 - completeButton.l_width
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var completeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: LConstant.screenWidth - 55, y: 4.5, width: 40, height: 40))
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    // MARK:- layoutView
    fileprivate func layoutView() {
        addSubview(completeButton)
    }

}
