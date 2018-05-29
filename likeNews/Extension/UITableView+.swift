//
//  UITableView+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/09/04.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadDataAfter(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            
            self.reloadData()
        }) { _ in
            
            completion()
        }
    }
}
