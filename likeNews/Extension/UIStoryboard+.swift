//
//  UIStoryboard+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    class func storyboardTransition(storyboardName: String, viewControllerName: String? = nil) -> UIViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let viewControllerName = viewControllerName {
            return storyboard.instantiateViewController(withIdentifier: viewControllerName)
        }
        return storyboard.instantiateInitialViewController()
    }
}
