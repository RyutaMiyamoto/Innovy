//
//  Collection+.swift
//  likeNews
//
//  Created by R.miyamoto on 2018/05/22.
//  Copyright © 2018年 R.Miyamoto. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
