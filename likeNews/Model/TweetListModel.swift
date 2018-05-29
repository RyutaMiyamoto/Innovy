//
//  TweetListModel.swift
//  likeNews
//
//  Created by Ryuta Miyamoto on 2017/12/06.
//  Copyright © 2017年 R.Miyamoto. All rights reserved.
//

import Foundation
import Alamofire
import Realm
import SDWebImage
import TwitterKit

class TweetListModel {
    /// shared
    static let shared = TweetListModel()
    /// 取り出し最大件数
    private let numReadMax = 100

    ///
    /// - Parameters:
    ///   - word: ワード
    ///   - completion: ツイートリスト
    func tweetList(word: String = "", completion: @escaping ([TWTRTweet])->Void) {
        let client = TWTRAPIClient()
        
        let url = Bundle.Api(key: .twitterHost) + "/" + Bundle.Api(key: .twitterHostVersion) + "/search/tweets.json"
        let params = ["q": word, "count": numReadMax.description]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: url, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil { completion([]) }
            do {
                guard let data = data else { return }
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                if let statuses = json["statuses"] as? NSArray {
                    let tweetList = TWTRTweet.tweets(withJSONArray: statuses as [AnyObject]) as! [TWTRTweet]
                    completion(tweetList)
                }
            } catch _ as NSError {
                completion([])
            }
        }
    }
}
