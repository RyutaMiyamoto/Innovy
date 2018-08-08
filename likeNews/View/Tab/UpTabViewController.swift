//
//  UpTabViewController.swift
//  UpTabViewController
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import SVProgressHUD

class UpTabViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NewsListViewControllerDelegate {

    /// CollectionView種別
    enum CollectionViewType: Int {
        /// セグメント
        case segment = 1
        /// メインView
        case mainView
    }
    /// セグメント
    @IBOutlet weak var segmentCollectionView: UICollectionView! {
        didSet {
            segmentCollectionView.register(R.nib.segmentCollectionViewCell)
        }
    }
    /// メイン
    @IBOutlet weak var mainCollectionView: UICollectionView! {
        didSet {
            mainCollectionView.register(R.nib.mainCollectionViewCell)
        }
    }
    /// 読み上げ停止ボタン
    @IBOutlet var speechStopButton: UIButton! {
        didSet {
            speechStopButton.layer.borderColor = UIColor.titleFont().cgColor
            speechStopButton.layer.borderWidth = 2
            speechStopButton.layer.cornerRadius = speechStopButton.frame.height * 0.5
            speechStopButton.layer.masksToBounds = true
        }
    }
    /// 選択状態View
    var selectedStateView: UIView! {
        didSet {
            selectedStateView.backgroundColor = .thema()
            selectedStateView.layer.cornerRadius = 1
            selectedStateView.layer.masksToBounds = true

        }
    }
    
    /// 選択中セグメントセル
    private var selectedSegmentIndexPath = IndexPath(row: 0, section: 0)
    /// 先読み有無（true:先読み済み）
    private var isPrefetching = false

    /// viewModel
    var viewModel = UpTabViewControllerViewModel()
    /// 画面リスト
    var newsViewControllerList: [(viewController: UIViewController, title: String)] = []
    /// 遷移元ViewController
    var sourceNewsListViewController: NewsListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationタイトル設定
        self.navigationItem.titleView = R.nib.navigationTitleView.firstView(owner: self)
        
        // 初期設定
        initSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 読み上げ停止ボタン表示有無
        if !SpeechModel.shared.isSpeech { speechStopButton.alpha = 0 }
    }

    // MARK: - CollectionView Delegate & DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sourceTabInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tabInfo = viewModel.sourceTabInfo[indexPath.row]
        // セグメント
        if collectionView == segmentCollectionView {
            if let cell = segmentCollectionView.dequeueReusableCell(withReuseIdentifier: R.nib.segmentCollectionViewCell,
                                                                    for: indexPath) {
                let segmentViewModel = viewModel.segmentCollectionViewCellViewModelList[indexPath.row]
                let isSelected = indexPath == selectedSegmentIndexPath
                segmentViewModel.setTitleColor(isSelected: isSelected)
                cell.viewModel = segmentViewModel
                viewModel.segmentCollectionViewCellViewModelList[indexPath.row] = segmentViewModel
                return cell
            }
        }
        
        // メイン
        if collectionView == mainCollectionView {
            if let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: R.nib.mainCollectionViewCell,
                                                                 for: indexPath),
                let viewController: NewsListViewController = tabInfo.viewController as? NewsListViewController {
                viewController.delegate = self
                cell.setView(viewController: viewController)
                return cell
            }
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // セグメント
        if collectionView == segmentCollectionView {
            // 選択中の上タブをもう一度タップした場合は、該当ニュース一覧を先頭にスクロールする
            if mainCollectionView.contentOffset.x == CGRect().screenWidth() * CGFloat(indexPath.row) {
                if let cell = mainCollectionView.cellForItem(at: indexPath) as? MainCollectionViewCell,
                   let viewController = cell.newsListViewController {
                    viewController.tableView.setContentOffset(CGPoint.zero, animated: true)
                }
            } else {
                // 対象セルを画面の中央に表示
                segmentCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)

                // 画面をセグメントに該当する位置に移動
                mainCollectionView.setContentOffset(CGPoint(x: CGRect().screenWidth() * CGFloat(indexPath.row),
                                                            y: mainCollectionView.contentOffset.y), animated: true)
                
                // セグメントを選択状態にする
                setSelectedSegmentedCell(indexPath: indexPath)
                
                // 選択状態View移動
                moveSelectedStateView(indexPath: indexPath)
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // セグメント
        if collectionView == segmentCollectionView {
            return viewModel.cellSizeSegment[indexPath.row]
        }
        
        // メイン
        if collectionView == mainCollectionView {
            // スクロールをスムーズにするために、全てのセルを１画面に表示させてCellを作成しておく
            if isPrefetching {
                return viewModel.cellSizeMain[indexPath.row]
            } else {
                return CGSize(width: CGFloat(viewModel.sourceTabInfo.count) / CGRect().screenWidth(),
                              height: CGRect().screenHeight() - UIApplication.shared.statusBarFrame.size.height - 155)
            }
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == segmentCollectionView {
            // セグメント
            return viewModel.collectionViewEdgeInsetsSegment
        } else {
            // メイン
            return UIEdgeInsets.zero
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionViewType = CollectionViewType(rawValue: scrollView.tag) else { return }
        
        if collectionViewType == .mainView {
            // メイン
            let pageIndex = Int(scrollView.contentOffset.x / CGRect().screenWidth())
            
            // セグメントを選択状態にする
            let selectedIndexPath = IndexPath(row: pageIndex, section: 0)
            segmentCollectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
            setSelectedSegmentedCell(indexPath: selectedIndexPath)
            moveSelectedStateView(indexPath: selectedIndexPath)
        }
    }

    // MARK: - NewsListViewControllerDelegate
    
    func toArticleDetail(from viewController: NewsListViewController, article: Article) {
        // 記事詳細画面に遷移
        sourceNewsListViewController = viewController
        performSegue(withIdentifier: R.segue.upTabViewController.articleDetail.identifier, sender: article)
    }
    
    func startSpeech(from viewController: NewsListViewController) {
        // 読み上げ停止ボタン表示
        dispSpeechStopButton()
    }
    
    func endSpeech(from viewController: NewsListViewController) {
        // 読み上げ停止ボタン非表示
        hideSpeechStopButton()
    }
    
    // MARK: - segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = R.segue.upTabViewController.articleDetail(segue: segue)?.destination,
            let article = sender as? Article {
            viewController.delegate = sourceNewsListViewController
            viewController.hidesBottomBarWhenPushed = true
            viewController.article = article
        }
    }
    
    // MARK: - User Event
    
    @IBAction func tapSpeechStopButton(_ sender: UIButton) {
        // 読み上げを停止し、読み上げ停止ボタン非表示
        SpeechModel.shared.stopSpeech()
        hideSpeechStopButton()
    }
    
    // MARK: - Private Method
    
    /// 初期設定を行う
    private func initSetting() {
        SVProgressHUD.show()
        self.viewModel.loadNews(completion: {
            // 画面作成
            self.createView()
        })
    }
    
    /// 初期作成
    private func create(array: [(viewController: UIViewController, title: String)]) {
        viewModel.setInfo(tabinfo: array)
    }
    
    /// 画面作成
    private func createView() {
        // 各タブに表示するニュース一覧ViewController作成
        newsLists()
        // viewModelにviewControllerとタイトルをセット
        create(array: newsViewControllerList)
        // 選択状態View初期設定
        if let selectedStateViewFrame = viewModel.selectedStateViewFrameList.first {
            selectedStateView = UIView(frame: selectedStateViewFrame)
            segmentCollectionView.addSubview(selectedStateView)
        }
        
        // ジャンル別のニュース一覧Cellを作成
        mainCollectionView.reloadDataAfter {
            if !self.isPrefetching {
                self.isPrefetching = true
                self.mainCollectionView.reloadDataAfter {
                    SVProgressHUD.dismiss()
                }
            }
        }
        segmentCollectionView.reloadData()
    }
    
    /// ニュースリスト作成
    private func newsLists() {
        for genre in NewsListModel.shared.genreList {
            if let viewController =
                R.storyboard.newsList.instantiateInitialViewController() {
                viewController.viewModel = NewsListViewModel(genre: genre)
                newsViewControllerList.append((viewController, genre))
            }
        }
    }
    
    /// 前回選択表示されていたセルを未選択表示にし、今回指定されたIndexPathに該当するセルを選択表示する
    ///
    /// - Parameter indexPath: 指定パス
    private func setSelectedSegmentedCell(indexPath: IndexPath) {
        if indexPath != selectedSegmentIndexPath {
            selectedSegmentIndexPath = indexPath
            segmentCollectionView.reloadData()
        }
    }
    
    /// 読み上げ停止ボタン表示
    private func dispSpeechStopButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.speechStopButton.alpha = 1
        })
    }
    
    /// 読み上げ停止ボタン非表示
    private func hideSpeechStopButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.speechStopButton.alpha = 0
        })
    }
    
    /// 選択状態View移動
    ///
    /// - Parameter indexPath: 移動対象タブ位置
    private func moveSelectedStateView(indexPath: IndexPath) {
        DispatchQueue.mainSyncSafe {
            UIView.animate(withDuration: 0.3, animations: {
                guard let cellFrame = self.viewModel.selectedStateViewFrameList[safe: indexPath.row] else { return }
                self.selectedStateView.frame = cellFrame
            })
        }
    }
}
