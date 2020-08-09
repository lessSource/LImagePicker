//
//  LShowImageFilterCell.swift
//  LImageShow
//
//  Created by L j on 2020/8/9.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LShowImageFilterCell: UICollectionViewCell {
    
    fileprivate lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        return label
    }()
    
    public var title: String = "" {
        didSet {
            label.text = title
        }
    }
    
    public var isSelect: Bool = false {
        didSet {
            label.backgroundColor = isSelect ? UIColor.black : UIColor.clear
            label.textColor = isSelect ? UIColor.white : UIColor.black
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initView() {
        addSubview(label)
    }
    
}
