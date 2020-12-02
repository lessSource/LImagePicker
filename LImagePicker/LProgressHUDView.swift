//
//  LProgressHUDView.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/12/2.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LProgressHUDView: UIView {

    public var style: LProgressHUDStyle
    
    var timeoutBlock = { }
    
    var timer: Timer?
    
    deinit {
        print(self, "+++++释放")
    }
    
    init(style: LProgressHUDStyle) {
        self.style = style
        super.init(frame: UIScreen.main.bounds)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - initView
    fileprivate func initView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 90))
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5.0
        view.backgroundColor = style.backColor
        view.clipsToBounds = true
        view.alpha = 0.8
        view.center = center
        
        if style == .lightBlur || style == .darkBlur {
            let effect = UIBlurEffect(style: style.blurEffectStyle!)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = view.bounds
            view.addSubview(effectView)
        }
        
        let indicator = UIActivityIndicatorView(style: style.indicatorStyle)
        indicator.frame = CGRect(x: (view.l_width - 30)/2, y: 15, width: 30, height: 30)
        indicator.startAnimating()
        view.addSubview(indicator)
        
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: view.l_width, height: 30))
        label.textAlignment = .center
        label.textColor = style.textColor
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "正在处理..."
        view.addSubview(label)
        
        addSubview(view)
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
extension LProgressHUDView {
    func timeout(_ timer: Timer) {
        timeoutBlock()
        hide()
    }
}
