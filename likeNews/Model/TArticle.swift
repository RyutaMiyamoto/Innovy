//
//  TArticle.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/04.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import Realm

class TArticle: RLMObject {
    /// ジャンル名
    dynamic var genreName = String()
    /// 情報元名
    dynamic var sourceName = String()
    /// タイトル
    dynamic var title = ""
    /// 記事URL
    dynamic var url = ""
    /// 更新日付
    dynamic var date: Date?
    /// 画像リンク
    dynamic var imageUrl = ""
    /// スコア
    dynamic var score = 0
    /// クリップ日付
    dynamic var clipDate: Date?
    /// 既読有無
    dynamic var isRead = false
    
    override class func primaryKey() -> String? {
        return "title"
    }
    
    override static func indexedProperties() -> [String] {
        return ["title"]
    }    
    
    /// 記事情報を保存、更新する
    ///
    /// - Parameter article: 記事情報
    /// - Returns: 記事情報
    class func createOrUpdate(article: Article) -> TArticle? {
        let tArticle = TArticle()
        
        tArticle.genreName = article.genreName
        tArticle.sourceName = article.sourceName
        tArticle.title = article.title
        tArticle.url = article.url
        tArticle.date = article.date
        tArticle.imageUrl = article.imageUrl
        tArticle.score = article.score
        tArticle.clipDate = article.clipDate
        tArticle.isRead = article.isRead
        
        let realm = RLMRealm.default()
        do {
            realm.beginWriteTransaction()
            TArticle.createOrUpdate(in: realm, withValue: tArticle)
            try realm.commitWriteTransaction()
            return tArticle
        } catch {
            realm.cancelWriteTransaction()
            return nil
        }
    }
    
    /// 記事情報一覧を保存、更新する
    ///
    /// - Parameter articles: 記事情報一覧
    /// - Returns: 記事情報
    class func createOrUpdate(articles: [Article]) {
        if articles.isEmpty { return }
        
        let realm = RLMRealm.default()
        realm.beginWriteTransaction()
        for article in articles {
            let tArticle = TArticle()
            tArticle.genreName = article.genreName
            tArticle.sourceName = article.sourceName
            tArticle.title = article.title
            tArticle.url = article.url
            tArticle.date = article.date
            tArticle.imageUrl = article.imageUrl
            tArticle.score = article.score
            tArticle.clipDate = article.clipDate
            tArticle.isRead = article.isRead
            TArticle.createOrUpdate(in: realm, withValue: tArticle)
        }
        
        do {
            try realm.commitWriteTransaction()
        } catch {
            realm.cancelWriteTransaction()
        }
    }
}
