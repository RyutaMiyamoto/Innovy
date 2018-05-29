//
//  Date+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/04.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

let yyyyMMFormat = "yyyyMM"

extension Date {
    
    /// 指定された書式の日付文字列に変換する
    ///
    /// - Parameter dateFormat: 書式（yyyy-MM-dd HH:mm:ss等）
    /// - Returns: 変換後の日付文字列。変換できない場合はnilを返す
    func toString(dateFormat: String, timezone: TimeZone? = nil) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if let timezone = timezone {
            formatter.timeZone = timezone
        } else {
            formatter.timeZone = TimeZone(abbreviation: "JST")
        }
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: self)
    }
    
    /// ○日前の日付を返す
    ///
    /// - Parameter day: ◯日前
    /// - Returns: ○日前の日付
    func dayBefore(day: Int) -> Date {
        let daySecond = Int(60 * 60 * 24)
        return self.addingTimeInterval(TimeInterval(-(daySecond * day)))
    }
    
    /// 指定された日付の曜日を1文字で返す
    ///
    /// - Returns: 曜日（月曜日の場合：月）
    func dayOfTheWeek() -> String {
        var calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        calendar.locale = Locale(identifier: "ja")
        let shortWeekdaySymbols = calendar.shortWeekdaySymbols
        if weekday <= shortWeekdaySymbols.count {
            return shortWeekdaySymbols[weekday - 1]
        }
        return ""
    }
    
    /// mm月dd日形式の日付を返す
    ///
    /// - Returns: mm月dd日形式の日付
    func monthAndDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        return formatter.string(from: self)
    }
}
