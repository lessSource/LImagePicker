//
//  LAlbumPickerController.swift
//  LImagePicker
//
//  Created by Lj on 2020/5/5.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit
import Photos

class LAlbumPickerController: UIViewController {

    fileprivate lazy var dataArray: Array = [LAlbumPickerModel]()
    
    fileprivate lazy var navView: LImageNavView = {
        let navView = LImageNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.backButton.isHidden = true
        navView.titleLabel.text = "全部图片"
        navView.backgroundColor = UIColor.white
        return navView
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 80
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navVC = navigationController as? LImagePickerController else { return }
        LImagePickerManager.shared.getAlbumResources(navVC.allowPickingVideo ? .unknown : .image) { array in
            self.dataArray = array
            self.initData()
        }
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(navView)
        view.addSubview(tableView)
        tableView.register(LAlbumPickerTableViewCell.self, forCellReuseIdentifier: LAlbumPickerTableViewCell.l_identifire)
    }
    

    // MARK:- initData
    fileprivate func initData() {
        guard let navVC = navigationController as? LImagePickerController else {
            tableView.reloadData()
            return
        }
        for i in 0..<dataArray.count {
            var selectCount: Int = 0
            for mediaModel in navVC.selectArray {
                if dataArray[i].fetchResult?.contains(mediaModel.dataProtocol as? PHAsset ?? PHAsset()) == true {
                    selectCount += 1
                }
            }
            dataArray[i].selectCount = selectCount
        }
        tableView.reloadData()
    }
    
}

extension LAlbumPickerController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LAlbumPickerTableViewCell = tableView.dequeueReusableCell(withIdentifier: LAlbumPickerTableViewCell.l_identifire) as! LAlbumPickerTableViewCell
        cell.albumModel = dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoPickerVC = LPhotoPickerController()
        photoPickerVC.pickerModel = dataArray[indexPath.row]
        pushAndHideTabbar(photoPickerVC)
    }
    
}
