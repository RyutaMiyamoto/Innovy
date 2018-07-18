//
//  Array+.swift
//  likeNews
//
//  Created by RyutaMiyamoto on 2018/06/30.
//  Copyright © 2018 R.Miyamoto. All rights reserved.
//

import Foundation

extension Array {
    func findIndex(includeElement: (Element) -> Bool) -> [Int] {
        var indexArray:[Int] = []
        for (index, element) in enumerated() {
            if includeElement(element) {
                indexArray.append(index)
            }
        }
        return indexArray
    }
}
