//
//  LImagePickerNavView.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImagePickerNavView: UIView {
    
    public weak var delegate: LImagePickerButtonProtocl?
    
    fileprivate lazy var cancleButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = UIColor.navViewTitleColor
        return label
    }()
    
    // MARK: - 选择序号
    fileprivate lazy var selectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isHidden = true
        return button
    }()
    
    fileprivate lazy var selectImageView: UIImageView = {
        let selectImageView = UIImageView()
        selectImageView.contentMode = .scaleAspectFit
        selectImageView.clipsToBounds = true
        selectImageView.isHidden = true
        return selectImageView
    }()
    
    fileprivate lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.mediaSelectColor
        label.textColor = UIColor.mediaSelectTextColor
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    fileprivate lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("完成", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.backgroundColor = UIColor.bottomViewConfirmBackColor
        button.isHidden = true
        button.layer.cornerRadius = 14
        return button
    }()
    
    public var isPreviewButton: Bool = false {
        didSet {
            selectButton.isHidden = !isPreviewButton
            selectImageView.isHidden = !isPreviewButton
            completeButton.isHidden = isPreviewButton
        }
    }
    
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var titleColor: UIColor = UIColor.clear {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    public var cancleImageStr: String = "" {
        didSet {
            cancleButton.setImage(UIImage.lImageNamedFromMyBundle(name: cancleImageStr), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        cancleButton.frame = CGRect(x: 16, y: l_height - 35, width: 26, height: 26)
        titleLabel.frame = CGRect(x: l_width/2 - 50, y: LConstant.statusHeight, width: 100, height: LConstant.topBarHeight)
        selectImageView.frame = CGRect(x: l_width - 40, y: l_height - 34, width: 24, height: 24)
        indexLabel.frame = selectImageView.frame
        selectButton.frame = CGRect(x: l_width - 44, y: l_height - 44, width: 44, height: 44)
        completeButton.frame = CGRect(x: l_width - 70, y: l_height - 36, width: 55, height: 28)
        
        addSubview(cancleButton)
        addSubview(titleLabel)
        addSubview(selectImageView)
        addSubview(indexLabel)
        addSubview(selectButton)
        addSubview(completeButton)
        
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonClick), for: .touchUpInside)
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(titleTapClick))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(titleTap)
    }
    
    public func selectSerialNumber(index: Int) {
        selectImageView.isHidden = false
        if index == 0 {
            selectImageView.image = UIImage.lImageNamedFromMyBundle(name: "icon_photograph_nor")
        }else {
            selectImageView.image = UIImage.lImageNamedFromMyBundle(name: "icon_photograph_sel")
        }
    }
    

}

@objc
extension LImagePickerNavView {
    
    fileprivate func cancleButtonClick() {
        delegate?.buttonView(view: self, buttonType: .cancle)
    }
    
    fileprivate func selectButtonClick() {
        delegate?.buttonView(view: self, buttonType: .previewSelect)
    }
    
    fileprivate func titleTapClick() {
        delegate?.buttonView(view: self, buttonType: .title)
    }
    
}

