//
//  Int+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/10/21.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

extension Int {
    
    /// 広告を表示するインデックスを返す
    ///
    /// - Parameter minIndex: 最小表示位置
    /// - Returns: 広告表示インデックスリスト
    func indexOfAd(minIndex: Int = 3) -> [Int] {
        if self < minIndex {
            return [self - 1]
        }
        
        let firstIndex = 2
        let adIndexStep = 7
        var indexNow = minIndex
        var indexList: [Int] = []
        
        // 最初の広告位置は固定
        if minIndex == 0 { indexList.append(firstIndex) }
        
        // ２件目以降の広告は一定数区切りで表示する
        indexNow += adIndexStep
        while indexNow < self {
            indexList.append(indexNow)
            indexNow += adIndexStep
        }
        
        return indexList
    }
}
