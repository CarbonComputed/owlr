//
//  APIController.swift
//  owlr
//
//  Created by Student on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone Natasha Martinez Ali Batayneh. All rights reserved.
//

import Foundation
import SwifteriOS

protocol APIControllerProtocol {
    func didReceiveAPIResults(statuses: [JSONValue]?)
}

class APIController  {
    var delegate: APIControllerProtocol?
    
    let swifter = Swifter(consumerKey: "tkbaXySRl6Fd8XictSd9S9vlr", consumerSecret: "2M87groo1SJlNAQti2JLdToZiD6IGUQce5ykOk50UIkyz8gxKC")
    
    
    init(){
        
    }
    
    // Send twitter specs, get back images
    func loadImages(lat: Double, long: Double, radius: Double, count: Int, maxId: String?) {
        var q = "filter:images"
        var geocode = "\(lat),\(long),\(radius)mi"
        swifter.getSearchTweetsWithQuery(q, geocode: geocode, lang: nil, locale: nil, resultType: "recent", count: count, until: nil, sinceID: nil, maxID: maxId, includeEntities: nil, callback: nil, success: { (statuses: [JSONValue]?, searchMetadata) -> Void in
              dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.didReceiveAPIResults(statuses)
                    println("Success")
                }

//              println("Success")
            
        }) { (error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.didReceiveAPIResults([])
                println(error)
            }
        }
    }
    

}