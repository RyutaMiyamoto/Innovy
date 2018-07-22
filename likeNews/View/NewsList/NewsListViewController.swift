//
//  NewsListViewController.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/01/16.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import Alamofire

protocol NewsListViewControllerDelegate: class {
    /// 記事詳細画面に遷移
    ///
    /// - Parameters:
    ///   - viewController: 呼び出し元
    ///   - article: 記事情報
    func toArticleDetail(from viewController: NewsListViewController, article: Article)
    
    /// ニュース読み上げ開始
    ///
    /// - Parameter viewController: 呼び出し元
    func startSpeech(from viewController: NewsListViewController)
    
    /// ニュース読み上げ終了
    ///
    /// - Parameter viewController: 呼び出し元
    func endSpeech(from viewController: NewsListViewController)
}

class NewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewsListCellDelegate, ArticleDetailViewControllerDelegate, SpeechModelDelegate {
    
    weak var delegate: NewsListViewControllerDelegate?

    /// 記事一覧テーブル
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(R.nib.newsListCell)
        }
    }
    /// セルの高さ
    var heightAtIndexPath = NSMutableDictionary()
    /// ViewModel
    var viewModel: NewsListViewModel?
    /// 記事更新
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        initSetting()
        
        guard let viewModel = viewModel else { return }
        viewModel.bind {
            self.refreshView()
        }
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cellViewModel = viewModel?.newsListCellViewModel else { return 0 }
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
        
        guard let viewModel = viewModel, let cellViewModel = viewModel.newsListCellViewModel[safe: indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.newsListCell) else { return UITableViewCell() }
        cell.viewModel = cellViewModel
        cell.articleImageUrl()
        cell.delegate = self
        if cellViewModel.dispType == .ad, !cellViewModel.isAdLoad {
            cell.loadAd()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsListCell ,
            let viewModel = cell.viewModel, let sourceArticle = viewModel.sourceArticle else { return }
        delegate?.toArticleDetail(from: self, article: sourceArticle)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel else { return }
        if  tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height && tableView.isDragging &&
            viewModel.newsList.count > viewModel.numReadOfPage * viewModel.page  {
            viewModel.loadNext()
        }
    }
    
    @IBAction func tableViewCellLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        articleLongPress(gesture: sender)
    }
    
    // MARK: - NewsListCellDelegate
    
    func imageUrlLoadComplete(from cell: NewsListCell) {
    }

    // MARK: - ArticleDetailViewControllerDelegate
    
    func toBack(from viewController: ArticleDetailViewController, article: Article) {
        // 既読状態更新
        updateVisibleIsRead()
    }
    
    // MARK: - SpeechModelDelegate
    
    func speechFinishItem(finishText: String, nextText: String) {
        // 読み上げ完了セルを元に戻す
        setSpeechState(text: finishText, isSpeech: false)
        
        // 次に読み上げるセルを読み上げ中表示にする
        setSpeechState(text: nextText, isSpeech: true)
    }

    func speechFinish() {
        delegate?.endSpeech(from: self)
    }
    
    func speechStop(stopText: String) {
        // 読み上げ中セルを元に戻す
        setSpeechState(text: stopText, isSpeech: false)
    }

    // MARK: - Private Method

    /// 初期設定
    func initSetting() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
        }
        
        refreshView()
    }
    
    func refresh(sender: UIRefreshControl) {
        if #available(iOS 10.0, *) {
            guard let viewModel = viewModel else { return }
            viewModel.reload(completion: {_ in })
        } else {
            // Fallback on earlier versions
        }
    }
    
    /// 画面を再描画する
    func refreshView() {
        DispatchQueue.mainSyncSafe { [weak self] in
            guard let `self` = self else { return }
            self.tableView.reloadDataAfter {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    /// 表示されている記事の既読状態更新
    func updateVisibleIsRead() {
        for visibleCell in tableView.visibleCells {
            if let cell = visibleCell as? NewsListCell { cell.updateTextColor() }
        }
    }

    /// 記事ロングプレス処理
    ///
    /// - Parameter gesture: ジェスチャ
    func articleLongPress(gesture: UILongPressGestureRecognizer) {
        guard let viewModel = viewModel else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        var speechArticles: [Article] = []
        var longPressCellViewModel: NewsListCellViewModel?
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsListCell, let cellViewModel = cell.viewModel,
            cellViewModel.dispType == .top || cellViewModel.dispType == .normal else { return }
        longPressCellViewModel = cellViewModel
        
        if let longPressCellViewModel = longPressCellViewModel {
            var isMatch = false
            for viewModel in viewModel.newsListCellViewModel {
                guard let article = viewModel.sourceArticle else { continue }
                if isMatch {
                    speechArticles.append(article)
                } else if article.title == longPressCellViewModel.titleText {
                    isMatch = true
                    speechArticles.append(article)
                }
            }
        }
        
        // 詳細を見るボタン
        let alertController = UIAlertController(title: R.string.localizable.articleLongPressTitle(), message: nil, preferredStyle: .actionSheet)
        let toArticleDetail = UIAlertAction(title: R.string.localizable.articleLongPressToDetail(), style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            if let longPressCellViewModel = longPressCellViewModel, let sourceArticle = longPressCellViewModel.sourceArticle {
                self.delegate?.toArticleDetail(from: self, article: sourceArticle)
            }
        }
        alertController.addAction(toArticleDetail)
        
        // 音声アシスト開始ボタン
        let speechStart = UIAlertAction(title: R.string.localizable.articleLongPressSpeechStart(), style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            SpeechModel.shared.startSpeech(articles: speechArticles)
            self.delegate?.startSpeech(from: self)
            SpeechModel.shared.delegate = self
        }
        alertController.addAction(speechStart)
        
        // キャンセルボタン
        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancel)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController,animated: true,completion: nil)
    }
    
    /// スピーチ状態をセットする
    ///
    /// - Parameters:
    ///   - text: スピーチ対象Text
    ///   - isSpeech: スピーチ状態（true:読み上げ中、false:読んでいない）
    func setSpeechState(text: String, isSpeech: Bool) {
        guard let cellViewModel  = viewModel?.newsListCellViewModel else { return }
        if let row = cellViewModel.findIndex(includeElement: { $0.titleText == text }).first {
            let updateViewModel = cellViewModel[row]
            updateViewModel.setSpeechState(isSpeech: isSpeech)
            viewModel?.newsListCellViewModel[row] = updateViewModel
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? NewsListCell  {
                cell.setSpeechState(state: isSpeech)
            }
        }
    }
}
