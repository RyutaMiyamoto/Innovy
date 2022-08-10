//
//  UpTabViewControllerViewModel.swift
//  UpTabViewController
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

class UpTabViewControllerViewModel {
    /// ジャンルリスト
    var genreList: [String] = []
    /// 余白
    var collectionViewEdgeInsetsSegment = UIEdgeInsets.zero
    /// セルサイズ（セグメント）
    var cellSizeSegment:[CGSize] = []
    /// セルサイズ（メイン）
    var cellSizeMain:[CGSize] = []
    /// ニュース一覧
    var newsListType = NewsListType()
    /// メインViewModelリスト
    var mainCollectionViewCellViewModelList: [MainCollectionViewCellViewModel] = []
    /// セグメントViewModelリスト
    var segmentCollectionViewCellViewModelList: [SegmentCollectionViewCellViewModel] = []
    /// 選択状態Viewの表示位置リスト
    var selectedStateViewFrameList: [CGRect] = []
    
    /// 初期設定
    ///
    /// - Parameter tabinfo: タブ情報
    func setInfo(genreList: [String]) {
        self.genreList = genreList
        createCellSize()
        createEdgeInsets()
        mainCollectionViewCellViewModelList = createMainCollectionViewCellViewModel()
        segmentCollectionViewCellViewModelList = createSegmentCollectionViewCellViewModel()
    }
    
    /// 全セルのサイズ作成
    private func createCellSize() {
        cellSizeSegment = []
        cellSizeMain = []
        
        // セグメントCellの両端マージン
        let segmentCellBothMargin:CGFloat = 82
        // 選択状態Cellの横位置
        var selectedStateViewOriginX: CGFloat = 0
        for genre in genreList {
            // セグメント
            let titleLabelWidth = genre.labelWidth(height: 22, font: UIFont.boldSystemFont(ofSize: 18))
            let segmentCellWidth = titleLabelWidth + segmentCellBothMargin
            // 選択状態View
            if selectedStateViewOriginX == 0 { selectedStateViewOriginX = CGRect().screenWidth() * 0.5 - segmentCellWidth * 0.5 }
            selectedStateViewFrameList.append(CGRect(x: selectedStateViewOriginX + segmentCellBothMargin * 0.5, y: 50,
                                                     width: titleLabelWidth, height: 2))
            cellSizeSegment.append(CGSize(width: segmentCellWidth, height: 54))
            selectedStateViewOriginX = selectedStateViewOriginX + segmentCellWidth
            
            // メイン
            cellSizeMain.append(CGSize(width: CGRect().screenWidth(),
                                       height: CGRect().screenHeight() - CGRect().statusBarHeight() - 155))
        }
    }
    
    /// 余白設定
    private func createEdgeInsets() {
        // セグメント
        if let cellSizeFirst = cellSizeSegment.first, let cellSizeLast = cellSizeSegment.last {
            let center = CGRect().screenWidth() * 0.5
            let leftMargin = center - cellSizeFirst.width * 0.5
            let rightMargin = center - cellSizeLast.width * 0.5
            collectionViewEdgeInsetsSegment = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: rightMargin)
        }
    }

    /// メインViewModelリストを作成する
    ///
    /// - Returns: メインViewModelリスト
    private func createMainCollectionViewCellViewModel() -> [MainCollectionViewCellViewModel] {
        var viewModelList: [MainCollectionViewCellViewModel] = []
        for genre in genreList {
            let viewModel = MainCollectionViewCellViewModel(genre: genre)
            viewModelList.append(viewModel)
        }
        return viewModelList
    }
    
    /// セグメントViewModelリストを作成する
    ///
    /// - Returns: セグメントViewModelリスト
    private func createSegmentCollectionViewCellViewModel() -> [SegmentCollectionViewCellViewModel] {
        guard let titleStart = genreList.first else { return [] }
        var viewModelList: [SegmentCollectionViewCellViewModel] = []
        for genre in genreList {
            let viewModel = SegmentCollectionViewCellViewModel()
            viewModel.titleText = genre
            viewModel.titleColor = genre == titleStart ? .darkGray : .lightGray
            viewModelList.append(viewModel)
        }
        return viewModelList
    }
    
    /// ニュース読み込み
    ///
    /// - Parameter completion: completion
    func loadNews(genre: String = "", completion: @escaping ()->Void) {
        var condition = NewsListModel.GetNewsCondition()
        condition.genre = genre
        NewsListModel.shared.newsList(condition: condition, completion: { response in
            completion()
        })
    }
}
