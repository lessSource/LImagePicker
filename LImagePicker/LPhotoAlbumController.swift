//
//  LPhotoAlbumController.swift
//  LImagePicker
//
//  Created by L. on 2020/11/30.
//  Copyright © 2020 L. All rights reserved.
//

import UIKit

class LPhotoAlbumController: UIViewController {

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
    
    fileprivate lazy var dataArray: Array = [LPhotoAlbumModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        initData()
    }
    
    // MARK: - initView
    fileprivate func initView() {
        tableView.register(LPhotoAlbumTableViewCell.self, forCellReuseIdentifier: LPhotoAlbumTableViewCell.l_identifire)
        view.addSubview(tableView)
    }
    
    // MARK: - initData()
    fileprivate func initData() {
        LImagePickerManager.shared.getAlbumResources(.image, duration: 100) { (dataArray) in
            self.dataArray = dataArray
            self.tableView.reloadData()
        }
    }
}

extension LPhotoAlbumController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LPhotoAlbumTableViewCell = tableView.dequeueReusableCell(withIdentifier: LPhotoAlbumTableViewCell.l_identifire) as! LPhotoAlbumTableViewCell
        cell.photoAsset(albumModel: dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photographVC = LPhotographController()
        photographVC.albumModel = dataArray[indexPath.row]
        navigationController?.pushViewController(photographVC, animated: true)
    }
    
}
