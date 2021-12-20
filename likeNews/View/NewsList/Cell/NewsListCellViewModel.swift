//
//  NewsListCellViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/04/14.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit
import Realm
import GoogleMobileAds

class NewsListCellViewModel: NewsListModel {
    
    /// 表示種別
    enum DispType: Int {
        /// 先頭記事
        case top = 0
        /// 通常
        case normal
        /// 広告
        case ad
    }
    
    /// 表示種別
    var dispType: DispType = .normal
    /// 広告表示BlockView表示有無
    var isAdBlockViewHideen = true
    /// タイトル
    var titleText = ""
    /// タイトル色
    var titleTextColor = UIColor.darkGray
    /// 情報元
    var sourceNameText = ""
    /// 備考
    var noteText = ""
    /// 記事URL
    var articleUrl = ""
    /// 記事画像URL
    var imageUrl = ""
    /// 記事画像（AdMob用）
    var imageAd = UIImage()
    /// 記事画像表示有無
    var articleImageHidden = true
    /// 記事画像表示有無（一覧先頭用）
    var topArticleImageHidden = true
    /// 記事情報
    var sourceArticle: Article? {
        didSet {
            guard let sourceArticle = sourceArticle else { return }
            titleText = sourceArticle.title
            titleTextColor = sourceArticle.isRead ? .lightGray : .darkGray
            sourceNameText = sourceArticle.sourceName
            if let date = sourceArticle.date.toString(dateFormat: "MM/dd HH:mm") {
                noteText = date
            }
            articleUrl = sourceArticle.url
            imageUrl = sourceArticle.imageUrl
        }
    }
    /// ロード状態
    var isLoad = false
    /// 既読状態
    var isRead: Bool {
        guard let sourceArticle = sourceArticle, let article = NewsListModel.shared.articles(title: sourceArticle.title).first else { return false }
        return article.isRead
    }
    /// 広告ロード状態（true:ロード済み）
    var isAdLoad = false
    /// 読み上げ状態
    var isSpeechNow = false
    /// indexPath
    var indexPath = IndexPath()
    
    /// init
    ///
    /// - Parameters:
    ///   - article: 記事情報
    ///   - index: indexPath
    ///   - type: 表示種別
    init(article: Article = Article(), index: IndexPath, type: DispType) {
        super.init()
        
        initSetting(article: article, index: index, type: type)
    }
    
    /// 初期設定
    ///
    /// - Parameters:
    ///   - article: 記事情報
    ///   - index: indexPath
    ///   - type: 表示種別
    func initSetting(article: Article, index: IndexPath, type: DispType) {
        if type == .normal || type == .top {
            // すでに記事が保存してある場合は読み込んだ記事を使用する
            if let savedArticle = NewsListModel.shared.articles(title: article.title).first {
                sourceArticle = savedArticle
            } else {
                sourceArticle = article
            }
        }
        indexPath = index
        dispType = type
        
        isAdBlockViewHideen = dispType == .ad
        topArticleImageHidden = !(dispType == .top) || !UserDefaults.standard.isDispThumbnail
        articleImageHidden = !(dispType == .normal || dispType == .ad) || !UserDefaults.standard.isDispThumbnail
    }

    /// 文字色更新
    func updateTextColor() {
        sourceArticle?.isRead = isRead
    }
    
    /// スピーチ状態をセットする
    ///
    /// - Parameter isSpeech: スピーチ状態（true:読み上げ中、false:読んでいない）
    func setSpeechState(isSpeech: Bool) {
        isSpeechNow = isSpeech
    }
    
    /// 広告情報を反映する
    /// - Parameter nativeAd: 広告情報
    func setAdData(nativeAd: GADNativeAd) {
        guard let title = nativeAd.body,
            let source = nativeAd.advertiser,
            let image = nativeAd.icon?.image else { return }
        titleText = title
        imageAd = image
        sourceNameText = source
        noteText = "PR"
        isAdLoad = true
    }
}
