//
//  ProgressHUDView.swift
//  LImagePicker
//
//  Created by L. on 2020/12/2.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class ProgressHUDView: UIView {
    
    fileprivate var style: ProgressHUDStyle
    
    public var timeoutBlock = { }
    
    fileprivate var timer: Timer?
    
    fileprivate lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = style.textColor
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "正在处理..."
        return label
    }()
    
    fileprivate lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: style.indicatorStyle)
        return indicator
    }()
    
    fileprivate lazy var backView: LBackgroundView = {
        let backView = LBackgroundView()
        backView.blurEffectStyle = .dark
        return backView
    }()
    
    deinit {
        print(self, "+++++释放")
    }
    
    init(style: ProgressHUDStyle, prompt: String = "") {
        self.style = style
        super.init(frame: UIScreen.main.bounds)
        initView(prompt: prompt)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - initView
    fileprivate func initView(prompt: String = "") {
        if prompt.isEmpty {
            addSubview(backView)
            backView.addSubview(indicator)
            backView.addSubview(promptLabel)
            backView.frame = CGRect(x: 0, y: 0, width: 110, height: 90)
            backView.center = center
            indicator.frame = CGRect(x: (backView.l_width - 30)/2, y: 15, width: 30, height: 30)
            indicator.startAnimating()
            promptLabel.frame = CGRect(x: 0, y: 50, width: backView.l_width, height: 30)
        }else {
            addSubview(backView)
            backView.addSubview(promptLabel)
            promptLabel.text = prompt
            backView.frame = CGRect(x: 0, y: 0, width: promptLabel.intrinsicContentSize.width + 20, height: 44)
            backView.center = center
            promptLabel.frame = backView.bounds
        }
    }
 
    
    public func show(timeout: TimeInterval = 30, showView: UIView?) {
        DispatchQueue.main.async {
            if let view = showView {
                view.addSubview(self)
            }else {
                UIApplication.shared.keyWindow?.addSubview(self)
            }
        }
        if timeout > 0 {
            cleanTimer()
            timer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(timeout(_:)), userInfo: nil, repeats: false)
        }
    }
        
    public func showPromptInfo(showView: UIView?) {
        DispatchQueue.main.async {
            if let view = showView {
                view.addSubview(self)
            }else {
                UIApplication.shared.keyWindow?.addSubview(self)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hide()
        }

    }
    
    
    public func hide() {
        cleanTimer()
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
        
    fileprivate func cleanTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}

@objc
extension ProgressHUDView {
    func timeout(_ timer: Timer) {
        timeoutBlock()
        hide()
    }
}

enum LProgressHUDBackgroundStyle {
    case solideColor
    case blur
}


class LBackgroundView: UIView {
    
    public var style: LProgressHUDBackgroundStyle = .blur {
        didSet {
            if style == oldValue { return }
            updateForBackgroundStyle()
        }
    }
    
    public var blurEffectStyle: UIBlurEffect.Style = .light {
        didSet {
            if blurEffectStyle == oldValue { return }
            updateForBackgroundStyle()
        }
    }
    
    public var color: UIColor = UIColor(white: 0.8, alpha: 0.6) {
        didSet {
            backgroundColor = color
        }
    }
    
    fileprivate var effectView: UIVisualEffectView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    
    fileprivate func updateForBackgroundStyle() {
        effectView?.removeFromSuperview()
        effectView = nil
        if style == .blur {
            let effect = UIBlurEffect(style: blurEffectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            insertSubview(effectView, at: 0)
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            backgroundColor = color
            layer.allowsGroupOpacity = false
            self.effectView = effectView
        }else {
            backgroundColor = color
        }
    }
    
    
}
