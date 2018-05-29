//
//  SegmentCollectionViewCellViewModel.swift
//  UpTabViewController
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

class SegmentCollectionViewCellViewModel {
    /// タイトルテキスト
    var titleText = ""
    /// タイトル色
    var titleColor: UIColor = .darkGray
    
    /// タイトルカラーを設定する
    ///
    /// - Parameter isSelected: 選択状態
    func setTitleColor(isSelected: Bool) {
        if isSelected {
            titleColor = .darkGray
        } else {
            titleColor = .lightGray
        }
    }
}
