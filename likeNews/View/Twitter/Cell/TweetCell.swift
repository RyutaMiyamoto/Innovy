//
//  TweetCell.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/12/05.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import TwitterKit

class TweetCell: UITableViewCell {
    /// ツイートView
    @IBOutlet var tweetView: TWTRTweetView!
    /// ViewModel
    var viewModel: TweetCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            DispatchQueue.mainSyncSafe { [weak self] in
                guard let _ = self else { return }
                tweetView.configure(with: viewModel.sourceTweet)
            }
        }
    }
}
