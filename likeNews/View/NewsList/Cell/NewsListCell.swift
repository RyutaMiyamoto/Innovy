//
//  NewsListCell.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/01/05.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit
import SDWebImage
import NendAd

protocol NewsListCellDelegate: AnyObject {
    
    /// 画像URL読み込み完了
    ///
    /// - Parameters:
    ///   - cell: 呼び出し元
    func imageUrlLoadComplete(from cell: NewsListCell)
}

class NewsListCell: UITableViewCell {
    /// delegate
    weak var delegate: NewsListCellDelegate?
    /// 背景
    @IBOutlet weak var backView: UIView!
    /// 広告表示Block用
    @IBOutlet var adBlockView: UIView!
    /// タイトル
    @IBOutlet var titleLabel: UILabel!
    /// 情報元
    @IBOutlet var sourceLabel: UILabel!
    /// 備考
    @IBOutlet var noteLabel: UILabel!
    /// 記事画像View（一覧先頭用）
    @IBOutlet weak var topArticleImageBackView: UIView!
    /// 記事画像View
    @IBOutlet weak var articleImageBackView: UIView!
    /// 記事画像（一覧先頭用）
    @IBOutlet var topArticleImageView: UIImageView! {
        didSet {
            topArticleImageView.sd_imageIndicator = SDWebImageProgressIndicator.default
        }
    }
    /// 記事画像
    @IBOutlet var articleImageView: UIImageView! {
        didSet {
            articleImageView.sd_imageIndicator = SDWebImageProgressIndicator.default
        }
    }
    
    var viewModel: NewsListCellViewModel? {
        didSet {
            setCellInfo()
        }
    }
    
    /// 記事画像
    var imageUrl: String = "" {
        didSet {
            DispatchQueue.mainSyncSafe { [weak self] in
                guard let `self` = self, let viewModel = viewModel,
                    let imageView = viewModel.dispType == .top ? self.topArticleImageView : self.articleImageView,
                    let imageBackView = viewModel.dispType == .top ? self.topArticleImageBackView : self.articleImageBackView else { return }
                guard !self.imageUrl.isEmpty, self.imageUrl != "nothing",
                    let url = URL(string: self.imageUrl) else {
                        if !imageBackView.isHidden {
                            imageBackView.isHidden = true
                            self.delegate?.imageUrlLoadComplete(from: self)
                        }
                        return
                }
                
                if UIApplication.shared.canOpenURL(url) {
                    imageView.setImageSmoothly(url: url, placeholderImage: R.image.commonArticlePlaceholder())
                } else {
                    imageBackView.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Private Method

    /// 記事画像URL取得
    func articleImageUrl() {
        // サムネイル非表示設定時は画像を非表示にする
        if !UserDefaults.standard.isDispThumbnail {
            delegate?.imageUrlLoadComplete(from: self)
            return
        }
        guard let viewModel = viewModel else { return }
        imageUrl = viewModel.imageUrl
    }
    
    /// 文字色更新
    func updateTextColor() {
        guard let viewModel = self.viewModel else { return }
        viewModel.updateTextColor()
        titleLabel.textColor = viewModel.titleTextColor
    }
    
    /// 広告読み込み
    func loadAd() {
        guard let viewModel = viewModel else { return }
        viewModel.loadAd(completion: { result in
            guard result else { return }
            viewModel.isAdLoad = true
            self.setCellInfo()
        })
    }
    
    /// セル情報セット
    func setCellInfo() {
        guard let viewModel = viewModel else { return }
        DispatchQueue.mainSyncSafe { [weak self] in
            guard let `self` = self else { return }
            self.titleLabel.text = viewModel.titleText
            self.titleLabel.textColor = viewModel.titleTextColor
            self.sourceLabel.text = viewModel.sourceNameText
            self.noteLabel.text = viewModel.noteText
            self.topArticleImageBackView.isHidden = viewModel.topArticleImageHidden
            self.articleImageBackView.isHidden = viewModel.articleImageHidden
            if viewModel.dispType == .ad {
                self.articleImageView.image = viewModel.imageAd
            } else {
                self.imageUrl = viewModel.imageUrl
            }
            self.setSpeechState(state: viewModel.isSpeechNow)
        }
    }

    /// スピーチ状態をセットする
    ///
    /// - Parameter state: スピーチ状態（true:読み上げ中、false:読んでいない）
    func setSpeechState(state: Bool) {
        guard let viewModel = self.viewModel else { return }
        self.backView.backgroundColor = viewModel.isSpeechNow ? .speechCell() : .white
    }
}
