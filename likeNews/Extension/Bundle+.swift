//
//  Bundle+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/10/21.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

extension Bundle {
    
    /// 広告（AdMob）
    enum AdMobKey: String {
        /// 広告ユニット ID
        case adUnitID = "AdUnitId"
    }
    
    /// HockeyApp
    enum HockeyAppKey: String {
        /// ID
        case Id = "Id"
    }
    /// メール
    enum MailKey: String {
        /// お問い合わせ
        case inquiry = "Inquiry"
    }

    /// API
    enum ApiKey: String {
        /// ホスト
        case host = "Host"
        /// Pass
        case pass = "Pass"
        /// Twitterホスト
        case twitterHost = "TwitterHost"
        /// Twitterホストバージョン
        case twitterHostVersion = "TwitterHostVersion"
        /// Twitterコンシューマーキー
        case twitterConsumerKey = "TwitterConsumerKey"
        /// Twitterコンシューマーキー（シークレット）
        case twitterConsumerSecret = "TwitterConsumerSecret"
        /// Twitterトークン
        case twitterToken = "TwitterToken"
        /// Twitterトークン（シークレット）
        case twitterTokenSecret = "TwitterTokenSecret"
        /// OpenWeatherMapホスト
        case weatherHost = "WeatherHost"
        /// OpenWeatherMap API Key
        case weatherApiKey = "WeatherApiKey"
        /// Geo APIホスト
        case locationHost = "LocationHost"
        /// gistホスト
        case gistHost = "GistHost"
        /// gist上のジャンル
        case gistGenre = "GistGenre"
    }

    /// 広告（AdMob）に関連する値を返却する
    ///
    /// - Parameter key: キー名
    /// - Returns: 値
    class func AdMob(key: AdMobKey) -> String {
        guard let dictionary = Bundle.main.infoDictionary?["AdMob"] as? Dictionary<String, String> else {
            return ""
        }
        guard let returnString = dictionary[key.rawValue] as String? else {
            return ""
        }
        
        return  returnString
    }

    /// HockeyAppに関連する値を返却する
    ///
    /// - Parameter key: キー名
    /// - Returns: 値
    class func HockeyApp(key: HockeyAppKey) -> String {
        guard let dictionary = Bundle.main.infoDictionary?["HockeyApp"] as? Dictionary<String, String> else {
            return ""
        }
        guard let returnString = dictionary[key.rawValue] as String? else {
            return ""
        }
        
        return  returnString
    }
    /// メールに関連する値を返却する
    ///
    /// - Parameter key: キー名
    /// - Returns: 値
    class func Mail(key: MailKey) -> String {
        guard let dictionary = Bundle.main.infoDictionary?["Mail"] as? Dictionary<String, String> else {
            return ""
        }
        guard let returnString = dictionary[key.rawValue] as String? else {
            return ""
        }
        
        return  returnString
    }
    
    /// APIに関連する値を返却する
    ///
    /// - Parameter key: キー名
    /// - Returns: 値
    class func Api(key: ApiKey) -> String {
        guard let dictionary = Bundle.main.infoDictionary?["API"] as? Dictionary<String, String> else {
            return ""
        }
        guard let returnString = dictionary[key.rawValue] as String? else {
            return ""
        }
        
        return  returnString
    }

}
