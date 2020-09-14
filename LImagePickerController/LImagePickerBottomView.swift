//
//  LImagePickerBottomView.swift
//  LImagePickerController
//
//  Created by L j on 2020/9/7.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImagePickerBottomView: UIView {
    
    fileprivate lazy var previewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("预览", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.lLabelColor.withAlphaComponent(0.5), for: .normal)
        return button
    }()
    
    fileprivate lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        return button
    }()
    
    fileprivate lazy var originalButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("原图", for: .normal)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setImage(UIImage.imageNameFromBundle("icon_album_nor"), for: .normal)
        button.setImage(UIImage.imageNameFromBundle("icon_album_sel"), for: .selected)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - initView
    fileprivate func initView() {
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: 0.5))
        lineView.backgroundColor = UIColor.lLineColor
        addSubview(lineView)
        addSubview(previewButton)
        addSubview(completeButton)
        addSubview(originalButton)
        
        previewButton.addTarget(self, action: #selector(previewButtonClick), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonClick), for: .touchUpInside)
        originalButton.addTarget(self, action: #selector(originalButtonClick), for: .touchUpInside)

        
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        previewButton.heightAnchor.constraint(equalToConstant: self.l_height - LConstant.barHeight).isActive = true
        previewButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: self.l_height - LConstant.barHeight).isActive = true
        completeButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

        originalButton.translatesAutoresizingMaskIntoConstraints = false
        originalButton.centerYAnchor.constraint(equalTo: previewButton.centerYAnchor).isActive = true
        originalButton.leftAnchor.constraint(equalTo: previewButton.rightAnchor, constant: 10).isActive = true
        originalButton.heightAnchor.constraint(equalToConstant: self.l_height - LConstant.barHeight).isActive = true
        originalButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
}

@objc
extension LImagePickerBottomView {
    
    // 预览
    fileprivate func previewButtonClick() {
        print("预览")
    }
    
    // 完成
    fileprivate func completeButtonClick() {
        print("完成")
    }
    
    // 原图
    fileprivate func originalButtonClick() {
        print("原图")
    }
}
