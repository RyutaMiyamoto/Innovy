//
//  EtcCellViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/10/21.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

class EtcCellViewModel: NewsListModel {
    
    /// 表示種別
    var type = EtcViewModel.CellViewType.inquiry
    /// タイトル
    var titleText = ""
    /// アイコン画像
    var iconImage: UIImage?
    /// スイッチ表示有無
    var isSwitchHidden = true
    /// スイッチの状態
    var isSwitchOn = true
    /// 次ページ画像表示有無
    var isNextImageHidden = true
    
    init(type: EtcViewModel.CellViewType) {
        self.type = type
        switch type {
        case .weather:
            break
        case .inquiry:
            titleText = "お問い合わせ"
            iconImage = R.image.etcInquiry()
        case .cacheClear:
            titleText = "キャッシュクリア"
            iconImage = R.image.etcCacheClear()
        case .dispThumbnail:
            titleText = "サムネイル表示"
            iconImage = R.image.etcDispThumbnail()
            isSwitchHidden = false
            isSwitchOn = UserDefaults.standard.isDispThumbnail
        case .dispReadArticleNum:
            titleText = "記事を読んだ人数表示"
            iconImage = R.image.etcDispArticleNum()
            isSwitchHidden = false
            isSwitchOn = UserDefaults.standard.isDispReadArticleNum
        case .speech:
            titleText = "音声アシスト"
            iconImage = R.image.etcSpeech()
            isNextImageHidden = false
        }
    }
}

