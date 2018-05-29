//
//  MainCollectionViewCell.swift
//  UpTabViewController
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    /// 背景
    @IBOutlet weak var backView: UIView!
    /// ニュースリストViewController
    var newsListViewController: NewsListViewController?
    
    /// ViewControllerをセット
    ///
    /// - Parameter viewController: ニュースリストViewController
    func setView(viewController: NewsListViewController) {
        // iPhoneXの場合、テーブルの先頭と終端が（何故か）ずれるので高さ調整（仮）
        let adjustHeight: CGFloat = CGRect().screenHeight() == 812 ? 20 : 0
        
        newsListViewController = viewController
        viewController.view.frame = CGRect(x: 0, y: adjustHeight, width: backView.frame.size.width, height: backView.frame.size.height - adjustHeight * 2)
        backView.addSubview(viewController.view)
    }
}
