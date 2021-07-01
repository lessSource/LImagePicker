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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: LConstant.statusHeight).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: LConstant.navbarAndStatusBar - LConstant.statusHeight).isActive = true
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

