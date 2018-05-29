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
        /// ジャンル更新日付
        case genreUpdateDate
        /// ジャンル一覧
        case genreList
        /// サムネイル表示有無（true:表示）
        case isDispThumbnail
        /// 記事を読んだ人数表示有無（true:表示）
        case isDispReadArticleNum
        /// Twitter用OauthToken
        case oauthToken
        /// Twitter用OauthTokenSecret
        case oauthTokenSecret
        /// 読み上げ機能（速度）
        case speechRate
        /// 読み上げ機能（高さ）
        case speechPitch
    }
    
    /// ジャンル更新日付
    var genreUpdateDate: Date {
        get {
            let setKey = UserDefaults.key.genreUpdateDate
            guard let result =  UserDefaults.standard.object(forKey: setKey.rawValue) as? Date else {
                return Date(timeIntervalSince1970: 0)
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.genreUpdateDate.rawValue)
        }
    }
    
    /// ジャンル一覧
    var genreList: [String] {
        get {
            let setKey = UserDefaults.key.genreList
            guard let result =  UserDefaults.standard.object(forKey: setKey.rawValue) as? [String] else {
                return []
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.genreList.rawValue)
        }
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
    
    /// Twitter用OauthToken
    var oauthToken: String? {
        get {
            let setKey = UserDefaults.key.oauthToken
            guard let result = UserDefaults.standard.object(forKey: setKey.rawValue) as? String else {
                return nil
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.oauthToken.rawValue)
        }
    }
    
    /// Twitter用OauthTokenSecret
    var oauthTokenSecret: String? {
        get {
            let setKey = UserDefaults.key.oauthTokenSecret
            guard let result = UserDefaults.standard.object(forKey: setKey.rawValue) as? String else {
                return nil
            }
            return result
        }
        set {
            setValue(newValue, forKeyPath: UserDefaults.key.oauthTokenSecret.rawValue)
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

