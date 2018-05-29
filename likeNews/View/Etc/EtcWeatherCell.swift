//
//  EtcWeatherCell.swift
//  likeNews
//
//  Created by R.miyamoto on 2018/04/30.
//  Copyright © 2018年 R.Miyamoto. All rights reserved.
//

import UIKit
import CoreLocation

protocol EtcWeatherCellDelegate: class {
    
    /// 天気情報更新完了
    ///
    /// - Parameters:
    ///   - cell: 呼び出し元
    ///   - result: 取得結果
    func updateFinished(cell: EtcWeatherCell, result: Bool)
    
    /// 位置情報使用許可アラートを表示する
    ///
    /// - Parameter cell: 呼び出し元
    func showAlertAuthorizationLocation(cell: EtcWeatherCell)
}

class EtcWeatherCell: UITableViewCell, CLLocationManagerDelegate {

    weak var delegate: EtcWeatherCellDelegate?

    /// 日付ラベル
    @IBOutlet weak var dateLabel: UILabel!
    /// 地域名ラベル
    @IBOutlet weak var cityNameLabel: UILabel!
    /// 天気アイコン画像
    @IBOutlet weak var iconImageView: UIImageView!
    /// 現在気温ラベル
    @IBOutlet weak var tempLabel: UILabel!
    /// 最高気温ラベル
    @IBOutlet weak var maxTempLabel: UILabel!
    /// 最低気温ラベル
    @IBOutlet weak var minTempLabel: UILabel!
    
    /// ロケーション
    let locationManager = CLLocationManager()

    var viewModel: EtcWeatherCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            dateLabel.text = viewModel.dateText
            cityNameLabel.text = viewModel.cityNameText
            iconImageView.image = viewModel.iconImage
            tempLabel.text = viewModel.tempText
            maxTempLabel.text = viewModel.maxTempText
            minTempLabel.text = viewModel.minTempText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        locationManager.delegate = self
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            // 起動時のみ、位置情報の取得が許可
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 天気情報更新
        update(location: location)
    }
    
    // MARK: - Private Method
    
    /// 天気情報を更新する（外部呼び出し用）
    func updateWeather() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // まだユーザに許可を求めていない。
            locationManager.requestWhenInUseAuthorization()
            update()
        case .denied, .restricted:
            if CLLocationManager.locationServicesEnabled() {
                // 位置情報サービスはオンにしているが、自分のアプリには許可していない。
                delegate?.showAlertAuthorizationLocation(cell: self)
            }
            update()
        default: break
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    /// 天気情報を更新する（デフォルト位置は東京）
    ///
    /// - Parameter location: ロケーショ
    private func update(location: CLLocation = CLLocation(latitude: 35.709026, longitude: 139.731993)) {
        // 天気情報更新
        guard let viewModel = viewModel else { return }
        viewModel.update(location: location, completion: { result in
            self.viewModel = viewModel
            self.locationManager.stopUpdatingLocation()
            self.delegate?.updateFinished(cell: self, result: result)
        })
    }
}
