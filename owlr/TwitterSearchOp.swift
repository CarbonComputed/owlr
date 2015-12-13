//
//  TwitterSearchOp.swift
//  owlr
//
//  Created by Kevin Carbone on 6/20/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import UIKit
import SwiftyJSON

class TwitterSearchOp: SearchOperation {
    
    init(lat: Double, long: Double, radius: Double, count: Int, maxId: String?) {
        
        let oauthswift = oauthswiftTwitter
        let baseURL = "https://api.twitter.com/1.1/search/tweets.json"
        
        var geocode = ""
        geocode += String(format: "%.7f", lat)    + ","
        geocode += String(format: "%.7f", long)   + ","
        geocode += String(format: "%.2f", radius) + "mi"
        
        var params = Dictionary<String,AnyObject>()
        params["geocode"] = geocode
        params["result_type"] = "recent"
        params["q"] = "filter:images"
        params["count"] = count
        
        if (maxId != nil) {
            params["max_id"] = maxId
        }
        
        super.init(oauthswift: oauthswift, baseURL: baseURL, params: params)
    }
    
    override func handleJSON(json : JSON){
        
        let statuses = json["statuses"]
        statuses.forEach {key, status in
            
            if status["entities"]["media"] != nil {
                if let urlString = status["entities"]["media"][0]["media_url"].string! as String? {
             
                    let url = NSURL(string : urlString)
                    let id = status["id_str"].string!
                    var text = status["text"].string!
                    text = text.stringByReplacingOccurrencesOfString(" ?http://.*", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                    let photo = Photo(id: id, url: url!, text: text)
                    self.photos.append(photo)
                }
            }
        }
    }
}
