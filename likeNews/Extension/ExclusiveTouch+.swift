//
//  ExclusiveTouch+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/04/12.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    open override func awakeFromNib() {
        self.isExclusiveTouch = true
    }
}

extension UITableViewCell {
    open override func awakeFromNib() {
        self.isExclusiveTouch = true
    }
}

extension UISegmentedControl {
    open override func awakeFromNib() {
        self.isExclusiveTouch = true
    }
}

extension UINavigationController {
    open override func awakeFromNib() {
        self.navigationBar.isExclusiveTouch = true
    }
}
