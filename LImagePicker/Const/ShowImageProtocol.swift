//
//  ShowImageProtocol.swift
//  ImagePicker
//
//  Created by Lj on 2019/10/4.
//  Copyright © 2019 Less. All rights reserved.
//

import UIKit

public protocol ShowImageVCDelegate: NSObjectProtocol {
    /** 删除 */
    func showImageDidDelete(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel)
    /** 选择 */
    func showImageDidSelect(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool
    /** 页面已经消失 */
    func showImageDidDisappear(_ viewController: ShowImageViewController)
}

extension ShowImageVCDelegate {
    
    public func showImageDidDelete(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) { }
    
    public func showImageDidSelect(_ viewController: ShowImageViewController, index: Int, imageData: LMediaResourcesModel) -> Bool {
        return false
    }
    
    public func showImageDidDisappear(_ viewController: ShowImageViewController) { }

}

protocol ShowImageNavTabDelegate: NSObjectProtocol {
    /** 删除 */
    func showImageNavDidDelete(_ view: ShowImageNavView)
    /** 选择 */
    func showImageNavDidSelect(_ view: ShowImageNavView)
}

extension ShowImageNavTabDelegate {
    func showImageNavDidDelete(_ view: ShowImageNavView) { }

    func showImageNavDidSelect(_ view: ShowImageNavView) { }
}

