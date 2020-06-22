//
//  AboutApp.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import AVFoundation


extension UIView {
    
    func showOscillatoryAnimation() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.layer.setValue(0.92, forKeyPath: "transform.scale")
        }) { (finished) in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.layer.setValue(0.92, forKeyPath: "transform.scale")
            }) { (finished) in
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            }
        }
    }
    
    func getControllerFromView() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next, responder is UIViewController {
                return responder as? UIViewController
            }
        }
        return nil
    }
    
    func viewController() -> UIViewController? {
        var next = self.next
        while next != nil {
            if next is UIViewController {
                return next as? UIViewController
            }
            next = next?.next
        }
        return  nil
    }
}

extension Bundle {
    static func imagePickerBundle() -> Bundle? {
        let path = Bundle(for: LImagePickerController.self).path(forResource: "LImagePicker", ofType: "bundle")
        let bundle = Bundle(path: path ?? "")
        return bundle
    }
}

extension UIImage {
    static func imageNameFromBundle(_ name: String) -> UIImage? {
        let imageName = name + "@2x"
        let imageBundle  = Bundle.imagePickerBundle()
        let imagePath = imageBundle?.path(forResource: imageName, ofType: "png")
        let image = UIImage(contentsOfFile: imagePath ?? "")
        return image
    }
}

extension UIImageView {
    // 获取视频截图
    func l_getNetWorkVidoeImage(urlStr: String, placeholder: String) {
        guard let url = URL(string: urlStr)  else {
            image = UIImage(named: placeholder)
            return
        }
        DispatchQueue.global().async {
            var resultImage: UIImage?
            let asset = AVURLAsset(url: url)
            let gen = AVAssetImageGenerator(asset: asset)
            gen.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 1)
            var actualTime: CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
            do {
                let thumbImage = try gen.copyCGImage(at: time, actualTime: &actualTime)
                resultImage = UIImage(cgImage: thumbImage)
            } catch  {
                self.image = UIImage(named: placeholder)
            }
            DispatchQueue.main.async {
                self.image = resultImage
            }
        }
    }
}


extension UIViewController {
    public func showAlertWithTitle(_ title: String) {
        let alertVC = UIAlertController(title: "提示", message: title, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    
}

