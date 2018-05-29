//
//  SegmentCollectionViewCell.swift
//  UpTabViewController
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

class SegmentCollectionViewCell: UICollectionViewCell {
    /// 背景
    @IBOutlet weak var backView: UIView!
    /// タイトル
    @IBOutlet weak var titleLabel: UILabel!
    /// 表示用データ
    var viewModel: SegmentCollectionViewCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.text = viewModel.titleText
            titleLabel.textColor = viewModel.titleColor
        }
    }
    
    /// 選択状態表示
    ///
    /// - Parameter seected: true:選択状態 false:未選択状態
    func selectedState(selected: Bool) {
        guard let viewModel = viewModel else { return }
        viewModel.setTitleColor(isSelected: selected)
        titleLabel.textColor = viewModel.titleColor
    }
}
