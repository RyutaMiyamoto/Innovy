//
//  DispatchQueue+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/15.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

extension DispatchQueue {
    class func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
    
    class func mainSyncSafe<T>(execute work: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try work()
        } else {
            return try DispatchQueue.main.sync(execute: work)
        }
    }
}
