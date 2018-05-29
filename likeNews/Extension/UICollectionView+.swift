//
//  UICollectionView+.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/11/18.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

extension UICollectionView {
    func reloadDataAfter(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            
            self.reloadData()
        }) { _ in
            
            completion()
        }
    }
}
