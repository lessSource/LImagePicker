//
//  PhotographContentView.swift
//  LImagePicker
//
//  Created by L on 2021/7/1.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

public enum PhotographButtonType {
    // 完成
    case complete
    // 预览
    case preview
}

public protocol PhotographViewDelegate: AnyObject {
    
    func photographView(_ view: UIView, didSelect type: PhotographButtonType)
    
}

public class PhotographNavView: UIView {

    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.navViewTitleColor
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    public lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    public lazy var cancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        addSubview(titleLabel)
        addSubview(backButton)
        addSubview(cancleButton)

        backButton.frame = CGRect(x: 16, y: l_height - 35, width: 26, height: 26)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LConstant.statusHeight).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: LConstant.navbarAndStatusBar - LConstant.statusHeight).isActive = true
        
        cancleButton.translatesAutoresizingMaskIntoConstraints = false
        cancleButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        cancleButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        
        
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
    }
    
    @objc fileprivate func backButtonClick() {
        guard let viewcontrollers = viewController()?.navigationController?.viewControllers else { return }
        if viewcontrollers.count > 1 {
            
            viewController()?.navigationController?.popViewController(animated: true)
        }else {
            viewController()?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func cancleButtonClick() {
        viewController()?.dismiss(animated: true, completion: nil)
    }
    
    
}

public class PhotographBottomView: UIView {
    
    public weak var delegate: PhotographViewDelegate?
    
    public lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor.bottomViewConfirmNorBackColor
        button.layer.cornerRadius = 20
        return button
    }()

    
    public lazy var previewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor.buttonViewPreviewNorColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    
    public lazy var originalView: OriginalButtonView = {
        let originalView = OriginalButtonView()
        return originalView
    }()
    
    
    public var alwaysEnableDoneBtn: Bool = false {
        didSet {
            completeButton.backgroundColor = !alwaysEnableDoneBtn ? UIColor.bottomViewConfirmNorBackColor : UIColor.bottomViewConfirmBackColor
            completeButton.isUserInteractionEnabled = alwaysEnableDoneBtn
        }
    }
    
    public var number: Int = 0 {
        didSet {
            completeButton.setTitle(number == 0 ? "完成" : "完成(\(number))", for: .normal)
            previewButton.setTitleColor(number == 0 ? UIColor.buttonViewPreviewNorColor : UIColor.bottomViewPreviewColor, for: .normal)
            previewButton.isUserInteractionEnabled = number != 0
            if !alwaysEnableDoneBtn {
                completeButton.backgroundColor = number == 0 ? UIColor.bottomViewConfirmNorBackColor : UIColor.bottomViewConfirmBackColor
                completeButton.isUserInteractionEnabled = number != 0
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        addSubview(completeButton)
        addSubview(previewButton)
        addSubview(originalView)
        
        completeButton.addTarget(self, action: #selector(completeButtonClick), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewButtonClick), for: .touchUpInside)
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        completeButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -LConstant.barHeight/2).isActive = true

        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor).isActive = true
        previewButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        
        originalView.translatesAutoresizingMaskIntoConstraints = false
        originalView.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor).isActive = true
        originalView.leftAnchor.constraint(equalTo: previewButton.rightAnchor, constant: 15).isActive = true
        originalView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        originalView.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    @objc fileprivate func completeButtonClick() {
        delegate?.photographView(self, didSelect: .complete)
    }
    
    @objc fileprivate func previewButtonClick() {
        delegate?.photographView(self, didSelect: .preview)
    }
    
    @objc fileprivate func originalButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
    }
}


public class OriginalButtonView: UIView {
    
    fileprivate(set) var isSelect: Bool = false {
        didSet {
            iconImage.image = UIImage.lImageNamedFromMyBundle(name: isSelect ? "icon_photograph_sel" : "icon_photograph_nor")
        }
    }
    
    fileprivate lazy var iconImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.lImageNamedFromMyBundle(name: "icon_photograph_nor")
        return image
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "原图"
        label.textColor = UIColor.bottomViewPreviewColor
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- initView
    fileprivate func initView() {
        addSubview(iconImage)
        addSubview(nameLabel)
        
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.heightAnchor.constraint(equalToConstant: 18).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 18).isActive = true
        iconImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 5).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureClick))
        addGestureRecognizer(tapGesture)
    }
    
    @objc fileprivate func tapGestureClick() {
        isSelect = !isSelect
    }
    
    
}

