//
//  UIApplication+.swift
//  likeNews
//
//  Created by R.miyamoto on 2022/08/09.
//  Copyright © 2022 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    /// rootViewControllerを取得する
    ///
    /// - Returns: rootViewController
    class func rootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else { return nil }
        guard let rootViewController = window.rootViewController else { return nil }
        return rootViewController
    }
}
