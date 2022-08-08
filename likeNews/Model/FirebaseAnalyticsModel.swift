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
        case scrollNews = "ニュース一覧スクロール"
        /// ニュース一覧手動更新
        case updateNews = "ニュース一覧手動更新"
        /// 検索ニュース一覧手動更新
        case updateSearchNews = "検索ニュース一覧手動更新"
        /// ジャンル選択
        case selectedGenre = "ジャンル選択"
        /// ワード検索
        case searchWord = "ワード検索"
        /// ニュースクリップ
        case clip = "ニュースクリップ"
        /// リモートPUSHタップ
        case tapRemotePush = "PUSH通知(リモート)タップ"
        /// ローカルPUSHタップ
        case tapLocalPush = "PUSH通知(ローカル)タップ"
        /// 天気情報手動更新
        case updateWeather = "天気情報手動更新"
        /// お問い合わせタップ
        case tapInquiry = "お問い合わせタップ"
        /// キャッシュクリア実行
        case clearCache = "キャッシュクリア実行"
        /// サムネイル表示切り替え
        case switchingDispThumbnail = "サムネイル表示切り替え"
        /// 記事を読んだ人数表示切り替え
        case switchingDispReadArticleNum = "記事を読んだ人数表示切り替え"
        /// 音声アシスト設定変更
        case updateSpeechSetting = "音声アシスト設定変更"
    }
    
    /// スクリーントラッキング送信
    /// - Parameters:
    ///   - screenName: スクリーン名
    ///   - screenClass: クラス
    func sendScreen(screenName: ScreenName, screenClass: String?) {
        Analytics.logEvent(screenName.rawValue, parameters: [screenName.rawValue: screenClass as Any])
    }
    
    /// イベントトラッキング送信
    /// - Parameters:
    ///   - eventName: イベント名
    ///   - params: パラメータ
    func sendEvent(eventName: EventName, params: [String: String]?) {
        Analytics.logEvent(eventName.rawValue, parameters: params)
    }
}
