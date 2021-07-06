//
//  PhotographContentView.swift
//  LImagePicker
//
//  Created by L on 2021/7/1.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

public class PhotographNavView: UIView {

    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.navViewTitleColor
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    public lazy var cancleButton: UIButton = {
        let button = UIButton(type: .custom)
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
        addSubview(cancleButton)
        cancleButton.frame = CGRect(x: 16, y: l_height - 35, width: 26, height: 26)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LConstant.statusHeight).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: LConstant.navbarAndStatusBar - LConstant.statusHeight).isActive = true
        
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
    }
    
    @objc fileprivate func cancleButtonClick() {
        guard let viewcontrollers = viewController()?.navigationController?.viewControllers else { return }
        if viewcontrollers.count > 1 {
            
            viewController()?.navigationController?.popViewController(animated: true)
        }else {
            viewController()?.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
}

class PhotographBottomView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

