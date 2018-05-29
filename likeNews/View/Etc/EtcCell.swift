//
//  EtcCell.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/10/21.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

protocol EtcCellDelegate: class {
    /// スイッチ切り替え
    ///
    /// - Parameters:
    ///   - viewController: 呼び出し元
    func toggleSwitch(from sender: EtcCell)
}

class EtcCell: UITableViewCell {
    weak var delegate: EtcCellDelegate?

    /// アイコン画像
    @IBOutlet weak var iconImageView: UIImageView!
    /// タイトルラベル
    @IBOutlet weak var titleLabel: UILabel!
    /// スイッチ
    @IBOutlet weak var titleSwitch: UISwitch!
    /// 次ページ画像
    @IBOutlet var nextImageView: UIImageView!
    
    var viewModel: EtcCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            iconImageView.image = viewModel.iconImage
            titleLabel.text = viewModel.titleText
            titleSwitch.isHidden = viewModel.isSwitchHidden
            titleSwitch.setOn(viewModel.isSwitchOn, animated: false)
            nextImageView.isHidden = viewModel.isNextImageHidden
        }
    }

    @IBAction func toggleSwitch(_ sender: UISwitch) {
        delegate?.toggleSwitch(from: self)
    }
}
