//
//  NewsClipViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/24.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

class NewsClipViewModel {
    var newsListCellViewModel: [NewsListCellViewModel] = [] {
        didSet {
            didChange?()
        }
    }
    
    /// ニュース一覧
    var newsListType = NewsListType()
    /// 記事無しView表示有無
    var isNonArticleViewHidden = false

    private var didChange: (() -> Void)?
    
    func bind(didChange: @escaping () -> Void) {
        self.didChange = didChange
    }
    
    /// cellViewModel作成
    func createCellViewModel() {
        let realmNews = NewsListModel.shared.articles()
        var viewModel: [NewsListCellViewModel] = []
        isNonArticleViewHidden = !realmNews.isEmpty
        if realmNews.isEmpty {
            newsListCellViewModel = viewModel
            return
        }
        for article in realmNews {
            viewModel.append(NewsListCellViewModel(article: article, index: IndexPath(row: viewModel.count, section: 0), type: .normal))
        }
        newsListCellViewModel = viewModel
    }
}
