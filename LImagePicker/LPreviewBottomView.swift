//
//  LPreviewBottomView.swift
//  LImagePicker
//
//  Created by HY.Ltd on 2020/12/3.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LPreviewBottomView: UIView {

    public weak var delegate: LPreviewBottomProtocol?
    
    /** 数据源 */
    public var dataArray: [LPhotographModel] = []
    
    public var selectIndex: Int = 0 {
        didSet {
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: selectIndex, section: 0), at: .left, animated: true)
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 52, height: 52)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: l_width, height: l_height), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        addSubview(collectionView)
        collectionView.register(LPhotographImageCell.self, forCellWithReuseIdentifier: LPhotographImageCell.l_identifire)
    }
    
}

extension LPreviewBottomView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LPhotographImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: LPhotographImageCell.l_identifire, for: indexPath) as! LPhotographImageCell
        cell.loadingResourcesModel(dataArray[indexPath.item])
        cell.previewSelect(isCurrent: indexPath.item == selectIndex, isSelect: dataArray[indexPath.item].isSelect)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.item
        collectionView.reloadData()
        delegate?.previewBottomView(view: self, didSelect: indexPath.item)
    }
    
}
