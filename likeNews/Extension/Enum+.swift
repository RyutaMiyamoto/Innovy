//
//  Enum+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/07/22.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

public protocol EnumEnumerable {
    associatedtype Case = Self
}

/**
 enumを配列で便利に扱うためのextension
 */
public extension EnumEnumerable where Case: Hashable {
    private static var iterator: AnyIterator<Case> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            
            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Case.self).pointee
            }
            return next.hashValue == n ? next : nil
        }
    }
    
    public static func enumerate() -> EnumeratedSequence<AnySequence<Case>> {
        return AnySequence(self.iterator).enumerated()
    }
    
    /// enumのcaseを配列で返す
    public static var cases: [Case] {
        return Array(self.iterator)
    }
    
    /// enumのcase数を返す
    public static var count: Int {
        return self.cases.count
    }
}
