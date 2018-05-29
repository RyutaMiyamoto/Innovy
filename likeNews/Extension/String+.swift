//
//  String+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/04/13.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    /// 文字列をDate型に変換する
    ///
    /// - Parameter dateFormat: 書式（yyyy-MM-dd HH:mm:ss等）
    /// - Returns: 変換後の日付。変換できない場合はnilを返す
    func toDate(dateFormat: String, timezone: TimeZone? = nil) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let timezone = timezone {
            formatter.timeZone = timezone
        } else {
            formatter.timeZone = TimeZone(abbreviation: "JST")
        }
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.date(from: self)
    }
    
    /// テキストセット後のラベルの高さを取得する
    ///
    /// - Parameters:
    ///   - width: ラベルの横幅
    ///   - font: フォント
    /// - Returns: テキストセット後のラベルの高さ
    func labelHeight(width: CGFloat, font: UIFont, maxLine: Int = 0) -> CGFloat {
        let label = UILabel()
        label.font = font
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = maxLine
        label.text = self
        
        let rect: CGSize = label.sizeThatFits(CGSize(width: width-label.layoutMargins.left-label.layoutMargins.right, height: CGFloat.greatestFiniteMagnitude))
        
        return rect.height
    }
    
    /// テキストセット後のラベルの幅を取得する（ラベルは1行固定）
    ///
    /// - Parameters:
    ///   - height: ラベルの高さ
    ///   - font: フォント
    /// - Returns: テキストセット後のラベルの幅
    func labelWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel()
        label.font = font
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.text = self
        
        let rect: CGSize = label.sizeThatFits(CGSize(width:CGFloat.greatestFiniteMagnitude , height: height-label.layoutMargins.top-label.layoutMargins.bottom))
        
        return rect.width
    }
}
