//
//  NewsListViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/04/14.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

class NewsListViewModel {
    
    var newsListCellViewModel: [NewsListCellViewModel]! {
        didSet {
            didChange?()
        }
    }
    
    /// ジャンル
    var genre: String = ""
    /// ニュース一覧
    var newsList: [Article] = []
    /// 最大読み込み件数
    let maxNewsList = 100
    // 1ページあたりの読み込み件数
    let numReadOfPage = 25
    /// 現在のページ
    var page = 1
    
    private var didChange: (() -> Void)?
    
    func bind(didChange: @escaping () -> Void) {
        self.didChange = didChange
    }
    
    /// 初期化処理
    ///
    /// - Parameters:
    ///   - genre: ジャンル
    init(genre: String) {
        self.genre = genre
        createCellViewModel()
    }
    
    /// 一覧に初期表示する記事一覧ViewModelリストを作成する（広告含む）
    ///
    /// - Parameters:
    ///   - articles: 全記事一覧
    ///   - isDispTop: 先頭記事表示有無（true:先頭記事表示させる）
    /// - Returns: 初期表示する記事一覧ViewModelリスト
    class func createNewsListCellViewModel(articles: [Article], isDispTop: Bool = true) -> [NewsListCellViewModel] {
        if articles.isEmpty { return [] }
        // 1ページあたりの読み込み件数
        let numReadOfPage = 25
        // 作成後ViewModelリスト
        var viewModelList: [NewsListCellViewModel] = []
        for article in articles {
            let dispType: NewsListCellViewModel.DispType = viewModelList.isEmpty && isDispTop ? .top : .normal
            viewModelList.append(NewsListCellViewModel(article: article, index: IndexPath(row: viewModelList.count, section: 0), type: dispType))
            if viewModelList.count >= numReadOfPage { break }
        }
        // 広告挿入位置
        let adIndexList = articles.count > numReadOfPage ? numReadOfPage.indexOfAd(minIndex: 0) : articles.count.indexOfAd(minIndex: 0)
        for adIndex in adIndexList {
            if viewModelList.count > adIndex + 1 {
                viewModelList.insert(NewsListCellViewModel(index: IndexPath(row: viewModelList.count, section: 0), type: .ad), at: adIndex)
            }
        }
        
        return viewModelList
    }
    
    /// 次ページ読み込み後に表示する記事一覧ViewModelリストを作成する（広告含む）
    ///
    /// - Parameters:
    ///   - articles: 全記事一覧
    ///   - viewModelList: 現在表示している記事一覧ViewModelリスト
    ///   - page: 現在のページ
    /// - Returns: 次ページ読み込み後に表示する記事一覧ViewModelリスト
    class func createNewsListCellNextViewModel(articles: [Article], viewModelList: [NewsListCellViewModel], page: Int) -> [NewsListCellViewModel] {
        // 1ページあたりの読み込み件数
        let numReadOfPage = 25
        // 戻り値
        var tmpViewModelList = viewModelList
        // newsListに対する読み込み開始位置（記事 + 広告）
        let startIndex = numReadOfPage * page
        // newsListに対する読み込み終了位置
        let endIndex = startIndex + numReadOfPage < articles.count ? startIndex + numReadOfPage : articles.count - 1
        // 記事挿入
        for i in startIndex..<endIndex {
            tmpViewModelList.append(NewsListCellViewModel(article: articles[i], index: IndexPath(row: viewModelList.count, section: 0), type: .normal))
        }
        // 広告挿入位置
        let adIndexList = endIndex.indexOfAd(minIndex: startIndex)
        for adIndex in adIndexList {
            if tmpViewModelList.count > adIndex + 1 {
                tmpViewModelList.insert(NewsListCellViewModel(index: IndexPath(row: viewModelList.count, section: 0), type: .ad), at: adIndex)
            }
        }
        
        return tmpViewModelList
    }
    
    /// cellViewModel作成
    ///
    /// - Parameter articles: 記事情報。無ければrealm内の情報を元に作成する
    private func createCellViewModel(articles: [Article] = []) {
        page = 1
        newsList = !articles.isEmpty ? articles : NewsListModel.shared.articles(genre: genre)
        newsListCellViewModel = NewsListViewModel.createNewsListCellViewModel(articles: newsList)
    }
    
    /// ニュース読み込み
    ///
    /// - Parameter completion: completion
    func reload(completion: @escaping ()->Void) {
        var condition = NewsListModel.GetNewsCondition()
        condition.genre = genre
        condition.num = maxNewsList
        NewsListModel.shared.newsList(condition: condition, completion: { articles in
            self.createCellViewModel(articles: articles)
            completion()
        })
    }
    
    /// 次の記事を読み込む（広告含む）
    func loadNext() {
        guard let viewModelList = newsListCellViewModel else { return }
        let nextViewModelList = NewsListViewModel.createNewsListCellNextViewModel(articles: newsList, viewModelList: viewModelList, page: page)
        page += 1
        newsListCellViewModel = nextViewModelList
    }
}
