//
//  LImagePickerNavView.swift
//  LImagePickerController
//
//  Created by L j on 2020/9/2.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImagePickerNavView: UIView {
    
    /** 标题 */
    public var nameTitle: String = "" {
        didSet {
            nameLabel.text = nameTitle
        }
    }
    
    /** 是否隐藏返回键 */
    public var isBackHidden: Bool = true {
        didSet {
            leftButton.isHidden = isHidden
        }
    }
    
    /** 背景色 */
//    public var back
    
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
    
    fileprivate lazy var leftButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.isHidden = true
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
        addSubview(leftButton)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LConstant.statusHeight).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: LConstant.topBarHeight).isActive = true
        
        cancleButton.translatesAutoresizingMaskIntoConstraints = false
        cancleButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        cancleButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        leftButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        leftButton.addTarget(self, action: #selector(leftButtonClick), for: .touchUpInside)
    }
    
}

extension LImagePickerNavView {
    
    
}


@objc
extension LImagePickerNavView {
    
    fileprivate func cancleButtonClick() {
        getControllerFromView()?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func leftButtonClick() {
        getControllerFromView()?.navigationController?.popViewController(animated: true)
    }
    
}
