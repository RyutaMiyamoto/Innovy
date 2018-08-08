//
//  NewsListType.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/04/14.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import Alamofire
import Unbox

/// 記事情報
struct Article {
    /// ジャンル名
    var genreName = ""
    /// 情報元名
    var sourceName = ""
    /// タイトル
    var title = ""
    /// 記事URL
    var url = ""
    /// 更新日付
    var date = Date(timeIntervalSince1970: 0)
    /// 画像リンク(ニュース一覧取得時は空状態)
    var imageUrl = ""
    /// スコア
    var score = 0
    /// クリップ日付
    var clipDate = Date(timeIntervalSince1970: 0)
    /// 既読有無
    var isRead = false
}

extension Article: Unboxable {
    init(unboxer: Unboxer) throws {
        self.genreName = try unboxer.unbox(key: "genreName")
        self.sourceName = try unboxer.unbox(key: "sourceName")
        self.title = try unboxer.unbox(key: "title")
        self.url = try unboxer.unbox(key: "url")
        self.date = try String.init(stringLiteral: unboxer.unbox(key: "date")).toDate(dateFormat: "yyyy-MM-dd HH:mm:ss")!
        self.score = try unboxer.unbox(key: "score")
        self.imageUrl = try unboxer.unbox(key: "imageUrl")
    }
}

/// ニュース概要
struct NewsOverview {
    /// タイトル
    var title: String = ""
    /// タブの色
    var tabColor: UIColor
}

class NewsListType {
    
    /// ジャンル一覧
    let genreList =  ["新着", "人気", "スタートアップ", "サービス", "デザイン", "仮想通貨", "仕事術",
                      "お役立ち", "考察", "ライフ", "プロダクト"]
    
    /// ニュースJSONをパースする
    ///
    /// - Parameter json: JSON
    /// - Returns: パースしたJSON
    func parseJsonNews(at json: Data) -> [Article] {
        var articles: [Article] = []
        do {
            articles = try unbox(data: json)
            return articles
        } catch {
        }
        return articles
    }
}
