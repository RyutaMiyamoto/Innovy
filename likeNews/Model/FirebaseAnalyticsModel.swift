//
//  FirebaseAnalyticsModel.swift
//  likeNews
//
//  Created by RyutaMiyamoto on 2019/12/30.
//  Copyright © 2019 R.Miyamoto. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class FirebaseAnalyticsModel {

    static let shared = FirebaseAnalyticsModel()

    /// 画面名
    enum ScreenName: String {
        /// ニュース一覧
        case newsList = "ニュース一覧"
        /// ニュース検索
        case newsSearch = "ニュース検索"
        ///クリップ済ニュース一覧
        case newsClip = "クリップ済ニュース一覧"
        /// その他
        case etc = "その他"
        /// 記事詳細
        case articleDetail = "記事詳細"
        /// 音声アシスト
        case speechSetting = "音声アシスト"
    }
    
    /// スクリーントラッキング送信
    /// - Parameters:
    ///   - screenName: スクリーン名
    ///   - screenClass: クラス
    func sendScreen(screenName: ScreenName, screenClass: String?) {
        Analytics.setScreenName(screenName.rawValue, screenClass: screenClass)
    }
}
