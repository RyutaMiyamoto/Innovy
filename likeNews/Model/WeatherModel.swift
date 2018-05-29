//
//  WeatherModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2018/04/28.
//  Copyright © 2018年 R.Miyamoto. All rights reserved.
//

import Foundation
import Alamofire
import Unbox
import CoreLocation

/// 天気情報
struct Weather {
    /// 地域名
    var cityName = ""
    /// 天気アイコンID
    var iconId = ""
    /// 現在気温
    var temp: Float = 0
    /// 最高気温
    var maxTemp: Float = 0
    /// 最低気温
    var minTemp: Float = 0
    /// 取得日時
    var date = Date(timeIntervalSince1970: 0)
}

/// 住所
struct Address {
    /// 都道府県
    var prefecture = ""
    /// 市区町村
    var city = ""
    /// 市区町村（かな）
    var cityKana = ""
    /// 町・地域
    var town = ""
    /// 町・地域（かな）
    var townKana = ""
    /// ロケーション
    var location = CLLocation(latitude: 0, longitude: 0)
    /// 指定位置からの距離
    var distance: Double = 0
}

extension Weather: Unboxable {
    init(unboxer: Unboxer) throws {
        self.iconId = try unboxer.unbox(keyPath: "weather.0.icon")
        self.temp = try unboxer.unbox(keyPath: "main.temp") - 273.15
        self.maxTemp = try unboxer.unbox(keyPath: "main.temp_max") - 273.15
        self.minTemp = try unboxer.unbox(keyPath: "main.temp_min") - 273.15
        self.date = try Date(timeIntervalSince1970: unboxer.unbox(key: "dt"))
    }
}

extension Address: Unboxable {
    init(unboxer: Unboxer) throws {
        self.prefecture = try unboxer.unbox(keyPath: "response.location.0.prefecture")
        self.city = try unboxer.unbox(keyPath: "response.location.0.city")
        self.cityKana = try unboxer.unbox(keyPath: "response.location.0.city_kana")
        self.town = try unboxer.unbox(keyPath: "response.location.0.town")
        self.townKana = try unboxer.unbox(keyPath: "response.location.0.town_kana")
        self.location = try CLLocation(latitude: unboxer.unbox(keyPath: "response.location.0.y"),
                                       longitude: unboxer.unbox(keyPath: "response.location.0.x"))
        self.distance = try unboxer.unbox(keyPath: "response.location.0.distance")
    }
}

class WeatherModel {
    /// shared
    static let shared = WeatherModel()
    
    /// 天気アイコン
    enum WeatherIcon: String {
        /// 快晴（日中）
        case clearSkyDay = "01d"
        /// 晴れ（日中）
        case fewCloudsDay = "02d"
        /// くもり（日中）
        case scatteredCloudsDay = "03d"
        /// くもり（日中）
        case brokenCloudsDay = "04d"
        /// 小雨（日中）
        case showerRainDay = "09d"
        /// 雨（日中）
        case rainDay = "10d"
        /// 雷雨（日中）
        case thunderstormDay = "11d"
        /// 雪（日中）
        case snowDay = "13d"
        /// 霧（日中）
        case mistDay = "50d"
        /// 快晴（夜間）
        case clearSkyNight = "01n"
        /// 晴れ（夜間）
        case fewCloudsNight = "02n"
        /// くもり（夜間）
        case scatteredCloudsNight = "03n"
        /// くもり（夜間）
        case brokenCloudsNight = "04n"
        /// 小雨（夜間）
        case showerRainNight = "09n"
        /// 雨（夜間）
        case rainNight = "10n"
        /// 雷雨（夜間）
        case thunderstormNight = "11n"
        /// 雪（夜間）
        case snowNight = "13n"
        /// 霧（夜間）
        case mistNight = "50n"
        
        /// アイコン画像
        var image: UIImage? {
            switch self {
            case .clearSkyDay: return R.image.weatherClearSkyDay()
            case .fewCloudsDay: return R.image.weatherFewCloudsDay()
            case .scatteredCloudsDay: return R.image.weatherScatteredCloudsDay()
            case .brokenCloudsDay: return R.image.weatherBrokenCloudsDay()
            case .showerRainDay: return R.image.weatherShowerRainDay()
            case .rainDay: return R.image.weatherRainDay()
            case .thunderstormDay: return R.image.weatherThunderstormDay()
            case .snowDay: return R.image.weatherSnowDay()
            case .mistDay: return R.image.weatherMistDay()
            case .clearSkyNight: return R.image.weatherClearSkyNight()
            case .fewCloudsNight: return R.image.weatherFewCloudsNight()
            case .scatteredCloudsNight: return R.image.weatherScatteredCloudsNight()
            case .brokenCloudsNight: return R.image.weatherBrokenCloudsNight()
            case .showerRainNight: return R.image.weatherShowerRainNight()
            case .rainNight: return R.image.weatherRainNight()
            case .thunderstormNight: return R.image.weatherThunderstormNight()
            case .snowNight: return R.image.weatherSnowNight()
            case .mistNight: return R.image.weatherMistNight()
            }
        }
    }
    
    /// ロケーションで指定された地域の天気情報を取得する
    ///
    /// - Parameters:
    ///   - location: ロケーション
    ///   - completion: 天気情報
    func weather(location: CLLocation, completion: @escaping (Weather?)->Void) {
        
        let url = Bundle.Api(key: .weatherHost) + "/data/2.5/weather"
        let params = ["appid": Bundle.Api(key: .weatherApiKey),
                      "lat": location.coordinate.latitude.description, "lon": location.coordinate.longitude.description]
        
        Alamofire.request(url, parameters: params).responseData { response in
            guard let responce = response.result.value else {
                completion(nil)
                return
            }
            var weather = self.parseJsonWeather(at: responce)
            WeatherModel.shared.address(location: location, completion: { address in
                if let address = address {
                    weather.cityName = address.city + address.town
                    completion(weather)
                }
            })
        }
    }
    
    /// ロケーションで指定された地域の住所情報を取得する
    ///
    /// - Parameters:
    ///   - location: ロケーション
    ///   - completion: 住所
    func address(location: CLLocation, completion: @escaping (Address?)->Void) {
        
        let url = Bundle.Api(key: .locationHost) + "/api/json"
        let params = ["method": "searchByGeoLocation",
                      "x": location.coordinate.longitude.description, "y": location.coordinate.latitude.description]
        
        Alamofire.request(url, parameters: params).responseData { response in
            guard let responce = response.result.value else {
                completion(nil)
                return
            }
            let address = self.parseJsonAddress(at: responce)
            completion(address)
        }
    }
    
    /// 天気JSONをパースする
    ///
    /// - Parameter json: JSON
    /// - Returns: パースしたJSON
    func parseJsonWeather(at json: Data) -> Weather {
        var weather = Weather()
        do {
            weather = try unbox(data: json)
            return weather
        } catch {
        }
        return weather
    }
    
    /// 住所JSONをパースする
    ///
    /// - Parameter json: JSON
    /// - Returns: パースしたJSON
    func parseJsonAddress(at json: Data) -> Address {
        var address = Address()
        do {
            address = try unbox(data: json)
            return address
        } catch {
        }
        return address
    }
    
    /// アイコンIDに該当するアイコン画像を取得する
    ///
    /// - Parameter id: アイコンID
    /// - Returns: アイコン画像
    func iconImage(id: String) -> UIImage? {
        guard let weatherIcon = WeatherIcon(rawValue: id) else { return UIImage() }
        return weatherIcon.image
    }
}

