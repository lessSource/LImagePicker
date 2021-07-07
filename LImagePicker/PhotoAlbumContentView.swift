//
//  PhotoAlbumContentView.swift
//  LImagePicker
//
//  Created by L on 2021/7/2.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

public class PhotoAlbumNavView: UIView {

    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.navViewTitleColor
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    public lazy var cancleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.lImageNamedFromMyBundle(name: "icon_close_white"), for: .normal)
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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: LConstant.statusHeight).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: LConstant.navbarAndStatusBar - LConstant.statusHeight).isActive = true
        
        cancleButton.translatesAutoresizingMaskIntoConstraints = false
        cancleButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        cancleButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        cancleButton.heightAnchor.constraint(equalToConstant: 26).isActive = true
        cancleButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        cancleButton.addTarget(self, action: #selector(cancleButtonClick), for: .touchUpInside)
    }
    
    @objc fileprivate func cancleButtonClick() {
        viewController()?.dismiss(animated: true, completion: nil)
    }
    
    
}

