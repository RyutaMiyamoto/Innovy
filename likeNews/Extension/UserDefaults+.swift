//
//  UserDefaults+.swift
//  likeNews
//
//  Created by System on 2017/11/14.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import AVFoundation

extension UserDefaults {
    enum key: String {
        /// サムネイル表示有無（true:表示）
        case isDispThumbnail
        /// 記事を読んだ人数表示有無（true:表示）
        case isDispReadArticleNum
        /// 読み上げ機能（速度）
        case speechRate
        /// 読み上げ機能（高さ）
        case speechPitch
    }
    
    /// サムネイル表示有無
    var isDispThumbnail: Bool {
        get {
            let setKey = UserDefaults.key.isDispThumbnail
            guard let result =  UserDefaults.standard.object(forKey: setKey.rawValue) as? Bool else {
                return true
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.isDispThumbnail.rawValue)
        }
    }
    
    /// 記事を読んだ人数表示有無
    var isDispReadArticleNum: Bool {
        get {
            let setKey = UserDefaults.key.isDispReadArticleNum
            guard let result =  UserDefaults.standard.object(forKey: setKey.rawValue) as? Bool else {
                return true
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.isDispReadArticleNum.rawValue)
        }
    }
    
    /// 読み上げ機能（速度）
    var speechRate: Float {
        get {
            let setKey = UserDefaults.key.speechRate
            guard let result = UserDefaults.standard.object(forKey: setKey.rawValue) as? Float else {
                return AVSpeechUtteranceDefaultSpeechRate
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.speechRate.rawValue)
        }
    }
    
    /// 読み上げ機能（高さ）
    var speechPitch: Float {
        get {
            let setKey = UserDefaults.key.speechPitch
            guard let result = UserDefaults.standard.object(forKey: setKey.rawValue) as? Float else {
                return 1.0
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.speechPitch.rawValue)
        }
    }
}

