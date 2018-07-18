//
//  NewsClipViewController.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/24.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

class NewsClipViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 記事無しView
    @IBOutlet weak var nonArticleView: UIView!
    /// tableView
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(R.nib.newsListCell)
        }
    }
    /// ViewModel
    var viewModel = NewsClipViewModel()
    /// セルの高さ
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationタイトル設定
        self.navigationItem.titleView = R.nib.navigationTitleView.firstView(owner: self)
        
        viewModel.bind {
            self.tableView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.createCellViewModel()
        nonArticleView.isHidden = viewModel.isNonArticleViewHidden
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsListCellViewModel.count
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.newsListCell),
            let cellViewModel = viewModel.newsListCellViewModel[safe: indexPath.row] else { return UITableViewCell() }
        cell.viewModel = cellViewModel
        cell.articleImageUrl()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsListCell, let viewModel = cell.viewModel else { return }
        performSegue(withIdentifier: R.segue.newsClipViewController.articleDetail.identifier, sender: viewModel.sourceArticle)
    }

    // MARK: - segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = R.segue.newsClipViewController.articleDetail(segue: segue)?.destination,
            let article = sender as? Article {
            viewController.hidesBottomBarWhenPushed = true
            viewController.article = article
        }
    }
}
