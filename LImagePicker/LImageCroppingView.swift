//
//  LImageCroppingView.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImageCroppingView: UIView {
    
    public var cropRect: CGRect =  CGRect.zero
    
    public var needCircleCrop: Bool = true
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    public func drawCroppingView() {
        guard let imagePicker =  viewController()?.navigationController as? LImagePickerController else { return }
        cropRect = imagePicker.cropRect
        needCircleCrop = imagePicker.needCircleCrop
        
        let path = UIBezierPath(rect: bounds)
        let shapeLayer = CAShapeLayer()
        if needCircleCrop {
            path.append(UIBezierPath(arcCenter: center, radius: cropRect.size.width/2, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false))
        }else {
            path.append(UIBezierPath(rect: cropRect))
        }
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.opacity = 0.5
        layer.addSublayer(shapeLayer)
    }
    

}
