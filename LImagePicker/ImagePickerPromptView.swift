//
//  LImagePickerPromptView.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

protocol PromptViewDelegate: AnyObject {
    
    func promptViewButtonClick(_ promptView: ImagePickerPromptView)
    
    func promptViewImageClick(_ promptView: ImagePickerPromptView)
}

extension PromptViewDelegate {
    
    func promptViewButtonClick(_ promptView: ImagePickerPromptView) { }
    
    func promptViewImageClick(_ promptView: ImagePickerPromptView) { }
}

class ImagePickerPromptView: UIView {

    public weak var delegate: PromptViewDelegate?
    
    public lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("重新加载", for: .normal)
        button.frame = CGRect(origin: CGPoint(x: (bounds.width - button.intrinsicContentSize.width)/2, y: titleLabel.frame.maxY + 5), size: button.intrinsicContentSize)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: (bounds.width - 150)/2, y: 150, width: 150, height: 120))
        imageView.image = UIImage(named: "hp_pc_bacao")
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 15, y: imageView.frame.maxY + 10, width: bounds.width - 30, height: 30))
        title.font = UIFont.boldSystemFont(ofSize: 15)
        title.textColor = UIColor.withHex(hexString: "#B1BDCB")
        title.numberOfLines = 0
        title.text = "暂无数据"
        title.isUserInteractionEnabled = true
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("++++++\(self)");
    }
    
    // MARK:- setUpUI
    private func setUpUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(button)
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageClick))
        imageView.addGestureRecognizer(tapGesture)
        let laberTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapClick))
        titleLabel.addGestureRecognizer(laberTapGesture)
    }
    
    fileprivate func titleFrame() {
        var frame: CGRect = titleLabel.frame
        frame.origin.y = imageView.frame.maxY + 10
        titleLabel.frame = frame
        var buttonFrame: CGRect = button.frame
        buttonFrame.origin.y = titleLabel.frame.maxY + 5
        button.frame = buttonFrame
    }
    
    // MARK:- public
    /** 占位view的位置 */
    public func viewFrame(_ frame: CGRect) {
        self.frame = frame
    }
    /** 占位图片位置 */
    public func imageFrame(_ frame: CGRect) {
        imageView.frame = frame
        titleFrame()
    }
    /** 占位图片 */
    public func imageName(_ image: String) {
        imageView.image = UIImage.lImageNamedFromMyBundle(name: image)
    }
    
    public func image(_ image: UIImage?) {
        imageView.image = image
    }
    
    /** 图片距上位置 */
    public func imageTop(_ top: CGFloat) {
        var frame: CGRect = imageView.frame
        frame.origin.y = top
        imageView.frame = frame
        titleFrame()
    }
    /** 提示文字 */
    public func title(_ title: String) {
        let attributedString = NSMutableAttributedString(string: title)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: title.count))
        titleLabel.attributedText = attributedString
        titleLabel.l_height = titleLabel.intrinsicContentSize.height
    }
    
    /** 对齐方式 */
    public func alignment(_ alignment: NSTextAlignment) {
        titleLabel.textAlignment = alignment
    }
    
    /** 提示文字大小 */
    public func titleFont(_ font: UIFont) {
        titleLabel.font = font
    }
    /** 提示文字颜色 */
    public func titleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    /** button显示 */
    public func isButtonHidden(_ hidden: Bool) {
        button.isHidden = hidden
    }
    
    // MARK:- Event
    @objc fileprivate func buttonClick() {
        delegate?.promptViewButtonClick(self)
    }
    @objc fileprivate func imageClick() {
        delegate?.promptViewImageClick(self)
    }
    @objc fileprivate func labelTapClick() {
        delegate?.promptViewImageClick(self)
    }
    
}


extension UIView {
    
    typealias PromptViewClosure = (_ promptView: ImagePickerPromptView) -> ()
    
    func placeholderShow(_ show: Bool,_ promptViewClosure: PromptViewClosure? = nil) {
        if show {
            showPromptView()
            promptViewClosure?(promptView)
        }else {
            promptView.removeFromSuperview()
        }
    }
    
    // MARK:- private
    private func showPromptView() {
        if self.subviews.count > 0 {
            var t_v = self
            for v in self.subviews {
                if v.isKind(of: UIScrollView.self) {
                    t_v = v
                }
            }
            t_v.insertSubview(promptView, aboveSubview: t_v.subviews[0])
            promptView.backgroundColor = t_v.backgroundColor
        }else {
            self.addSubview(promptView)
        }
    }
    
    private struct AssociatedKeys {
        static var PromptViewKey: String = "PromptViewKey"
    }
    
    private var promptView: ImagePickerPromptView {
        get {
            guard let view = objc_getAssociatedObject(self, &AssociatedKeys.PromptViewKey) as? ImagePickerPromptView else {
                return generatePromptView()
            }
            return view
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.PromptViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private func generatePromptView() -> ImagePickerPromptView {
        let view: ImagePickerPromptView = ImagePickerPromptView(frame: bounds)
        promptView = view
        return view
    }
    
}
