//
//  APIController.swift
//  owlr
//
//  Created by Student on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import Foundation
import SwifteriOS

class APIController  {
    
    let swifter = Swifter(consumerKey: "tkbaXySRl6Fd8XictSd9S9vlr", consumerSecret: "2M87groo1SJlNAQti2JLdToZiD6IGUQce5ykOk50UIkyz8gxKC")
    
    
    init(){
        
    }
    
    // Send twitter specs, get back images
    func loadImages(lat: Double, long: Double, radius: Double, count: Int) {
        var q = "filter:images"
        var geocode = "\(lat),\(long),\(radius)mi"
        swifter.getSearchTweetsWithQuery(q, geocode: geocode, lang: nil, locale: nil, resultType: nil, count: count, until: nil, sinceID: nil, maxID: nil, includeEntities: nil, callback: nil, success: { (statuses, searchMetadata) -> Void in
            println(statuses)
        }) { (error) -> Void in
            println(error)
        }
    }
    

}