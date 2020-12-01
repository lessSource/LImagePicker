//
//  LImageCroppingView.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LImageCroppingView: UIView {
    
    public var cropRect: CGRect =  CGRect(x: LConstant.screenWidth/2 - 150 , y: LConstant.screenHeight / 2 - 150 , width: 300, height: 300)
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        
        let path = UIBezierPath(rect: bounds)
        let shapeLayer = CAShapeLayer()
        path.append(UIBezierPath(arcCenter: center, radius: cropRect.size.width/2, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false))
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.opacity = 0.5
        layer.addSublayer(shapeLayer)
    }
    

}
