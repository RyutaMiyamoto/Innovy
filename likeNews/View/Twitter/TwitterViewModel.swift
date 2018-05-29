//
//  TwitterViewModel.swift
//  likeNews
//
//  Created by System on 2017/12/05.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterViewModel {
    
    /// 記事情報
    var article: Article
    
    var tweetCellViewModel: [TweetCellViewModel]! {
        didSet {
            didChange?()
        }
    }
    
    /// ツイートViewリスト
    var tweetViewList: [TweetCell] = []
    /// ツイート初期テキスト
    var tweetInitText = ""
    /// ツイートボタン表示有無
    var isTweetButtonHidden = false
    
    private var didChange: (() -> Void)?
    
    func bind(didChange: @escaping () -> Void) {
        self.didChange = didChange
    }

    /// 初期化
    ///
    /// - Parameter article: 記事情報
    init(article: Article) {
        self.article = article
        tweetInitText = "\n\n" + article.title + "\n" + article.url
        isTweetButtonHidden = !UIApplication.shared.canOpenURL(URL(string: "twitter://")!)
    }
    
    /// 一覧に表示するツイート一覧ViewModelリストを作成する
    ///
    /// - Parameter tweetList: 全ツイート
    /// - Returns: ツイート一覧ViewModelリスト
    class func createTweetCellViewModel(tweetList: [TWTRTweet]) -> [TweetCellViewModel] {
        if tweetList.isEmpty { return [] }
        // 作成後ViewModelリスト
        var viewModelList: [TweetCellViewModel] = []
        for tweet in tweetList {
            viewModelList.append(TweetCellViewModel(tweet: tweet))
        }
        
        return viewModelList
    }
    
    /// ツイート読み込み
    ///
    /// - Parameter completion: completion
    func reload(word: String = "", completion: @escaping ()->Void) {
        TweetListModel.shared.tweetList(word: word, completion: { tweetList in
            self.tweetCellViewModel = TwitterViewModel.createTweetCellViewModel(tweetList: tweetList)
            completion()
        })
    }
}
