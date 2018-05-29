//
//  EtcWeatherCellViewModel.swift
//  likeNews
//
//  Created by R.miyamoto on 2018/04/30.
//  Copyright © 2018年 R.Miyamoto. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class EtcWeatherCellViewModel: NSObject {
    
    /// 天気情報
    var weather = Weather()
    /// 日付
    var dateText = ""
    /// 地域
    var cityNameText = ""
    /// 天気アイコン画像
    var iconImage: UIImage?
    /// 現在気温
    var tempText = ""
    /// 最高気温ラベル
    var maxTempText = ""
    /// 最低気温ラベル
    var minTempText = ""
    
    /// ロケーションを元に天気情報を取得する
    ///
    /// - Parameters:
    ///   - location: ロケーション
    ///   - completion: 取得結果
    func update(location: CLLocation, completion: @escaping (Bool)->Void) {
        WeatherModel.shared.weather(location: location, completion: { weather in
            guard let weather = weather else {
                completion(false)
                return
            }
            self.weather = weather
            self.dateText = weather.date.monthAndDay() + "(" + weather.date.dayOfTheWeek() + ")"
            self.cityNameText = weather.cityName
            self.iconImage = WeatherModel.shared.iconImage(id: weather.iconId)
            self.tempText = (round(weather.temp * 10) / 10).description
            self.maxTempText = (round(weather.maxTemp * 10) / 10).description
            self.minTempText = (round(weather.minTemp * 10) / 10).description
            completion(true)
        })
    }
}
