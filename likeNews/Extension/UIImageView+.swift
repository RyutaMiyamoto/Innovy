//
//  UIImageView+.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/10/31.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView {
    
    /// URLから読み出した画像をふわっと表示する
    ///
    /// - Parameters:
    ///   - url: 画像URL
    ///   - placeholderImage: プレースホルダ画像
    func setImageSmoothly(url: URL, placeholderImage: UIImage?) {
        sd_setImage(with: url, placeholderImage: placeholderImage) { [weak self] image, error, cacheType, imageUrl in
            guard let `self` = self else { return }
            if error != nil { return }
            if image != nil && cacheType == .none {
                self.fadeIn(speed: .slow, completed: {})
            }
        }
    }
}
