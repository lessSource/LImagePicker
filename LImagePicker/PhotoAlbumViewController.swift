//
//  PhotoAlbumViewController.swift
//  LImagePicker
//
//  Created by L on 2021/6/30.
//  Copyright © 2021 L. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UIViewController {

    public weak var imagePickerDelegate: ImagePhotographProtocol?
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y:  LConstant.navbarAndStatusBar, width: LConstant.screenWidth, height: LConstant.screenHeight - LConstant.navbarAndStatusBar), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 84
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        return tableView
    }()
    
    fileprivate lazy var navView: PhotoAlbumNavView = {
        let navView = PhotoAlbumNavView(frame: CGRect(x: 0, y: 0, width: LConstant.screenWidth, height: LConstant.navbarAndStatusBar))
        navView.backgroundColor = UIColor.white
        navView.titleLabel.text = "相册"
        return navView
    }()
    
    fileprivate var dataArray: Array = [PhotoAlbumModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
        initData()
    }
    
    
    //MARK:- initView
    fileprivate func initView() {
        view.addSubview(navView)
        view.addSubview(tableView)
        tableView.register(PhotoAlbumTableViewCell.self, forCellReuseIdentifier: PhotoAlbumTableViewCell.l_identifire)
        imagePickerDelegate?.imagePickerCustomPhotoAlbum(navView: navView)
    }
    
    // MARK:- initData
    fileprivate func initData() {
        ImagePickerManager.shared.getAlbumResources(.image, duration: 100) { array in
            self.dataArray = array
            self.tableView.reloadData()
        }
        
    }
    
}

extension PhotoAlbumViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoAlbumTableViewCell.l_identifire) as! PhotoAlbumTableViewCell
        cell.photoAsset(albumModel: dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photographVC = PhotographViewController()
        photographVC.albumModel = dataArray[indexPath.row]
        photographVC.imagePickerDelegate = imagePickerDelegate
        navigationController?.pushViewController(photographVC, animated: true)
    }
    
    
    
}



