//
//  ActivityOpenSafari.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/08/20.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import UIKit

class ActivityOpenSafari: UIActivity {
    var url: URL!
    
    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "SafariOpen")
    }
    
    override var activityTitle: String? {
        return "Safariで開く"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "ArticleDetail-ShareOpenSafari")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        super.prepare(withActivityItems: activityItems)
    }
    
    override func perform() {
        self.activityDidFinish(true)
    }
    
    override func activityDidFinish(_ completed: Bool) {
        super.activityDidFinish(completed)
        
        // Safariで指定URLを開く
        if UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.openURL(url!)
        }
    }
}
