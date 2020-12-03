//
//  LImagePickerBottomView.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImagePickerBottomView: UIView {
    
    public weak var delegate: LImagePickerButtonProtocl?
    
    fileprivate lazy var previewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor.buttonViewPreviewNorColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    fileprivate lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.bottomViewConfirmColor, for: .normal)
        button.backgroundColor = UIColor.bottomViewConfirmNorBackColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    fileprivate lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.bottomViewTitleColor
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.text = "已选0张"
        label.isHidden = true
        return label
    }()
    
    public var isPreviewHidden: Bool = false {
        didSet {
            previewButton.isHidden = isPreviewHidden
        }
    }
    
    public var number: Int = 0 {
        didSet {
            numberLabel.isHidden = false
            numberLabel.text = "已选\(number)张"
            numberLabel.l_width = numberLabel.intrinsicContentSize.width
        }
    }
    
    public var isConfirmSelect: Bool = true {
        didSet {
            previewButton.isUserInteractionEnabled = isConfirmSelect
            previewButton.setTitleColor(isConfirmSelect ? UIColor.bottomViewPreviewColor : UIColor.buttonViewPreviewNorColor , for: .normal)
            confirmButton.isUserInteractionEnabled = isConfirmSelect
            confirmButton.backgroundColor = isConfirmSelect ? UIColor.bottomViewConfirmBackColor : UIColor.bottomViewConfirmNorBackColor
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
        previewButton.frame = CGRect(x: 16, y: 15, width: previewButton.intrinsicContentSize.width, height: previewButton.intrinsicContentSize.height)
        confirmButton.frame = CGRect(x: LConstant.screenWidth - 88, y: 9, width: 72, height: 32)
        numberLabel.frame = CGRect(x: 16, y: 9, width: numberLabel.intrinsicContentSize.width, height: 32)
        addSubview(previewButton)
        addSubview(confirmButton)
        addSubview(numberLabel)
        
        previewButton.addTarget(self, action: #selector(previewButtonClick), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonClick), for: .touchUpInside)
    }
    
}

@objc
extension LImagePickerBottomView {
    
    fileprivate func previewButtonClick() {
        delegate?.buttonView(view: self, buttonType: .preview)
    }
    
    fileprivate func confirmButtonClick() {
        delegate?.buttonView(view: self, buttonType: .confirm)
    }
    
}
