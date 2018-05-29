//
//  UIView+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/10/31.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

/// フェード速度
enum FadeSpeed: TimeInterval {
    /// 速い
    case fast = 0.1
    /// 普通
    case normal = 0.2
    /// 遅い
    case slow = 1.0
}

extension UIView {
    
    /// フェードインさせる
    ///
    /// - Parameters:
    ///   - speed: 速度
    ///   - completed: completed
    func fadeIn(speed: FadeSpeed = .slow, completed: @escaping (() -> ())) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: speed.rawValue, animations: {
            self.alpha = 1
        }) { finished in
            completed()
        }
    }
    
    /// フェードアウトさせる
    ///
    /// - Parameters:
    ///   - speed: 速度
    ///   - completed: completed
    func fadeOut(speed: FadeSpeed = .slow, completed: @escaping (() -> ())) {
        UIView.animate(withDuration: speed.rawValue, animations: {
            self.alpha = 0
        }) { [weak self] finished in
            guard let `self` = self else { return }
            self.isHidden = true
            self.alpha = 1
            completed()
        }
    }
}
