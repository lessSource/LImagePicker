//
//  LImageCameraOperationView.swift
//  LImageCamera
//
//  Created by L j on 2020/7/7.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

enum LImageCameraOperationType: String {
    case shooting = "拍摄"
    case suspended = "暂停"
    case taking = "拍照"
    case remake = "重拍"
}

protocol LImageCameraOperationDelegate: class {
    
    func operationViewDidSelect(buttonType: LImageCameraOperationType)
    
    func operationViewPlayStatus() -> Bool
    
}

class LImageCameraOperationView: UIView {

    public weak var delegate: LImageCameraOperationDelegate?
    
    fileprivate lazy var cancleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 15, y: LConstant.statusHeight + 10, width: 45, height: 30))
        button.setTitle("取消", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    fileprivate lazy var completeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: LConstant.screenWidth - 60, y: LConstant.statusHeight + 10, width: 45, height: 30))
        button.setTitle("完成", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    
    // 摄像按钮
    fileprivate lazy var takingView: UIView = {
        let view = UIView(frame: CGRect(x: LConstant.screenWidth/2 - 30, y: LConstant.screenHeight - 130, width: 60, height: 60))
        view.layer.cornerRadius = 30
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // 圆环
    fileprivate lazy var ringView: RingShapLayerView = {
        let view = RingShapLayerView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        view.center = takingView.center
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        addSubview(cancleButton)
        addSubview(completeButton)
        addSubview(ringView)
        addSubview(takingView)
        cancleButton.addTarget(self, action: #selector(cancleButtonClick(_ :)), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureClick))
        takingView.addGestureRecognizer(tapGesture)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureClick(_ :)))
        takingView.addGestureRecognizer(longGesture)
        
    }
    
    public func shootingComplete() {
        cancleButton.setTitle("重拍", for: .normal)
        completeButton.isHidden = false
        ringView.isHidden = true
        ringView.animate(0)
        takingView.isHidden = true
    }
    
    
    @objc fileprivate func cancleButtonClick(_ sender: UIButton) {
        if sender.currentTitle == "取消" {
            getControllerFromView()?.dismiss(animated: true, completion: nil)
        }else {
            cancleButton.setTitle("取消", for: .normal)
            delegate?.operationViewDidSelect(buttonType: .remake)
            completeButton.isHidden = true
            takingView.isHidden = false
            ringView.isHidden = false
        }
        
    }
    
    @objc fileprivate func tapGestureClick() {
        delegate?.operationViewDidSelect(buttonType: .taking)
    }
    
    @objc fileprivate func longGestureClick(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            takingAnimation(0.5, radius: 5, forKey: "startAnimationKey")
            delegate?.operationViewDidSelect(buttonType: .shooting)
        case .ended:
            takingAnimation(1, radius: 30, forKey: "endAnimationKey")
            delegate?.operationViewDidSelect(buttonType: .suspended)
        default: break
        }
    }
    
    
    public func shootingAnimate(_ progress: CGFloat) {
        ringView.animate(progress)
    }
    
    // 按钮动画
    fileprivate func takingAnimation(_ scale: CGFloat, radius: CGFloat, forKey: String) {
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 0.3
        groupAnimation.repeatCount = 1
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = .forwards
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.toValue = scale
        let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        radiusAnimation.toValue = radius
        groupAnimation.animations = [scaleAnimation, radiusAnimation]
        
        takingView.layer.add(groupAnimation, forKey: forKey)
    }

    
}

class RingShapLayerView: UIView {
        
    fileprivate lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        layer.addSublayer(shapeLayer)
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.height/2, y: bounds.width/2), radius: bounds.width/2, startAngle: CGFloat(Double.pi * 3/2), endAngle: CGFloat(Double.pi * 2 + Double.pi * 3/2), clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 5
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.fillColor = UIColor.clear.cgColor
    }
    
    public func animate(_ progress: CGFloat) {
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.strokeEnd = progress
    }
}
