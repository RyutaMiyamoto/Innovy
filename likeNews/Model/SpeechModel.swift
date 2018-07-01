//
//  SpeechModel.swift
//  likeNews
//
//  Created by R.miyamoto on 2017/12/29.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import AVFoundation

protocol SpeechModelDelegate: class {
    
    /// 1件読み上げ完了
    ///
    /// - Parameters:
    ///   - finishText: 読み上げ完了記事タイトル
    ///   - nextText: 次に読み上げる記事タイトル
    func speechFinishItem(finishText: String, nextText: String)
    
    /// 全読み上げ完了
    func speechFinish()
    
    /// 読み上げ停止
    ///
    /// - Parameter stopText: 停止時点の記事タイトル
    func speechStop(stopText: String)
}

class SpeechModel: NSObject, AVSpeechSynthesizerDelegate {
    
    static let shared = SpeechModel()
    weak var delegate: SpeechModelDelegate?
    /// 読み上げシンセサイザ
    var synthesizer = AVSpeechSynthesizer()
    /// 記事情報
    var articles: [Article] = []
    /// 読み上げ情報
    var speechTexts: [String] = []
    /// 読み上げ中有無
    var isSpeech = false
    /// 現在読み上げ中の要素
    var speechIndex = 0
    /// 言語
    var voice: AVSpeechSynthesisVoice?
    /// 読み上げ速度
    var rate: Float = 0
    /// 読み上げ高さ
    var pitch: Float = 0
    
    override init() {
        super.init()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if utterance.speechString != R.string.localizable.speechStart() &&
            utterance.speechString != R.string.localizable.speechEnd() &&
            utterance.speechString != R.string.localizable.speechNextArticle() &&
            speechTexts.count > speechIndex + 2 {
            // ”次です”を読み上げ
            synthesizer.speak(setSpeechText(text: R.string.localizable.speechNextArticle()))
            
        } else if speechTexts.count > speechIndex + 1 {
            // 次の記事を読み上げ
            delegate?.speechFinishItem(finishText: speechTexts[speechIndex], nextText: speechTexts[speechIndex + 1])
            speechIndex += 1
            let text = speechTexts[speechIndex]
            
            synthesizer.speak(setSpeechText(text: text))
        } else {
            // 読み上げ終了
            delegate?.speechFinish()
            stopSpeech()
        }
    }
    
    // MARK: - Private Method
    
    /// 音声再生開始
    ///
    /// - Parameter articles: 記事情報
    func startSpeech(articles: [Article]) {
        // まず読み上げを停止する
        stopSpeech()
        
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        isSpeech = true
        
        // 1件目の記事情報取得
        if articles.isEmpty { return }
        self.articles = articles
        
        // 読み上げ機能初期設定
        voice = AVSpeechSynthesisVoice(language: "ja-JP")
        rate = UserDefaults.standard.speechRate
        pitch = UserDefaults.standard.speechPitch
        
        speechTexts = []
        speechTexts.append(R.string.localizable.speechStart())
        for article in articles { speechTexts.append(article.title) }
        speechTexts.append(R.string.localizable.speechEnd())
        speechIndex = 0
        
        // 読み上げ開始
        guard let text = speechTexts.first else { return }
        synthesizer.speak(setSpeechText(text: text))
    }
    
    /// 音声再生開始（確認）
    ///
    /// - Parameters:
    ///   - rate: 速さ
    ///   - pitch: 高さ
    func startSpeechConfirm(rate: Float, pitch: Float) {
        // まず読み上げを停止する
        stopSpeech()
        
        isSpeech = true
        
        // 読み上げ機能初期設定
        let utterance = AVSpeechUtterance(string: R.string.localizable.speechSettingConfirm())
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = rate
        utterance.pitchMultiplier = pitch

        synthesizer.speak(utterance)
    }
    
    /// 音声再生停止
    func stopSpeech() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        isSpeech = false
        guard speechTexts.count > speechIndex else { return }
        delegate?.speechStop(stopText: speechTexts[speechIndex])
        speechTexts = []
    }
    
    /// 音声設定
    ///
    /// - Parameter text: 読み上げテキスト
    /// - Returns: AVSpeechUtterance
    private func setSpeechText(text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        return utterance
    }
}
