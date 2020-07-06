//
//  LImageTabBarView.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

enum ImageTabBarButtonType: String {
    /** 完成 */
    case complete = "完成"
    /** 预览 */
    case preview = "预览"
    /** 编辑 */
    case edit = "编辑"
    /** 原图 */
    case original = "原图"
}

protocol ImageTabBarViewDelegate: NSObjectProtocol {
    func imageTabBarViewButton(_ buttonType: ImageTabBarButtonType)
}

extension ImageTabBarViewDelegate {
    func imageTabBarViewButton(_ buttonType: ImageTabBarButtonType) { }
}


class LImageTabBarView: UIView {

    public weak var delegate: ImageTabBarViewDelegate?
    
    public var maxCount: Int = 1 {
        didSet {
            previewButton.isHidden = maxCount == 1
        }
    }
    
    public var currentCount: Int = 0 {
        didSet {
            if currentCount == 0 {
                completeButton.setTitle("完成", for: .normal)
                completeButton.isUserInteractionEnabled = false
                previewButton.isUserInteractionEnabled = false
                completeButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(0.5), for: .normal)
                previewButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(0.5), for: .normal)
            }else {
                completeButton.setTitle("完成(\(currentCount)/\(maxCount))", for: .normal)
                completeButton.isUserInteractionEnabled = true
                previewButton.isUserInteractionEnabled = true
                completeButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(1.0) ,for: .normal)
                previewButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(1.0) ,for: .normal)
            }
            if currentCount == 1 {
                editButton.isUserInteractionEnabled = true
                editButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(1.0) ,for: .normal)
            }else {
                editButton.isUserInteractionEnabled = false
                editButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(0.5), for: .normal)
            }
            completeButton.l_width = completeButton.titleLabel?.intrinsicContentSize.width ?? 0
            completeButton.l_x = LConstant.screenWidth - 15 - completeButton.l_width
        }
    }
    
    fileprivate lazy var completeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: LConstant.screenWidth - 55, y: 4.5, width: 40, height: 40))
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor(white: 0, alpha: 0.5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate lazy var previewButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: 4.5, width: 40, height: 40))
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor(white: 0, alpha: 0.5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate lazy var editButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 60, y: 4.5, width: 40, height: 40))
        button.setTitle("编辑", for: .normal)
        button.setTitleColor(UIColor.lLabelColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    fileprivate lazy var originalButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 110, y: 4.5, width: 60, height: 40)
        button.setTitle("原图", for: .normal)
        editButton.setTitleColor(UIColor.lLabelColor.withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setImage(UIImage.imageNameFromBundle("icon_album_nor"), for: .normal)
        button.setImage(UIImage.imageNameFromBundle("icon_album_sel"), for: .selected)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- layoutView
    fileprivate func layoutView() {
        addSubview(completeButton)
        addSubview(previewButton)
        addSubview(editButton)
        addSubview(originalButton)
        completeButton.addTarget(self, action: #selector(completeButtonClick(_ :)), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewButtonClick(_ :)), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonClick(_ :)), for: .touchUpInside)
        originalButton.addTarget(self, action: #selector(originalButtonClick(_ :)), for: .touchUpInside)
        
        originalButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        originalButton.imageView?.contentMode = .scaleAspectFit
        
        let lineView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: 1))
        lineView.backgroundColor = UIColor.groupTableViewBackground
        addSubview(lineView)
    }
    
    // MARK:- Event
    @objc fileprivate func completeButtonClick(_ sender: UIButton) {
        delegate?.imageTabBarViewButton(.complete)
    }
    
    @objc fileprivate func previewButtonClick(_ sender: UIButton) {
        delegate?.imageTabBarViewButton(.preview)
    }

    @objc fileprivate func editButtonClick(_ sender: UIButton) {
        delegate?.imageTabBarViewButton(.edit)
    }
    
    @objc fileprivate func originalButtonClick(_ sender: UIButton) {
        originalButton.isSelected = !originalButton.isSelected
        delegate?.imageTabBarViewButton(.original)
    }
}
