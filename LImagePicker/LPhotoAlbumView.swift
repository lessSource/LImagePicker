//
//  LPhotoAlbumView.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LPhotoAlbumView: UIView {

    // 动画时间
    fileprivate let animationTimeInterval: TimeInterval = 0.3
    
    fileprivate lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.screenHeight * 0.7))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    fileprivate lazy var dataArray: Array = [LPhotoAlbumModel]()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.backView.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        initView()
        initData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    fileprivate func initView() {
        addSubview(backView)
        tableView.register(LPhotoAlbumTableViewCell.self, forCellReuseIdentifier: LPhotoAlbumTableViewCell.l_identifire)
        backView.addSubview(tableView)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTapClick))
        backTap.delegate = self
        addGestureRecognizer(backTap)
        
    }

    // MARK: - initData
    fileprivate func initData() {
        LImagePickerManager.shared.getAlbumResources(.image) { (dataArray) in
            self.dataArray = dataArray
            self.tableView.reloadData()
        }
    }
    
    public func showView() {
        isHidden = false
        backView.transform = CGAffineTransform(translationX: 0, y: -backView.l_height)
        UIView.animate(withDuration: animationTimeInterval) {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            self.backView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    public func hideView() {
        UIView.animate(withDuration: animationTimeInterval) {
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            self.backView.transform = CGAffineTransform(translationX: 0, y: -self.backView.l_height)
        } completion: { (finish) in
            self.isHidden = true
            self.backView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    @objc fileprivate func backTapClick() {
        hideView()
    }
    
}

extension LPhotoAlbumView: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LPhotoAlbumTableViewCell = tableView.dequeueReusableCell(withIdentifier: LPhotoAlbumTableViewCell.l_identifire) as! LPhotoAlbumTableViewCell
        cell.photoAsset(albumModel: dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        didSelectClosure?(dataArray[indexPath.row])
        hideView()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let touchClass = touch.view?.classForCoder, NSStringFromClass(touchClass) == "UITableViewCellContentView"  {
            return false
        }
        return true
    }
    
    
}
