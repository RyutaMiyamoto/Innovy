//
//  UIColor+.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/12/29.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    /// アプリのテーマ
    ///
    /// - Returns: 色
    class func thema() -> UIColor {
        return UIColor.rgbColor(rgbValue: 0xAB89D3)
    }
    
    /// 項目タイトル
    ///
    /// - Returns: 色
    class func titleFont() -> UIColor {
        return UIColor.rgbColor(rgbValue: 0x555555)
    }
    
    /// 読み上げ中のセル
    ///
    /// - Returns: 色
    class func speechCell() -> UIColor {
        return UIColor.rgbColor(rgbValue: 0xD3B1FB)
    }
    
    /// UIntからUIColorを返す
    ///
    /// - Parameter rgbValue: RGB
    /// - Returns: 色
    class func rgbColor(rgbValue: UInt) -> UIColor {
        return UIColor(
            red:   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >>  8) / 255.0,
            blue:  CGFloat( rgbValue & 0x0000FF)        / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

