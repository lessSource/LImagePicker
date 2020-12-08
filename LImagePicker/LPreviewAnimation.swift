//
//  LPreviewAnimation.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

public class LPreviewAnimationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    fileprivate var isPresentAnimatotion: Bool = true
    // 动画时间
    fileprivate let animatTime: TimeInterval = 0.3
    // 父视图
    fileprivate var superView: UIView?
    // 点击Image
    fileprivate var contentImage: UIImageView?
    
    public init(contentImage: UIImageView? = nil,superView: UIView? = nil) {
        self.superView = superView
        self.contentImage = contentImage
        super.init()
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
}

extension LPreviewAnimationDelegate: UIViewControllerAnimatedTransitioning {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresentAnimatotion = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresentAnimatotion = false
        return self
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animatTime
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresentAnimatotion ? presentViewAnimation(transitionContext: transitionContext) : dismissViewAnimation(transitionContext: transitionContext)
    }
}

extension LPreviewAnimationDelegate {
    // 显示动画
    fileprivate func presentViewAnimation(transitionContext: UIViewControllerContextTransitioning) {
        // 获取view
        guard let `contentImage` = contentImage, let image = contentImage.image,let toView = transitionContext.view(forKey: .to),let window = UIApplication.shared.delegate?.window else {
            presentViewDefaultAnimation(transitionContext: transitionContext)
            return
        }
        
        let toBackView = UIView(frame: toView.bounds)
        toBackView.backgroundColor = UIColor.black
        toView.addSubview(toBackView)
        // 容器View
        let containerView = transitionContext.containerView
        // 过渡view添加到容器上
        toView.alpha = 0
        containerView.addSubview(toView)
        // 新建一个imageView添加到目标view之上，做为动画view
        let animateView = UIImageView()
        animateView.image = contentImage.image
        animateView.contentMode = .scaleAspectFill
        animateView.clipsToBounds = true
        // 被选中的imageView到目标view上的坐标转换
        
        let originalFrame = contentImage.convert(contentImage.bounds, to: window)
        animateView.frame = originalFrame
        containerView.addSubview(animateView)
        
        // endFrame
        var endFrame: CGRect = .zero
        endFrame.size.width = LConstant.screenWidth
        if image.size.height / image.size.width > LConstant.screenHeight / LConstant.screenWidth {
            endFrame.size.height = floor(image.size.height / (image.size.width / LConstant.screenWidth))
        }else {
            var height = image.size.height / image.size.width * LConstant.screenWidth
            if height < 1 || height.isNaN {
                height = LConstant.screenHeight
            }
            height = floor(height)
            endFrame.size.height = height
            endFrame.origin.y = LConstant.screenHeight/2 - height/2
            
        }
        if endFrame.height > LConstant.screenHeight && endFrame.height - LConstant.screenHeight <= 1 {
            endFrame.size.height = LConstant.screenHeight
        }
        
        // 过渡动画
        UIView.animate(withDuration: animatTime, animations: {
            animateView.frame = endFrame
            toView.alpha = 1
        }) { _ in
            transitionContext.completeTransition(true)
            animateView.removeFromSuperview()
            toBackView.removeFromSuperview()
        }
    }
    
    // 默认显示动画
    fileprivate func presentViewDefaultAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.transform = CGAffineTransform(translationX: toView.l_width, y: 0)
        UIView.animate(withDuration: animatTime, animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
    
    // 消失动画
    fileprivate func dismissViewAnimation(transitionContext: UIViewControllerContextTransitioning) {
        // 获取一系列view
        var viewController: UIViewController?
        
        if let navVC = transitionContext.viewController(forKey: .from) as? LImagePickerController, navVC.viewControllers.count > 0 {
            viewController = navVC.viewControllers[0]
        }else {
            viewController = transitionContext.viewController(forKey: .from)
        }
        
        guard let formVC = viewController as? LPreviewImageController, let cell = formVC.collectionView?.visibleCells.first as? LPreviewCollectionViewCell,let image = cell.currentImage.image ,let toView = transitionContext.viewController(forKey: .to)?.view, let _ = contentImage else {
            dismissViewDefaultAnimation(transitionContext: transitionContext)
            return
        }
        var endView: UIView?
        if let collectionView = superView as? UICollectionView {
            let indexPath = IndexPath(item: formVC.currentIndex + formVC.correctionNumber, section: 0)
            endView = collectionView.cellForItem(at: indexPath)
        }else {
            endView = contentImage
        }

        if endView == nil {
            dismissViewDefaultAnimation(transitionContext: transitionContext)
            return
        }

        // 过渡view
        guard let fromeView = transitionContext.view(forKey: .from) else { return }
        let formeBackView = UIView(frame: fromeView.bounds)
        formeBackView.backgroundColor = UIColor.black
        fromeView.addSubview(formeBackView)
        // 容器view
        let containerView = transitionContext.containerView

        // 新建过渡动画imageView
        let animateImageView = UIImageView()
        animateImageView.frame = cell.imageContainerView.frame
        animateImageView.image = image
        animateImageView.contentMode = .scaleAspectFill
        animateImageView.clipsToBounds = true
        containerView.addSubview(animateImageView)
        let endFrame: CGRect = endView!.convert(endView!.bounds, to: toView)

        UIView.animate(withDuration: animatTime, animations: {
            animateImageView.frame = endFrame
            fromeView.alpha = 0
        }) { _ in
            transitionContext.completeTransition(true)
            animateImageView.removeFromSuperview()
            formeBackView.removeFromSuperview()
        }
    }
    
    fileprivate func dismissViewDefaultAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromeView = transitionContext.view(forKey: .from) else {
            return
        }
        fromeView.transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: animatTime, animations: {
            fromeView.transform = CGAffineTransform(translationX: fromeView.l_width, y: 0)
        }) { _ in
            fromeView.transform = CGAffineTransform(translationX: 0, y: 0)
            transitionContext.completeTransition(true)
        }
    }
}








