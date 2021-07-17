////
////  TestViewController.swift
////  LImagePickerDemo
////
////  Created by L j on 2020/9/9.
////  Copyright © 2020 L. All rights reserved.
////
//
//import UIKit
//import LPublicImageParameter
//
//enum FilterType {
//    case normal      // 默认
//    case gray        // 灰度
//    case split2      // 二分屏
//    case split9      // 九分屏
//    case upsideDown  // 颠倒
//    case mosaic1     // 马赛克1
//    case mosaic2     // 马赛克2
//    case mosaic3     // 马赛克3
//    case zoom        // 缩放
//    case outside     // 灵魂出窍
//    case jitter      //
//    case flashWhite  // 闪白
//    case illusion    //
//    case burr        // 毛刺
//    
//    var filterName: String {
//        switch self {
//        case .normal:
//            return "Normal"
//        case .gray:
//            return "Gray"
//        case .split2:
//            return "SplitScreen2"
//        case .split9:
//            return "SplitScreen9"
//        case .upsideDown:
//            return "UpsideDown"
//        case .mosaic1:
//            return "Mosaic1"
//        case .mosaic2:
//            return "Mosaic2"
//        case .mosaic3:
//            return "Mosaic3"
//        case .zoom:
//            return "Zoom"
//        case .outside:
//            return "Outside"
//        case .jitter:
//            return "Jitter"
//        case .flashWhite:
//            return "FlashWhite"
//        case .illusion:
//            return "Illusion"
//        case .burr:
//            return "Burr"
//            
//        }
//    }
//    
//}
//
//public class TestViewController: UIViewController {
//
//    fileprivate lazy var navView: LEditPickerNavView = {
//        let navView = LEditPickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
//        return navView
//    }()
//    
//    fileprivate var dataArray = [FilterType]()
//    
//    fileprivate var myView: FilterView!
//    
//    public var contentImage: UIImage?
//    
//    deinit {
////        myView.removeDisplayLink()
//        print("++++++++", self)
//    }
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        title = "修改"
//        view.backgroundColor = UIColor.white
//        
//        view.addSubview(navView)
//        dataArray = [.normal, .gray, .split2, .split9, .upsideDown, .mosaic1, .mosaic2, .mosaic3, .zoom, .outside, .jitter, .flashWhite, .illusion, .burr]
//
//        
//        DispatchQueue.main.asyncAfter(deadline: .now()) {
//            self.myView = FilterView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar - 100), contentImage: self.contentImage!)
//            self.view.addSubview(self.myView)
//            
//            
//            let filerBarView = LShowImageFilterBar(frame: CGRect(x: 0, y: LConstant.screenHeight - 100, width: LConstant.screenWidth, height: 100))
//            filerBarView.delegate = self
//            self.view.addSubview(filerBarView)
//            
//            filerBarView.itemList = self.dataArray
//        }
//        
//    }
//
//
//}
//
//extension TestViewController: LShowImageFilterBarDelegate {
//    
//    func filterBar(_ filterBar: LShowImageFilterBar, index: Int) {
//        self.myView.setupsetupShaderProgram(dataArray[index].filterName)
//    }
//}


class TTTTTViewController: UIViewController {
    
    public var contentViewHeight: CGFloat = 206

    fileprivate lazy var backView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.withHex(hexString: "#000000", alpha: 0.0)
        return view
    }()
    
    fileprivate(set) lazy var contentView: UIView = {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: Constant.screenWidth - 48, height: contentViewHeight))
        contentView.backgroundColor = UIColor.white
        contentView.center = self.view.center
        contentView.layer.cornerRadius = 16
        return contentView
    }()
    
    /** 动画时间 */
    public var animationTime: TimeInterval = 0.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        initView()
    }
    
    // MARK: - initView
    fileprivate func initView() {
        view.addSubview(backView)
        view.addSubview(contentView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureClick))
        backView.addGestureRecognizer(tapGesture)
        UIView.animate(withDuration: animationTime) {
            self.backView.backgroundColor = UIColor.withHex(hexString: "#000000", alpha: 0.3)
        }
        contentView.layer.add(alertViewShowAnimation(), forKey: nil)
    }
    
    
    @objc fileprivate func tapGestureClick() {
        cancelAnimation {
//            self.backDidSelectClosure()
        }
    }
    
    fileprivate func cancelAnimation(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationTime, animations: {
            self.contentView.alpha = 0.0
            self.backView.backgroundColor = UIColor.withHex(hexString: "#000000", alpha: 0.0)
        }) { (finished) in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    fileprivate func alertViewShowAnimation() -> CAAnimation {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.keyTimes = [0, 0.5, 1.0]
        scaleAnimation.values = [0.01, 0.5, 1.0]
        scaleAnimation.duration = animationTime
        
        let opacityAnimaton = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimaton.keyTimes = [0, 0.5, 1]
        opacityAnimaton.values = [0.01, 0.5, 1.0]
        opacityAnimaton.duration = animationTime
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnimation, opacityAnimaton]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = animationTime
        return animation
    }
    
}


extension UIColor {
    
    /** 随机颜色 */
    public class var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
    }
    
    /** 颜色图片 */
    public func creatImageWithColor(_ width: CGFloat = 1.0, height: CGFloat = 1.0) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func withHex(hexString hex: String, alpha: CGFloat = 1) -> UIColor {
        // 去除空格
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        // 去除#
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if cString.count == 6 {
            var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0
            Scanner(string: cString[0..<2]).scanHexInt32(&red)
            Scanner(string: cString[2..<4]).scanHexInt32(&green)
            Scanner(string: cString[4..<6]).scanHexInt32(&blue)
            return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
        }else if cString.count == 8 {
            var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0, a: UInt32 = 0
            Scanner(string: cString[0..<2]).scanHexInt32(&red)
            Scanner(string: cString[2..<4]).scanHexInt32(&green)
            Scanner(string: cString[4..<6]).scanHexInt32(&blue)
            Scanner(string: cString[6..<8]).scanHexInt32(&a)
            return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(a) / 255.0)
        }else {
            return UIColor.gray
        }
        
    }
    
    
    
}


extension String {
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: min(self.count, r.lowerBound))
            let endIndex = self.index(self.startIndex, offsetBy: min(r.upperBound, self.count))
            return String(self[startIndex..<endIndex])
        }
    }
    
}


struct Constant {
    /** 屏幕宽度 */
    public static var screenWidth: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    /** 屏幕高度 */
    public static var screenHeight: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    /** 状态栏高度 */
    public static var statusHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    /** navtiveTitleView高度 */
    public static var topBarHeight: CGFloat {
        return 44.0
    }
    /** 头部高度 */
    public static var navbarAndStatusBar: CGFloat {
        return (statusHeight + topBarHeight)
    }
//    /** 标签栏 */
//    public static var bottomBarHeight: CGFloat {
//        return UIDevice.current.isIphone_X ? 83.0 : 49.0
//    }
//    /** 安全边界 */
//    public static var barHeight: CGFloat {
//        return UIDevice.current.isIphone_X ? 34.0 : 0.0
//    }
//    public static var barMargin: CGFloat {
//        return UIDevice.current.isIphone_X ? 20.0 : 0.0
//    }
    /** 不同设备的屏幕比例 */
    public static var sizeScale: CGFloat {
//        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
//            return screenHeight > 375.0 ? screenHeight/375.0 : 1
//        }else {
            return screenWidth > 375.0 ? screenWidth/375.0 : 1
//        }
    }
    /** 线高 */
    public static var lineHeight: CGFloat {
        return 0.5
    }
}
