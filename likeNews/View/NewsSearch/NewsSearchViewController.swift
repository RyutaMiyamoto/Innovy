//
//  NewsSearchViewController.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewsSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NewsListCellDelegate, ArticleDetailViewControllerDelegate {
    /// 記事無しView
    @IBOutlet weak var nonArticleView: UIView!
    /// サーチバー
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    /// tableView
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(R.nib.newsListCell)
        }
    }
    /// キーボードに配置する閉じるボタン用ツールバー
    var toolbar: UIToolbar? {
        didSet {
            guard let toolbar = toolbar else { return }
            toolbar.barStyle = .default
            toolbar.sizeToFit()
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapCloseButton(sender:)))
            toolbar.items = [spacer, closeButton]
            searchBar.inputAccessoryView = toolbar
        }
    }
    /// ViewModel
    var viewModel = NewsSearchViewModel()
    /// セルの高さ
    var heightAtIndexPath = NSMutableDictionary()
    /// 記事更新
    var refreshControl: UIRefreshControl!

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationタイトル設定
        self.navigationItem.titleView = R.nib.navigationTitleView.firstView(owner: self)
        
        initSetting()
        DispatchQueue.mainSyncSafe { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.bind {
                self.tableView.reloadDataAfter {
                    self.refreshControl.endRefreshing()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // キーボードを閉じる
        searchBar.resignFirstResponder()
    }

    // MARK: - User Event
    
    func tapCloseButton(sender: UIButton) {
        // キーボードを閉じる
        searchBar.resignFirstResponder()
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        searchBar.resignFirstResponder()
        
        // 検索
        guard let text = searchBar.text else { return }
        if !text.isEmpty {
            searchText()
        } else {
            viewModel.clearNewsList()
            viewModel.setNonArticleViewHidden(isHidden: false)
            nonArticleView.isHidden = viewModel.isNonArticleViewHidden
        }
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
        cell.delegate = self
        if cellViewModel.dispType == .ad, !cellViewModel.isAdLoad {
            cell.loadAd()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsListCell, let viewModel = cell.viewModel else { return }
        performSegue(withIdentifier: R.segue.newsSearchViewController.articleDetail.identifier, sender: viewModel.sourceArticle)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height && tableView.isDragging &&
            viewModel.newsList.count > viewModel.numReadOfPage * viewModel.page  {
            viewModel.loadNext()
        }
    }

    // MARK: - segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = R.segue.newsSearchViewController.articleDetail(segue: segue)?.destination,
            let article = sender as? Article {
            viewController.delegate = self
            viewController.hidesBottomBarWhenPushed = true
            viewController.article = article
        }
    }
    
    // MARK: - NewsListCellDelegate
    
    func imageUrlLoadComplete(from cell: NewsListCell) {
    }
    
    // MARK: - ArticleDetailViewControllerDelegate
    
    func toBack(from viewController: ArticleDetailViewController, article: Article) {
        // 既読状態更新
        updateVisibleIsRead()
    }

    // MARK: - Private Method
    
    /// 初期設定
    func initSetting() {
        
        // ツールバー作成
        toolbar = UIToolbar()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
    }
    
    func refresh(sender: UIRefreshControl) {
        if #available(iOS 10.0, *) {
            // 検索
            searchText()
        } else {
            // Fallback on earlier versions
        }
    }
    
    /// 入力されたテキストから記事を検索する
    func searchText() {
        guard let text = searchBar.text else { return }
        if text.isEmpty {
            self.refreshControl.endRefreshing()
            return
        }
        viewModel.searchWord = text
        SVProgressHUD.show()
        viewModel.reload(word: text, completion: { [weak self] in
            guard let `self` = self else { return }
            self.nonArticleView.isHidden = self.viewModel.isNonArticleViewHidden
        })
    }
    
    /// 表示されている記事の既読状態更新
    func updateVisibleIsRead() {
        for visibleCell in tableView.visibleCells {
            if let cell = visibleCell as? NewsListCell { cell.updateTextColor() }
        }
    }
}
