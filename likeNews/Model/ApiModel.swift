//
//  ApiModel.swift
//  likeNews
//
//  Created by RyutaMiyamoto on 2019/12/30.
//  Copyright © 2019 R.Miyamoto. All rights reserved.
//

import Foundation
import Alamofire

class ApiModel {
    /// API実行
    /// - Parameters:
    ///   - url: URL
    ///   - method: method
    ///   - params: param
    ///   - completion: response
    func requestApi(url: String, method: HTTPMethod, params: Parameters?,
                    completion: @escaping (Data?)->Void) {
        let request = AF.request(url, method: method, parameters: params)
        request.validate().response(completionHandler: { response in
            switch response.result {
            case .success(let data):
                completion(data)
            case .failure( _):
                completion(nil)
            }
            return
        })
    }
}
