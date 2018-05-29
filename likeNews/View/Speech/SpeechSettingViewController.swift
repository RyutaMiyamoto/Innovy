//
//  SpeechSettingViewController.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/12/29.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

class SpeechSettingViewController: UIViewController {
    /// 読み上げ速度Slider
    @IBOutlet weak var rateSlider: UISlider!
    /// 読み上げ音程Slider
    @IBOutlet weak var pitchSlider: UISlider!
    /// ViewModel
    var viewModel = SpeechSettingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.bind {
            DispatchQueue.mainSyncSafe {
                self.rateSlider.value = self.viewModel.rateValue
                self.pitchSlider.value = self.viewModel.pitchValue
            }
        }
        
        // 初期設定
        initSetting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 音声停止
        SpeechModel.shared.stopSpeech()
        
        // 設定値保存
        viewModel.saveSetting()
    }
    
    // MARK: - User Event
    
    @IBAction func rightSwipeGesture(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func rateSliderTouchUpInside(_ sender: UISlider) {
        viewModel.updateValue(rate: rateSlider.value, pitch: pitchSlider.value)
        SpeechModel.shared.startSpeechConfirm(rate: rateSlider.value, pitch: pitchSlider.value)
    }
    
    @IBAction func pitchSliderTouchUpInside(_ sender: UISlider) {
        viewModel.updateValue(rate: rateSlider.value, pitch: pitchSlider.value)
        SpeechModel.shared.startSpeechConfirm(rate: rateSlider.value, pitch: pitchSlider.value)
    }
    
    // MARK: - Private Method
    
    /// 初期設定
    func initSetting() {
        rateSlider.value = viewModel.rateValue
        pitchSlider.value = viewModel.pitchValue
    }
}
