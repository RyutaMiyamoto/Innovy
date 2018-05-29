//
//  CGRect+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/07/28.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    
    /// 画面の横幅を取得する
    ///
    /// - Returns: 横幅
    func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    /// 画面の縦幅を取得する
    ///
    /// - Returns: 縦幅
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }

    /// ステータスバーの縦幅を取得する
    ///
    /// - Returns: 縦幅
    func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
}
