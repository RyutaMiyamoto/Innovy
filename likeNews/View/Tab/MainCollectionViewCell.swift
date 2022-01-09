//
//  MainCollectionViewCell.swift
//  UpTabViewController
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

protocol MainCollectionViewCellDelegate: AnyObject {
    /// 記事詳細画面に遷移
    ///
    /// - Parameters:
    ///   - viewController: 呼び出しcell
    ///   - article: 記事情報
    func toArticleDetail(from cell: MainCollectionViewCell, article: Article)
    
    /// ニュース読み上げ開始
    ///
    /// - Parameter cell: 呼び出し元
    func startSpeech(from cell: MainCollectionViewCell)
    
    /// ニュース読み上げ終了
    ///
    /// - Parameter cell: 呼び出し元
    func endSpeech(from cell: MainCollectionViewCell)
}

class MainCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, NewsListCellDelegate, ArticleDetailViewControllerDelegate, SpeechModelDelegate {

    /// 背景
    @IBOutlet weak var backView: UIView!
    // ニュース一覧
    @IBOutlet weak var tableView: NewsListTableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(R.nib.newsListCell)
        }
    }
    weak var delegate: MainCollectionViewCellDelegate?
    
    /// セルの高さ
     var heightAtIndexPath = NSMutableDictionary()
     /// ViewModel
    var viewModel: MainCollectionViewCellViewModel? {
        didSet {
            initSetting()
            
            guard let viewModel = viewModel else { return }
            viewModel.bind {
                self.refreshView()
            }
        }
    }
     /// 記事更新
     var refreshControl: UIRefreshControl!
     /// これから読み込み対象のTableViewCellのIndexPath（Analyticsで使用）
     var analyticsIndexPath = IndexPath(row: 0, section: 0)
     /// スクロール開始Offset。下方向スクロール判別用。（Analyticsで使用）
     var scrollBeginingOffset = CGPoint(x: 0, y: 0)
     /// 下方向にスクロールしたか
     var isUnderScroll = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        FirebaseAnalyticsModel.shared.sendScreen(screenName: .newsList, screenClass: classForCoder.description())
    }
     
     // MARK: - TableView Delegate & DataSource
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         guard let cellViewModel = viewModel?.newsListCellViewModel else { return 0 }
         return cellViewModel.count
     }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }
     
     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
             return CGFloat(height.floatValue)
         } else {
             return UITableView.automaticDimension
         }
     }
     
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         let height = NSNumber(value: Float(cell.frame.size.height))
         heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // 表示対象のIndexPathを取得
         analyticsIndexPath = indexPath
         
         guard let viewModel = viewModel, let cellViewModel = viewModel.newsListCellViewModel[safe: indexPath.row],
             let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.newsListCell, for: indexPath) else { return UITableViewCell() }
         cell.viewModel = cellViewModel
         switch cellViewModel.dispType {
         case .normal, .top:
             cell.articleImageUrl()
         case .ad:
             if !cellViewModel.isAdLoad {
                 cell.loadAd()
             }
         }
         cell.delegate = self
         return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         guard let cell = tableView.cellForRow(at: indexPath) as? NewsListCell ,
             let viewModel = cell.viewModel, let sourceArticle = viewModel.sourceArticle else { return }
         delegate?.toArticleDetail(from: self, article: sourceArticle)
     }
     
     @IBAction func tableViewCellLongPress(_ sender: UILongPressGestureRecognizer) {
         guard sender.state == .began else { return }
         articleLongPress(gesture: sender)
     }
     
     // MARK: - UIScrollViewDelegate
     
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         scrollBeginingOffset = scrollView.contentOffset
     }

     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         // スクロール方向判別
         isUnderScroll = scrollBeginingOffset.y < scrollView.contentOffset.y

         // 次ページ読み込み判別
         guard let viewModel = viewModel else { return }
         if  tableView.contentOffset.y + tableView.frame.size.height > tableView.contentSize.height && tableView.isDragging &&
             viewModel.newsList.count > viewModel.numReadOfPage * viewModel.page  {
             viewModel.loadNext()
         }
     }

     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         // FirebaseAnalytics（どこまでスクロールしたか）
         if isUnderScroll, let viewModel = viewModel,
             let vendor = UIDevice.current.identifierForVendor {
             let params = ["UUID": vendor.uuidString,
                           "ジャンル": viewModel.genre,
                           "スクロール位置": analyticsIndexPath.row.description]
             FirebaseAnalyticsModel.shared.sendEvent(eventName: .scrollNews, params: params)
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
         tableView.refreshControl = refreshControl
         
         refreshView()
     }
     
     @objc func refresh(sender: UIRefreshControl) {
         guard let viewModel = viewModel else { return }
         viewModel.reload(completion: { })
         
         // FirebaseAnalytics（ニュース一覧手動更新）
         let params = ["ジャンル": viewModel.genre]
         FirebaseAnalyticsModel.shared.sendEvent(eventName: .updateNews, params: params)
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
         let toArticleDetail = UIAlertAction(title: R.string.localizable.articleLongPressToDetail(), style: UIAlertAction.Style.default){ (action: UIAlertAction) in
             if let longPressCellViewModel = longPressCellViewModel, let sourceArticle = longPressCellViewModel.sourceArticle {
                 self.delegate?.toArticleDetail(from: self, article: sourceArticle)
             }
         }
         alertController.addAction(toArticleDetail)
         
         // 音声アシスト開始ボタン
         let speechStart = UIAlertAction(title: R.string.localizable.articleLongPressSpeechStart(), style: UIAlertAction.Style.default){ (action: UIAlertAction) in
             SpeechModel.shared.startSpeech(articles: speechArticles)
             self.delegate?.startSpeech(from: self)
             SpeechModel.shared.delegate = self
         }
         alertController.addAction(speechStart)
         
         // キャンセルボタン
         let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertAction.Style.cancel, handler: nil)
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
