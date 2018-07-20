//
//  ArticleDetailViewController.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import WebKit
import TwitterKit

protocol ArticleDetailViewControllerDelegate: class {
    /// 遷移元画面に戻る
    ///
    /// - Parameters:
    ///   - viewController: 呼び出し元
    ///   - article: 記事情報
    func toBack(from viewController: ArticleDetailViewController, article: Article)
}

class ArticleDetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    weak var delegate: ArticleDetailViewControllerDelegate?

    /// 読み込み進捗プログレスバー
    @IBOutlet weak var progressView: UIProgressView!
    /// クリップボタン
    @IBOutlet weak var clipButton: UIButton! {
        didSet {
            setClipButtonImage()
        }
    }
    /// 注目View
    @IBOutlet weak var attentionView: UIView!
    /// 注目ラベル
    @IBOutlet weak var attentionLabel: UILabel!
    /// 注目Viewの左マージン
    @IBOutlet weak var attentionViewLeftMargin: NSLayoutConstraint!
    
    /// 記事情報
    var article: Article!
    /// webView
    var webView: WKWebView!
    /// ProgressView更新タイマ
    var timer: Timer!
    /// ProgressView更新間隔
    let timerDur = 0.1
    /// 注目View表示済み有無（true:表示済み、false:表示前）
    var isDispAttentionView = false
    /// 戻る有無
    var isBack = false
    
    /// ボタン種別
    enum ButtonType: Int {
        /// 戻るボタン
        case back = 100
        /// シェアボタン
        case share
        /// クリップボタン
        case clip
        /// Twitterボタン
        case twitter
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // NavigationBarを非表示にする
        self.navigationController?.navigationBar.isHidden = true
        
        // エッジスワイプ禁止
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // WebView設定
        settingWebView()
        
        // 記事をrealmから取得する（記事のクリップ状態を最新化させるため）
        if let tmpArticle = NewsListModel.shared.articles(title: article.title).first { article = tmpArticle }
        
        // 記事のスコアを+1する
        NewsListModel.shared.updateNewsScore(title: article.title, completion:{ _ in})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // タブを非表示にする
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ProgressView設定
        settingProgressView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isBack { return }
        
        // NavigationBarを非表示にする
        self.navigationController?.navigationBar.isHidden = false
        
        // タブを表示する
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 終了処理
        hideView()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url == nil {
            decisionHandler(.cancel)
            return
        }
        
        // target="_blank"の場合
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.isMainFrame) {
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - User Event
    
    @IBAction func rightSwipeGesture(_ sender: UISwipeGestureRecognizer) {
        // 戻る
        goBack()
    }
    
    @IBAction func tapButton(_ sender: UIButton) {
        switch sender.tag {
        case ButtonType.back.rawValue:
            // 戻るボタン
            goBack()
            
        case ButtonType.share.rawValue:
            // シェアボタン
            share()
            
        case ButtonType.clip.rawValue:
            // クリップボタン
            clip()
        
        case ButtonType.twitter.rawValue:
            // Twitterボタン
            twitter()
            
        default: break
        }
        
        // ボタンタップ時のアクション
        buttonTapAction(button: sender)
    }
    
    // MARK: - WkWebView Delegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 閲覧件数表示
        showAttentionView()
        
        // 記事の既読有無を保存
        saveIsRead()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        article.url = url.description
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // エラー処理
        networkError(isTop: !webView.canGoBack)
    }

    // MARK: - Private Method
    
    /// 戻る（前画面、またはリンク元）
    private func goBack() {
        isBack = true
        // 戻るボタン
        if webView.canGoBack {
            // 記事内でリンク先に飛んでいた場合はリンク元画面に戻る
            webView.goBack()
        } else {
            // 記事のトップ画面の場合は一覧画面に戻る
            navigationController?.popViewController(animated: true)
            delegate?.toBack(from: self, article: article)
        }
        dismiss(animated: true, completion: nil)
    }
    
    /// クリップする
    private func clip() {
        toggleClip()
        setClipButtonImage()
        showClipAlert()
    }
    
    /// シェアする
    private func share() {
        // 共有する項目
        let activityItems = [article.title, article.url] as [Any]
        
        // 共有対象
        let activityOpenSafari = ActivityOpenSafari()
        activityOpenSafari.url = URL(string: article.url)
        let applicationActivities = [activityOpenSafari]
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivityType.saveToCameraRoll
        ]
        activityVC.excludedActivityTypes = excludedActivityTypes
        
        present(activityVC, animated: true, completion: nil)
    }
    
    /// ツイート
    private func twitter() {
        isBack = false
        guard let navigationController = R.storyboard.twitter.instantiateInitialViewController() else { return }
        guard let twitterViewController = navigationController.topViewController as? TwitterViewController else { return }
        twitterViewController.viewModel = TwitterViewModel(article: article)
        present(navigationController, animated: true, completion: nil)
    }
    
    /// ボタンをタップした時のアクション
    ///
    /// - Parameter button: ボタン
    func buttonTapAction(button: UIButton) {
        DispatchQueue.mainSyncSafe { _ in
            UIView.animate(withDuration: 0.05, animations: { _ in
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { _ in
                UIView.animate(withDuration: 0.05, animations: { _ in
                    button.transform = CGAffineTransform.identity
                }, completion: nil)
            })
        }
    }
    
    /// WebView設定
    func settingWebView() {
        webView = WKWebView()
        // Autolayoutを設定
        webView.translatesAutoresizingMaskIntoConstraints = false
        // 親ViewにWKWebViewを追加
        view.addSubview(webView)
        // 拡大/縮小禁止
        webView.scrollView.maximumZoomScale = 1
        webView.scrollView.minimumZoomScale = 1
        // Delegateの設定
        webView.uiDelegate = self
        webView.navigationDelegate = self
        // WKWebViewを最背面に移動
        view.sendSubview(toBack: webView)
        // レイアウトを設定（後述）
        setWebViewLayoutWithConstant()
        // ページのロード
        if let url = URL(string: article.url) {
            webView.load(URLRequest(url: url))
        }
    }
    
    /// ProgressView設定
    func settingProgressView() {
        // プログレスビューの描画
        progressView.setProgress(0.0, animated: false)
        progressView.alpha = 1
        timer = Timer.scheduledTimer(timeInterval: timerDur, target: self,
                                     selector: #selector(ArticleDetailViewController.updateProgressView),
                                     userInfo: nil, repeats: true)
    }
    
    /// WebViewのレイアウト設定
    func setWebViewLayoutWithConstant(){
        // Constraintsを一度削除する
        for constraint in self.view.constraints {
            let secondItem: WKWebView? = constraint.secondItem as? WKWebView
            if secondItem == self.webView {
                self.view.removeConstraint(constraint)
            }
        }
        // Constraintsを追加
        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: topLayoutGuide, attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: bottomLayoutGuide, attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 44))
    }
    
    /// ProgressView更新
    func updateProgressView() {
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        if webView.estimatedProgress == 1.0 && timer?.isValid == true {
            // ページの読み込みが完了したらProgressViewを非表示にする
            timer?.invalidate()
            UIView.animate(withDuration: 0.5, animations: { self.progressView.alpha = 0  })
        }
    }
    
    /// ProgressView更新
    func hideView() {
        if !isBack { return }
        
        webView.removeFromSuperview()
        
        if timer?.isValid == true {
            timer?.invalidate()
        }
    }
    
    /// クリップ、またはクリップ解除する
    func toggleClip() {
        if article.clipDate == Date(timeIntervalSince1970: 0) {
            article.clipDate = Date()
        } else {
            article.clipDate = Date(timeIntervalSince1970: 0)
        }
        _ = TArticle.createOrUpdate(article: article)
    }
    
    /// 既読状態を保存する
    func saveIsRead() {
        if !article.isRead {
            article.isRead = true
            _ = TArticle.createOrUpdate(article: article)
        }
    }
    
    /// 現在のクリップ状態に対応する画像をクリップボタンに設定する
    func setClipButtonImage() {
        if let article = NewsListModel.shared.articles(title: article.title).first,
            article.clipDate != Date(timeIntervalSince1970: 0) {
            clipButton.setImage(R.image.articleDetailClipOnButton(), for: .normal)
        } else {
            clipButton.setImage(R.image.articleDetailClipOffButton(), for: .normal)
        }
    }
    
    /// 記事クリップによるアラートを表示する
    func showClipAlert() {
        if article.clipDate != Date(timeIntervalSince1970: 0) {
            let alert = UIAlertController(title: "",
                                          message: R.string.localizable.detailOnClip(),
                                          preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            
            // 1秒後に実行
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// 閲覧件数を画面に表示する（一瞬表示して、自動で非表示になる）
    func showAttentionView() {
        if !UserDefaults.standard.isDispReadArticleNum || isDispAttentionView { return }
        isDispAttentionView = true
        let startTopMargin: CGFloat = CGRect().screenWidth()
        let endTopMargin: CGFloat = 60
        let text = article.score > 0 ? R.string.localizable.detailAttentionMoreBefore() + article.score.description +
            R.string.localizable.detailAttentionMoreAfter() : R.string.localizable.detailAttentionFirst()
        attentionLabel.text = text
        
        DispatchQueue.mainSyncSafe { [weak self] in
            guard let `self` = self else { return }
            self.attentionViewLeftMargin.constant = startTopMargin
            self.attentionView.alpha = 0.25
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let `self` = self else { return }
                self.attentionViewLeftMargin.constant = endTopMargin
                self.view.layoutIfNeeded()
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, delay: 1, options: .curveLinear, animations: { [weak self] in
                        guard let `self` = self else { return }
                        self.attentionView.alpha = 0
                        }, completion: { _ in
                            
                    })
            })
        }
    }
    
    /// Networkエラー処理
    ///
    /// - Parameter isTop: 詳細先頭画面有無（true:先頭画面）
    func networkError(isTop: Bool) {
        // 先頭画面以外は何もしない
        if !isTop { return }
        
        // アラート表示。タップ後に一覧画面に戻る
        let alertController = UIAlertController(title: R.string.localizable.detailNetworkErrorTitle(),
                                                message: R.string.localizable.detailNetworkErrorMessage(), preferredStyle: .alert)
        let okButton = UIAlertAction(title: R.string.localizable.ok(), style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            self.isBack = true
            self.navigationController?.popViewController(animated: true)
            self.delegate?.toBack(from: self, article: self.article)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okButton)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController,animated: true,completion: nil)
    }
}
