//
//  APIController.swift
//  owlr
//
//  Created by Student on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone Natasha Martinez Ali Batayneh. All rights reserved.
//

import Foundation
import SwifteriOS
import UIKit

protocol APIControllerProtocol {
    func didReceiveAPIResults(statuses: [JSONValue]?)
}

class APIController  {
    var delegate: APIControllerProtocol?
    
    var view : ViewController?
    
    let swifter = Swifter(consumerKey: "tkbaXySRl6Fd8XictSd9S9vlr", consumerSecret: "2M87groo1SJlNAQti2JLdToZiD6IGUQce5ykOk50UIkyz8gxKC")
    
    init(){
    }
    init(view : ViewController){
        self.view = view
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
                let alertController = UIAlertController(title: "Uh-Oh", message:
                    "I think we hit twitters rate limit...", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.view?.presentViewController(alertController, animated: true, completion: nil)
                println(error)
            }
        }
    }
    

}