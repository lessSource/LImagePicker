//
//  LShowImageNavView.swift
//  LImageShow
//
//  Created by L j on 2020/6/19.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

class LShowImageNavView: UIView {
    public weak var imageDelegate: LShowImageNavTabDelegate?
    
    fileprivate lazy var configuration = LShowImageConfiguration()
    
    public var isImageSelect: Bool = false {
        didSet {
//            selectImageView.image = !isImageSelect ? UIImage.imageNameFromBundle("icon_album_nor") : UIImage.imageNameFromBundle("icon_album_sel")
        }
    }
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 10, y: LConstant.statusHeight, width: 44, height: 44))
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    public lazy var selectImageView: UIImageView = {
        let image = UIImageView(frame: CGRect(x: LConstant.screenWidth - 34, y: LConstant.statusHeight + 10, width: 24, height: 24))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    public lazy var selectButton: UIButton = {
        let button = UIButton(frame: CGRect(x: LConstant.screenWidth - 44, y: LConstant.statusHeight, width: 44, height: 44))
        return button
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 100, y: LConstant.statusHeight, width: LConstant.screenWidth - 200, height: 44))
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    }
    
    convenience init(frame: CGRect, configuration: LShowImageConfiguration) {
        self.init(frame: frame)
        self.configuration = configuration
        layoutView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- layoutView
    fileprivate func layoutView() {
        addSubview(titleLabel)
        addSubview(selectImageView)
        addSubview(selectButton)
        addSubview(backButton)
        
        if configuration.isDelete {
//            selectImageView.image = UIImage.imageNameFromBundle("icon_del")
        }
        if configuration.isSelect {
            //            addSubview(backButton)
            //            backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        }
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectButtonClick(_ :)), for: .touchUpInside)
    }
    
    // MARK:- public
    public func selectImageViewAnimation(_ isSelect: Bool) {
        isImageSelect = isSelect
    }
    
    // MARK:- Event
    @objc fileprivate func backButtonClick() {
        getControllerFromView()?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func selectButtonClick(_ sender: UIButton) {
        imageDelegate?.showImageNavDidSelect(self, buttonType: .select)
    }
    
    
}
