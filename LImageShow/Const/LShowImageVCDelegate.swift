//
//  LShowImageVCDelegate.swift
//  LImageShow
//
//  Created by L j on 2020/6/19.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import LPublicImageParameter

enum ShowImageButtonType {
    /** 原图 */
    case original
    /** 完成 */
    case complete
    /** 选择 */
    case select
    /** 删除 */
    case delete
}


protocol LShowImageVCDelegate: NSObjectProtocol {
    
    /** 删除 */
    func showImageDidDelete(_ viewController: LShowImageViewController, index: Int, imageData: LMediaResourcesModel)
    /** 选择 */
    func showImageDidSelect(_ viewController: LShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool
    /** 完成 */
    func showImageDidComplete(_ viewController: LShowImageViewController)
    /** 页面已经消失 */
    func showImageDidDisappear(_ viewController: LShowImageViewController)
    /** 是否获取原图 */
    func showImageGetOriginalImage(_ viewController: LShowImageViewController, isOriginal: Bool)
}

extension LShowImageVCDelegate {
    
    public func showImageDidDelete(_ viewController: LShowImageViewController, index: Int, imageData: LMediaResourcesModel) { }
    
    public func showImageDidSelect(_ viewController: LShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool {
        return false
    }
    
    func showImageDidComplete(_ viewController: LShowImageViewController) { }
    
    public func showImageDidDisappear(_ viewController: LShowImageViewController) { }
    
    func showImageGetOriginalImage(_ viewController: LShowImageViewController, isOriginal: Bool) { }
    
}

protocol LShowImageNavTabDelegate: class {
    
    // 导航栏操作
    func showImageNavDidSelect(_ view: LShowImageNavView, buttonType: ShowImageButtonType)
    // 操作
    func showImageBarDidSelect(_ view: LShowImageTabBarView, buttonType: ShowImageButtonType)
}

extension LShowImageNavTabDelegate {
    
    func showImageNavDidSelect(_ view: LShowImageNavView, buttonType: ShowImageButtonType) { }
    
    func showImageBarDidSelect(_ view: LShowImageTabBarView, buttonType: ShowImageButtonType) { }
}


