//
//  SpeechSettingViewModel.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/12/29.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation

class SpeechSettingViewModel {
        
    private var didChange: (() -> Void)?
    
    func bind(didChange: @escaping () -> Void) {
        self.didChange = didChange
    }

    /// 速さ値
    var rateValue: Float = 0
    /// 高さ値
    var pitchValue: Float = 0
    
    /// 初期設定
    init() {
        updateValue(rate: UserDefaults.standard.speechRate, pitch: UserDefaults.standard.speechPitch)
    }
    
    /// 設定値更新
    ///
    /// - Parameters:
    ///   - rate: 速さ
    ///   - pitch: 高さ
    func updateValue(rate: Float, pitch: Float) {
        rateValue = rate
        pitchValue = pitch
        didChange?()
    }
    
    /// 設定値保存
    func saveSetting() {
        UserDefaults.standard.speechRate = rateValue
        UserDefaults.standard.speechPitch = pitchValue
    }
}
