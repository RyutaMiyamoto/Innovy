//
//  TweetCellViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/12/05.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import TwitterKit

class TweetCellViewModel {    
    /// ツイート情報
    var sourceTweet: TWTRTweet!
    
    /// init
    ///
    /// - Parameter tweet: ツイート情報
    init(tweet: TWTRTweet) {
        self.sourceTweet = tweet
    }
}
