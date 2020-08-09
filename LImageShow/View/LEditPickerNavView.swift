//
//  LEditPickerNavView.swift
//  LImageShow
//
//  Created by L j on 2020/6/22.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

class LEditPickerNavView: UIView {

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 100, y: LConstant.statusHeight, width: LConstant.screenWidth - 200, height: LConstant.topBarHeight)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    public lazy var cancleButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentHorizontalAlignment = .left
        button.frame = CGRect(x: 15, y: LConstant.statusHeight + 2, width: 60, height: 40)
        button.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
        return button
    }()
    
    public lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("保存", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentHorizontalAlignment = .right
        button.frame = CGRect(x: LConstant.screenWidth - 75, y: LConstant.statusHeight + 2, width: 60, height: 40)
        button.addTarget(self, action: #selector(saveButtonClick), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        addSubview(titleLabel)
        addSubview(saveButton)
        addSubview(cancleButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Event
    @objc fileprivate func cancleButtonClick() {
        getControllerFromView()?.navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func saveButtonClick() {
        //            viewController()?.navigationController?.dismiss(animated: true, completion: nil)
    }


}
