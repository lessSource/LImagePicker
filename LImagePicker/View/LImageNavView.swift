//
//  LImageNavView.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

class LImageNavView: UIView {

    public var allNumber: Int = 0

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 100, y: LConstant.statusHeight, width: LConstant.screenWidth - 200, height: LConstant.topBarHeight)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    public lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("返回", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.frame = CGRect(x: 15, y: LConstant.statusHeight + 2, width: 60, height: 40)
        button.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        return button
    }()
    
    public lazy var cancleButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        button.contentHorizontalAlignment = .right
        button.frame = CGRect(x: LConstant.screenWidth - 75, y: LConstant.statusHeight + 2, width: 60, height: 40)
        button.addTarget(self, action: #selector(completeButtonClick), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lBackWhite
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(cancleButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Event
    @objc fileprivate func backButtonClick() {
        getControllerFromView()?.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func completeButtonClick() {
        getControllerFromView()?.navigationController?.dismiss(animated: true, completion: nil)
    }

}


