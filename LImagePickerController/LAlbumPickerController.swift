//
//  LAlbumPickerController.swift
//  LImagePickerController
//
//  Created by L j on 2020/8/28.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LAlbumPickerController: UIViewController {

    fileprivate lazy var dataArray: Array = [LAlbumPickerModel]()
    
    fileprivate lazy var navView: LImagePickerNavView = {
        let view = LImagePickerNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        view.backgroundColor = UIColor.lBackGround
        return view
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y:  LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar), style: .plain)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.lBackGround
        tableView.register(LAlbumPickerCell.self, forCellReuseIdentifier: LAlbumPickerCell.l_identifire)
        view.addSubview(tableView)
        view.addSubview(navView)
        
        LImagePickerManager.shared.getAlbumResources(.image, duration: 100) { (dataArray) in
            self.dataArray = dataArray
            self.tableView.reloadData()
        }
        
    }
    
    deinit {
        print(self, "++++++释放")
    }
    
}


extension LAlbumPickerController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LAlbumPickerCell = tableView.dequeueReusableCell(withIdentifier: LAlbumPickerCell.l_identifire) as! LAlbumPickerCell
        cell.photoAsset(albumModel: dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photoPickerVC = LPhotoPickerController()
        photoPickerVC.albumModel = dataArray[indexPath.row]
        navigationController?.pushViewController(photoPickerVC, animated: true)
    }
    
}
