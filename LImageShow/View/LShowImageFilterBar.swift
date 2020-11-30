////
////  LShowImageFilterBar.swift
////  LImageShow
////
////  Created by L j on 2020/8/9.
////  Copyright © 2020 L. All rights reserved.
////
//
//import UIKit
//import LPublicImageParameter
//
//protocol LShowImageFilterBarDelegate: class {
//    func filterBar(_ filterBar: LShowImageFilterBar, index: Int)
//}
//
//extension LShowImageFilterBarDelegate {
//    func filterBar(_ filterBar: LShowImageFilterBar, index: Int) { }
//}
//
//class LShowImageFilterBar: UIView {
//    
//    
//    public weak var delegate: LShowImageFilterBarDelegate?
//    
//    fileprivate var currentIndex: Int = 0
//    
//    fileprivate lazy var collectionViewLayout: UICollectionViewFlowLayout = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.minimumLineSpacing = 0
//        flowLayout.minimumInteritemSpacing = 0;
//        
//        flowLayout.itemSize = CGSize(width: 100, height: self.l_height)
//        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        flowLayout.scrollDirection = .horizontal
//        return flowLayout
//    }()
//    
//    fileprivate lazy var collectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.collectionViewLayout)
//        
//        collectionView.backgroundColor = UIColor.white
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
//        return collectionView
//    }()
//    
//    public var itemList: Array = [FilterType]() {
//        didSet {
//            collectionView.reloadData()
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    fileprivate func initView() {
//        collectionView.register(LShowImageFilterCell.self, forCellWithReuseIdentifier: LShowImageFilterCell.l_identifire)
//        addSubview(collectionView)
//    }
//
//}
//
//
//extension LShowImageFilterBar: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return itemList.count
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: LShowImageFilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: LShowImageFilterCell.l_identifire, for: indexPath) as! LShowImageFilterCell
//        cell.title = itemList[indexPath.row].filterName
//        cell.isSelect = indexPath.row == currentIndex
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        currentIndex = indexPath.row
//        collectionView.reloadData()
//        
//        collectionView .scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        
//        delegate?.filterBar(self, index: indexPath.row)
//        
//    }
//    
//}
