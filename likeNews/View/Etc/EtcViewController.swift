//
//  EtcViewController.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import CTFeedback
import SDWebImage
import StoreKit

class EtcViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                         EtcCellDelegate, EtcWeatherCellDelegate {
    
    /// tableView
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(R.nib.etcCell)
            tableView.register(R.nib.etcWeatherCell)
        }
    }
    
    // お問い合わせView
    var feedbackViewController: UINavigationController?

    /// ViewModel
    var viewModel = EtcViewModel()
    /// セルの高さ
    var heightAtIndexPath = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationタイトル設定
        self.navigationItem.titleView = R.nib.navigationTitleView.firstView(owner: self)
        
        viewModel.bind {
            DispatchQueue.mainSyncSafe { [weak self] in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            }
        }
        // 初期設定
        initSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirebaseAnalyticsModel.shared.sendScreen(screenName: .etc, screenClass: classForCoder.description())
        
        // 前回レビュー促進ダイアログを表示してから一定期間表示がない場合のみ再表示する。
        if UserDefaults().previousDateRequestReview.dayAfter(day: 120) > Date() { return }
        // レビュー促進ダイアログ表示
        DispatchQueue.mainSyncSafe { [weak self] in
            guard let _ = self else { return }
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                UserDefaults().previousDateRequestReview = Date()
            }
        }
    }
    
    // MARK: - TableView Delegate & DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.etcCellViewModel.count
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
        if let cellViewModel = viewModel.etcCellViewModel[indexPath.row] as? EtcCellViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etcCell, for: indexPath) else { return UITableViewCell() }
            cell.viewModel = cellViewModel
            cell.delegate = self
            return cell
        } else if let cellViewModel = viewModel.etcCellViewModel[indexPath.row] as? EtcWeatherCellViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.etcWeatherCell, for: indexPath) else { return UITableViewCell() }
            cell.viewModel = cellViewModel
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? EtcWeatherCell {
            // 天気情報更新
            cell.updateWeather()
            
            // FirebaseAnalytics（天気情報手動更新）
            FirebaseAnalyticsModel.shared.sendEvent(eventName: .updateWeather, params: nil)
            
        } else if let cell = tableView.cellForRow(at: indexPath) as? EtcCell,
            let viewModel = cell.viewModel {
            switch viewModel.type {
            case .weather:
                break
            case .inquiry:
                if let navigaticonController = feedbackViewController {
                    present(navigaticonController, animated: true, completion:nil)
                    // FirebaseAnalytics（お問い合わせタップ）
                    FirebaseAnalyticsModel.shared.sendEvent(eventName: .tapInquiry, params: nil)
                }
            case .cacheClear:
                clearCache()
            case .dispThumbnail:
                break
            case .dispReadArticleNum:
                break
            case .speech:
                performSegue(withIdentifier: R.segue.etcViewController.speechSetting.identifier, sender: nil)
            }
        }
    }

    // MARK: - EtcCell Delegate
    
    func toggleSwitch(from sender: EtcCell) {
        guard let viewModel = sender.viewModel else { return }
        switch viewModel.type {
        case .weather:
            break
        case .inquiry:
            break
        case .cacheClear:
            break
        case .dispThumbnail:
            UserDefaults.standard.isDispThumbnail = sender.titleSwitch.isOn
            
            // FirebaseAnalytics（サムネイル表示切り替え）
            let params = ["サムネイル表示": sender.titleSwitch.isOn.description]
            FirebaseAnalyticsModel.shared.sendEvent(eventName: .switchingDispThumbnail, params: params)
        case .dispReadArticleNum:
            UserDefaults.standard.isDispReadArticleNum = sender.titleSwitch.isOn
            
            // FirebaseAnalytics（記事を読んだ人数表示切り替え）
            let params = ["人数表示": sender.titleSwitch.isOn.description]
            FirebaseAnalyticsModel.shared.sendEvent(eventName: .switchingDispReadArticleNum, params: params)

        case .speech:
            break
        }
    }
    
    // MARK: - EtcWeatherCell Delegate

    func updateFinished(cell: EtcWeatherCell, result: Bool) {
        if result { tableView.reloadData() }
    }
    
    func showAlertAuthorizationLocation(cell: EtcWeatherCell) {
        // 位置情報取得許可アラート表示
        let alertController = UIAlertController(title: R.string.localizable.etcWeatherLocationAuthorizationTitle(),
                                                message: R.string.localizable.etcWeatherLocationAuthorizationMessage(), preferredStyle: .alert)
        let toSettingButton = UIAlertAction(title: R.string.localizable.ok(), style: UIAlertAction.Style.default){ (action: UIAlertAction) in }
        alertController.addAction(toSettingButton)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Private Method

    /// 初期設定
    func initSetting() {
        // viewMode作成
        viewModel.createCellViewModel()

        // お問い合わせView作成
        if let viewController = CTFeedbackViewController(topics: CTFeedbackViewController.defaultLocalizedTopics(), localizedTopics: ["不具合報告", "質問", "要望", "その他"]) {
            viewController.toRecipients = [Bundle.Mail(key: .inquiry)]
            viewController.useHTML = true
            let navigaticonController = UINavigationController(rootViewController: viewController)
            navigaticonController.navigationBar.barTintColor = .darkGray
            navigaticonController.navigationBar.tintColor = .darkGray
            feedbackViewController = navigaticonController
        }
        
        // 天気情報取得
        updateWeather()
    }
    
    /// キャッシュをクリアする
    func clearCache() {
        let alert = UIAlertController(title: R.string.localizable.etcClearCacheBeforeTitle(),
                                      message: R.string.localizable.etcClearCacheBeforeMessage(),
                                      preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: R.string.localizable.ok(), style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            // FirebaseAnalytics（キャッシュクリア実行）
            FirebaseAnalyticsModel.shared.sendEvent(eventName: .clearCache, params: nil)
            
            SDWebImageManager.shared.imageCache.clear(with: .all, completion: {
                let alert = UIAlertController(title:nil,
                                              message: R.string.localizable.etcClearCacheAfterMessage(),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.ok(),
                                              style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        })
        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in })
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 天気情報を更新する
    func updateWeather() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EtcWeatherCell else { return }
        cell.updateWeather()
    }
}
