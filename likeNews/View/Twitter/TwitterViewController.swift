//
//  TwitterViewController.swift
//  likeNews
//
//  Created by System on 2017/12/05.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import SVProgressHUD
import TwitterKit
import Social

class TwitterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TWTRTweetViewDelegate {
    
    /// tableView
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(R.nib.tweetCell)
        }
    }
    /// ツイート無しView
    @IBOutlet weak var nonTweetView: UIView!
    /// ツイートボタン
    @IBOutlet var tweetButton: UIButton! {
        didSet {
            tweetButton.layer.borderColor = UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1).cgColor
            tweetButton.layer.borderWidth = 2
            tweetButton.layer.cornerRadius = tweetButton.frame.height * 0.5
            tweetButton.layer.masksToBounds = true
        }
    }
    /// 閉じるViewの高さ
    @IBOutlet var closeViewHeight: NSLayoutConstraint!
    /// ViewModel
    var viewModel: TwitterViewModel?
    /// セルの高さ
    var heightAtIndexPath = NSMutableDictionary()
    /// ボタン種別
    enum ButtonType: Int {
        /// 閉じるボタン
        case close = 100
        /// ツイートボタン
        case tweet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iPhoneXとそれ以外の端末で閉じるボタンViewの高さを合わせる
        if #available(iOS 11.0, *), CGRect().screenHeight() == 812 {
            closeViewHeight.constant = closeViewHeight.constant + 14
        }
        
        SVProgressHUD.show()
        
        if let viewModel = viewModel {
            self.navigationItem.title = viewModel.article.title + "に関するツイート"
            viewModel.reload(word: viewModel.article.title, completion: {_ in
                self.tableView.reloadDataAfter {
                    self.nonTweetView.alpha = viewModel.tweetCellViewModel.count > 0 ? 0 : 1
                    self.tweetButton.isHidden = viewModel.isTweetButtonHidden
                    SVProgressHUD.dismiss()
                }
            })
        }
    }

    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cellViewModel = viewModel?.tweetCellViewModel else { return 0 }
        return cellViewModel.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.tweetCell),
            let cellViewModel = viewModel?.tweetCellViewModel[safe: indexPath.row] else { return UITableViewCell() }
        cell.viewModel = cellViewModel
        cell.tweetView.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TWTRTweetViewDelegate
    
    func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
    }
    
    // MARK: - User Event
    
    @IBAction func tapButton(_ sender: UIButton) {
        switch sender.tag {
        case ButtonType.close.rawValue:
            // 閉じるボタン
            close()
            
        case ButtonType.tweet.rawValue:
            // ツイートボタン
            tweet()
            
        default: break
        }
    }
    
    // MARK: - Private Method
    
    /// 画面を閉じる
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    /// ツイートする
    func tweet() {
        var composeView: SLComposeViewController
        composeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        if let viewModel = viewModel {
            composeView.setInitialText(viewModel.tweetInitText)
        }
        self.present(composeView, animated: true, completion: nil)
    }
}
