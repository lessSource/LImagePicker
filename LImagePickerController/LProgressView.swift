//
//  LProgressView.swift
//  LImagePickerController
//
//  Created by L j on 2020/9/6.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LProgressView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var progressLayer: CAShapeLayer = {
        let progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.opacity = 1
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 5
        
        progressLayer.shadowColor = UIColor.black.cgColor
        progressLayer.shadowOffset = CGSize(width: 1, height: 1)
        progressLayer.shadowOpacity = 0.5
        progressLayer.shadowRadius = 2
        
        return progressLayer
    }()
    
    public var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = rect.width / 2
        let startA = -CGFloat.pi / 2
        let endA = startA + CGFloat.pi * 2.0 * progress
        progressLayer.frame = bounds
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startA, endAngle: endA, clockwise: true)
        progressLayer.path = path.cgPath
        progressLayer.removeFromSuperlayer()
        layer.addSublayer(progressLayer)
    }
    

}
