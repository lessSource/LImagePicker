//
//  LPhotographCollectionViewCell.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LPhotographCollectionViewCell: UICollectionViewCell {
    
    public var mediaAsset: PHAsset?
    
    public var representedAssetIdentifier: String = ""
    
    public var imageRequestID: PHImageRequestID = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
