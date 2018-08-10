//
//  NewsListModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/04/12.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import Alamofire
import Realm
import SDWebImage

class NewsListModel: NewsListType {
    
    static let shared = NewsListModel()
    
    /// 並び順
    enum SortKey: String {
        /// 作成日時
        case date = "date"
        /// クリップ日時
        case clipDate = "clipDate"
        /// スコア
        case score = "score"
    }
    
    /// ニュース一覧取得条件
    struct GetNewsCondition {
        /// ジャンル
        var genre: String = ""
        /// ワード
        var word: String = ""
        /// 取得件数
        var num: Int = 500
    }

    /// API種別
    enum ApiType: Int {
        /// ニュース一覧取得
        case getNews = 0
        /// 記事のスコアをインクリメント
        case updateNewsScore
    }
    
    /// ニュース取り出し最大件数
    private let numReadMax = 100
    
    /// 検索条件作成
    ///
    /// - Parameter condition: 検索条件
    /// - Returns: APIに送信する検索条件文字列
    private func createGetNewsCondition(condition: GetNewsCondition) -> String {
        var conditionStr = ""
        
        // ジャンル、またはワード指定がない場合はスコア順に並び替え
        if !condition.genre.isEmpty {
            guard let index = NewsListModel.shared.genreList.index(of: condition.genre) else { return "" }
            conditionStr.append("&genre=" + index.description)
        } else if condition.word.isEmpty {
            conditionStr.append("&score=1")
        }
        
        // ワード
        if let word = condition.word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            !word.isEmpty {
            conditionStr.append("&word=" + word)
        }
        
        // 取得件数
        conditionStr.append("&num=" + condition.num.description)
        
        return conditionStr
    }

    /// APIの基本URLを作成する
    ///
    /// - Parameter type: APIの種類
    /// - Returns: APIの基本URL
    private func createUrlBase(type: ApiType) -> String {
        let host = Bundle.Api(key: .host)
        let pass = Bundle.Api(key: .pass)
        var apiStr = ""
        switch type {
        case .getNews:
            apiStr = "/getNews.php?pass="
        case .updateNewsScore:
            apiStr = "/updateNewsScore.php?pass="
        }
        
        return host + apiStr + pass
    }
    
    /// ニュースリスト取得
    ///
    /// - Parameters:
    ///   - genre: ジャンル
    ///   - word: ワード
    ///   - num: 取得件数
    ///   - completion: ニュースリスト
    func newsList(condition: GetNewsCondition, completion: @escaping ([Article])->Void) {
        var url = ""
        if condition.word.isEmpty {
            let genreFileName = getGistGenreFileName(genreName: condition.genre)
            if genreFileName.isEmpty  {
                completion([])
                return
            }
            url = Bundle.Api(key: .gistHost) + Bundle.Api(key: .gistGenre) + genreFileName
        } else {
            url = createUrlBase(type: .getNews) + createGetNewsCondition(condition: condition)
        }
        
        Alamofire.request(url).responseData { response in
            guard let responce = response.result.value else {
                completion([])
                return
            }
            let news = self.parseJsonNews(at: responce)
            DispatchQueue.mainSyncSafe  {
                var saveArticles: [Article] = []
                for article in news {
                    // すでに記事が内部に存在する場合は保存しない
                    if NewsListModel.shared.articles(title: article.title).isEmpty {
                        saveArticles.append(article)
                    }
                }
                if !saveArticles.isEmpty {
                    TArticle.createOrUpdate(articles: saveArticles)
                    self.prefetchImages(articles: saveArticles)
                }
                completion(news)
            }
        }
    }
    
    /// タイトルと一致した記事のスコアを+1する
    ///
    /// - Parameters:
    ///   - title: タイトル
    ///   - completion: 結果
    func updateNewsScore(title: String, completion: @escaping (Bool)->Void) {
        if title.isEmpty {
            completion(true)
            return
        }
        var url = createUrlBase(type: .updateNewsScore)
        if let title = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            !title.isEmpty {
            url = url + "&title=" + title
        }
        Alamofire.request(url).responseData { response in
            completion(true)
            return
        }
    }
    
    /// ジャンル別記事情報をRealmから取得する
    ///
    /// - Parameter genre: ジャンル
    func articles(genre: String = "") -> [Article] {
        var predicate = NSPredicate()
        switch genre {
        case "新着", "人気":
            predicate = NSPredicate(format: "date > %@", argumentArray: [Date().dayBefore(day: 7)])
        default:
            predicate = NSPredicate(format: "genreName = %@", argumentArray: [genre])
        }
        let sort = genre == "人気" ? SortKey.score : SortKey.date
        return takeArticles(predicate: predicate, sortKey: sort, num: numReadMax)
    }

    /// ワードに一致する記事をRealmから取得する
    ///
    /// - Parameter word: ワード
    func articles(words: [String]) -> [Article] {
        if words.isEmpty { return [] }
        var formatList: [String] = []
        for _ in words { formatList.append("title contains[c] %@") }
        let format = formatList.joined(separator: " AND ")
        let predicate = NSPredicate(format: format, argumentArray: words)
        return takeArticles(predicate: predicate, sortKey: .date, num: numReadMax)
    }
    
    /// タイトルに一致する記事をRealmから取得する
    ///
    /// - Parameter title: タイトル
    func articles(title: String) -> [Article] {
        let predicate = NSPredicate(format: "title = %@", argumentArray: [title])
        return takeArticles(predicate: predicate, sortKey: .date, num: numReadMax)
    }
    
    /// クリップ追加されている記事情報をRealmから取得する
    func articles() -> [Article] {
        let predicate = NSPredicate(format: "clipDate != %@", argumentArray: [NSDate(timeInterval: 0, since: Date(timeIntervalSince1970: 0))])
        return takeArticles(predicate: predicate, sortKey: .clipDate, num: numReadMax)
    }
    
    /// 古い記事情報をRealmから削除する
    func removeOldArticles() {
        let removeBeforeDate = Date().dayBefore(day: 365)
        let predicate = NSPredicate(format: "date < %@", argumentArray: [removeBeforeDate])
        let realm = RLMRealm.default()
        realm.beginWriteTransaction()
        realm.deleteObjects(TArticle.objects(with: predicate))
        do {
            try realm.commitWriteTransaction()
        } catch {
            realm.cancelWriteTransaction()
        }
    }
    
    /// Realmからニュース一覧を取り出す
    ///
    /// - Parameters:
    ///   - predicate: 条件
    ///   - sortKey: 並び順
    ///   - num: 取得件数
    /// - Returns: ニュース一覧
    private func takeArticles(predicate: NSPredicate?, sortKey: SortKey, num: Int = 0) -> [Article] {
        var articles: [Article] = []
        let results = TArticle.objects(in: RLMRealm.default(),
                                       with: predicate).sortedResults(usingKeyPath: sortKey.rawValue,
                                                                      ascending: false)
        for result in results {
            var article = Article()
            let tArticle = result as! TArticle
            article.title = tArticle.title
            article.genreName = tArticle.genreName
            article.sourceName = tArticle.sourceName
            article.title = tArticle.title
            article.url = tArticle.url
            if let date = tArticle.date {
                article.date = date
            }
            article.imageUrl = tArticle.imageUrl
            article.score = tArticle.score
            if let clipDate = tArticle.clipDate {
                article.clipDate = clipDate
            }
            article.isRead = tArticle.isRead
            articles.append(article)
            
            if num > 0 && articles.count >= num { break }
        }
        return articles
    }
    
    /// 記事画像を先読みする
    ///
    /// - Parameter articles: 記事リスト
    func prefetchImages(articles: [Article]) {
        if !UserDefaults.standard.isDispThumbnail { return }
        var urlList: [URL] = []
        for article in articles {
            if let url = URL(string: article.imageUrl) {
                urlList.append(url)
            }
        }
        let imagePrefetcher = SDWebImagePrefetcher.shared()
        imagePrefetcher.prefetchURLs(urlList)
    }
    
    /// 指定されたジャンル名によるgistでのファイル名を取得する
    ///
    /// - Parameter genreName: ジャンル名
    /// - Returns: gist上のファイル名
    private func getGistGenreFileName(genreName: String) -> String {
        let gistFileList = ["new", "pop", "startup", "service", "design", "cryptocurrency", "worktechnique",
                            "useful", "consideration", "life", "product"]
        if !genreName.isEmpty {
            guard let index = NewsListModel.shared.genreList.index(of: genreName),
                let fileName = gistFileList[safe: index] else { return "" }
            return fileName
        }
        return "all"
    }
}
