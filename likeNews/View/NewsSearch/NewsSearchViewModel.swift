//
//  NewsSearchViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

class NewsSearchViewModel {
    var newsListCellViewModel: [NewsListCellViewModel] = [] {
        didSet {
            didChange?()
        }
    }
    /// 検索ワード
    var searchWord = ""
    /// ニュース一覧
    var newsList: [Article] = []
    // 1ページあたりの読み込み件数
    let numReadOfPage = 29
    /// 現在のページ
    var page = 1
    /// 記事無しView表示有無
    var isNonArticleViewHidden = false
    
    private var didChange: (() -> Void)?
    
    func bind(didChange: @escaping () -> Void) {
        self.didChange = didChange
    }
    
    /// cellViewModel作成
    ///
    /// - Parameter articles: 記事情報。無ければrealm内の情報を元に作成する
    func createCellViewModel(articles: [Article] = []) {
        page = 1
        newsList = !articles.isEmpty ?
            articles : NewsListModel.shared.articles(words: searchWord.replacingOccurrences(of: "　", with: " ").components(separatedBy: " "))
        isNonArticleViewHidden = !newsList.isEmpty
        newsListCellViewModel = NewsListViewModel.createNewsListCellViewModel(articles: newsList, isDispTop: false)
    }
    
    /// ニュース読み込み
    ///
    /// - Parameter completion: completion
    func reload(word: String, completion: @escaping ()->Void) {
        var condition = NewsListModel.GetNewsCondition()
        condition.word = word
        NewsListModel.shared.newsList(condition: condition, completion: { articles in
            self.createCellViewModel(articles: articles)
            completion()
        })
    }
    
    /// 次の記事を読み込む（広告含む）
    func loadNext() {
        let nextViewModelList = NewsListViewModel.createNewsListCellNextViewModel(articles: newsList, viewModelList: newsListCellViewModel, page: page)
        page += 1
        newsListCellViewModel = nextViewModelList
    }
    
    /// ニュースリストを削除する
    func clearNewsList() {
        newsList = []
        newsListCellViewModel = []
    }
    
    /// 記事無しView表示有無をセット
    ///
    /// - Parameter isHidden: 記事無しView表示有無
    func setNonArticleViewHidden(isHidden: Bool) {
        isNonArticleViewHidden = isHidden
    }
}
