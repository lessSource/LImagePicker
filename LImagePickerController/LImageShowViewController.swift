//
//  LShowImageViewController.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

private let cellMargin: CGFloat = 20

class LImageShowViewController: UICollectionViewController {

    /** 数据模型 */
    fileprivate lazy var configuration = LImagePickerConfiguration()
    
    /** 当前序号 */
    fileprivate(set) var currentIndex: Int = 0
    
    
    fileprivate override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init(configuration: LImagePickerConfiguration) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: LConstant.screenWidth + cellMargin, height: LConstant.screenHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        self.init(collectionViewLayout: layout)
        self.configuration = configuration
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.lBackGround
        title = "查看大图"
        
        initView()
    }
    
    deinit {
        print(self, "++++++释放")
    }

}


extension LImageShowViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func initView() {
        collectionView.frame = UIScreen.main.bounds
        collectionView.l_width = LConstant.screenWidth + cellMargin
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(LImageShowCollectionViewCell.self, forCellWithReuseIdentifier: LImageShowCollectionViewCell.l_identifire)
        collectionView.scrollToItem(at: IndexPath(row: 0, section: configuration.currentIndex), at: .left, animated: false)
    }
    
}

extension LImageShowViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LImageShowCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: LImageShowCollectionViewCell.l_identifire, for: indexPath) as! LImageShowCollectionViewCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let imageShowCell = cell as? LImageShowCollectionViewCell {
            imageShowCell.scrollView.zoomScale = 1.0
//            imageShowCell.li
        }
    }
    
    
    
}
