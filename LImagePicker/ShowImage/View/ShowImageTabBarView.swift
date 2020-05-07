//
//  ShowImageTabBarView.swift
//  ImagePicker
//
//  Created by Lj on 2019/10/5.
//  Copyright © 2019 Less. All rights reserved.
//

import UIKit

class ShowImageTabBarView: UIView {

    public weak var imageDelegate: ShowImageNavTabDelegate?
                
    public var maxCount: Int = 1
    
    public var selectCount: Int = 0 {
        didSet {
            if selectCount == 0 {
                completeButton.setTitle("完成", for: .normal)
                completeButton.isUserInteractionEnabled = false
                completeButton.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
            }else {
                completeButton.setTitle("完成(\(selectCount)/\(maxCount))", for: .normal)
                completeButton.isUserInteractionEnabled = true
                completeButton.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
            }
            completeButton.l_width = completeButton.titleLabel?.intrinsicContentSize.width ?? 0
            completeButton.l_x = LConstant.screenWidth - 15 - completeButton.l_width
        }
    }
    
    fileprivate lazy var completeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: LConstant.screenWidth - 55, y: 4.5, width: 40, height: 40))
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    public lazy var originalButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 15, y: 4.5, width: 75, height: 40))
        button.setTitle("原图", for: .normal)
        button.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setImage(UIImage.imageNameFromBundle("icon_album_nor"), for: .normal)
        button.setImage(UIImage.imageNameFromBundle("icon_album_sel"), for: .selected)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- layoutView
    fileprivate func layoutView() {
        addSubview(completeButton)
        addSubview(originalButton)
        completeButton.addTarget(self, action: #selector(completeButtonClick), for: .touchUpInside)
        originalButton.addTarget(self, action: #selector(originalButtonClick), for: .touchUpInside)
    }
    
    // MARK:- click
    @objc fileprivate func completeButtonClick() {
        imageDelegate?.showImageBarDidSelect(self, buttonType: .complete)
    }
    
    @objc fileprivate func originalButtonClick() {
        originalButton.isSelected = !originalButton.isSelected
        imageDelegate?.showImageBarDidSelect(self, buttonType: .original)
    }

}
