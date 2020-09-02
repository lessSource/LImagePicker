//
//  LImagePickerNavView.swift
//  LImagePickerController
//
//  Created by L j on 2020/9/2.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImagePickerNavView: UIView {
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "标题"
        label.textColor = UIColor.lLabelColor
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    fileprivate lazy var cancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
        addSubview(nameLabel)
        addSubview(cancleButton)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LConstant.statusHeight).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: LConstant.topBarHeight).isActive = true
        
        cancleButton.translatesAutoresizingMaskIntoConstraints = false
        cancleButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        cancleButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)

    }
    
}


@objc
extension LImagePickerNavView {
    
    fileprivate func cancleButtonClick() {
        getControllerFromView()?.dismiss(animated: true, completion: nil)
    }
    
}
