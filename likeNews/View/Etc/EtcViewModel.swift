//
//  EtcViewModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

class EtcViewModel {
    
    var etcCellViewModel: [Any]! {
        didSet {
            didChange?()
        }
    }

    private var didChange: (() -> Void)?
    
    func bind(didChange: @escaping () -> Void) {
        self.didChange = didChange
    }

    /// 表示種別
    enum CellViewType: Int, EnumEnumerable {
        /// 天気情報
        case weather = 0
        /// お問い合わせ
        case inquiry
        /// キャッシュクリア
        case cacheClear
        /// サムネイル表示
        case dispThumbnail
        /// 記事を読んだ人数表示
        case dispReadArticleNum
        /// 音声アシスト
        case speech
    }

    /// cellViewModel作成
    ///
    /// - Parameter articles: 記事情報。無ければrealm内の情報を元に作成する
    func createCellViewModel() {
        var viewModel: [Any] = []
        for i in 0..<CellViewType.count {
            guard let type = CellViewType(rawValue: i) else { break }
            if type == .weather {
                viewModel.append(EtcWeatherCellViewModel())
            } else {
                viewModel.append(EtcCellViewModel(type: type))
            }
        }
        etcCellViewModel = viewModel
    }
}
