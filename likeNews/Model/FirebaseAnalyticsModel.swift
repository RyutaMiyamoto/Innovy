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
    
    /// イベント名
    enum EventName: String {
        /// ニューススクロール
        case newsScroll = "ニュース一覧スクロール"
        /// ジャンル選択
        case selectedGenre = "ジャンル選択"
        /// ワード検索
        case searchWord = "ワード検索"
        /// ニュースクリップON
        case clipOn = "ニュースクリップON"
        /// ニュースクリップOFF
        case clipOff = "ニュースクリップOFF"
        /// リモートPUSHタップ
        case remotePushTap = "PUSH通知(リモート)タップ"
        /// ローカルPUSHタップ
        case localPushTap = "PUSH通知(ローカル)タップ"
    }
    
    /// スクリーントラッキング送信
    /// - Parameters:
    ///   - screenName: スクリーン名
    ///   - screenClass: クラス
    func sendScreen(screenName: ScreenName, screenClass: String?) {
        Analytics.setScreenName(screenName.rawValue, screenClass: screenClass)
    }
    
    /// イベントトラッキング送信
    /// - Parameters:
    ///   - eventName: イベント名
    ///   - params: パラメータ
    func sendEvent(eventName: EventName, params: [String: String]) {
        Analytics.logEvent(eventName.rawValue, parameters: params)
    }
}
