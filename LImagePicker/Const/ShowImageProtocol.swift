//
//  ShowImageProtocol.swift
//  ImagePicker
//
//  Created by Lj on 2019/10/4.
//  Copyright © 2019 Less. All rights reserved.
//

import UIKit

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


protocol ShowImageVCDelegate: NSObjectProtocol {
    /** 删除 */
    func showImageDidDelete(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel)
    /** 选择 */
    func showImageDidSelect(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool
    /** 完成 */
    func showImageDidComplete(_ viewController: ShowImageViewController)
    /** 页面已经消失 */
    func showImageDidDisappear(_ viewController: ShowImageViewController)
    /** 是否获取原图 */
    func showImageGetOriginalImage(_ viewController: ShowImageViewController, isOriginal: Bool)
}

extension ShowImageVCDelegate {
    
    public func showImageDidDelete(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) { }
    
    public func showImageDidSelect(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool {
        return false
    }
    
    func showImageDidComplete(_ viewController: ShowImageViewController) { }
    
    public func showImageDidDisappear(_ viewController: ShowImageViewController) { }
    
    func showImageGetOriginalImage(_ viewController: ShowImageViewController, isOriginal: Bool) { }

}

protocol ShowImageNavTabDelegate: class {
    
    // 导航栏操作
    func showImageNavDidSelect(_ view: ShowImageNavView, buttonType: ShowImageButtonType)
    // 操作
    func showImageBarDidSelect(_ view: ShowImageTabBarView, buttonType: ShowImageButtonType)
}

extension ShowImageNavTabDelegate {
    
    func showImageNavDidSelect(_ view: ShowImageNavView, buttonType: ShowImageButtonType) { }
    
    func showImageBarDidSelect(_ view: ShowImageTabBarView, buttonType: ShowImageButtonType) { }
}

