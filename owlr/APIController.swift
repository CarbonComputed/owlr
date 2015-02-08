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
import OAuthSwift

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
    
    func doOAuthInstagram(){
        let oauthswift = OAuth2Swift(
            consumerKey:    "6e37389055434819af596615c633b78a",
            consumerSecret: "d0e3198127cd4f53b8075aa416a69aad",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/instagram")!, scope: "likes+comments", state:"INSTAGRAM", success: {
            credential, response in
            println("Instagram", message: "oauth_token:\(credential.oauth_token)")
            let url :String = "https://api.instagram.com/v1/users/1574083/?access_token=\(credential.oauth_token)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                    println(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    println(error)
            })
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
        })
    }
    
    // Send twitter specs, get back images
    func loadImages(lat: Double, long: Double, radius: Double, count: Int, maxId: String?) {
        if self.view?.loader != nil{
            self.view?.loader.startAnimating()
        }
        var q = "filter:images"
        var geocode = "\(lat),\(long),\(radius)mi"
        swifter.getSearchTweetsWithQuery(q, geocode: geocode, lang: nil, locale: nil, resultType: "recent", count: count, until: nil, sinceID: nil, maxID: maxId, includeEntities: nil, callback: nil, success: { (statuses: [JSONValue]?, searchMetadata) -> Void in
            if self.view?.loader != nil{
                self.view?.loader.stopAnimating()
            }
              dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.didReceiveAPIResults(statuses)
                    println("Success")
                }

//              println("Success")
            
        }) { (error) -> Void in
            if self.view?.loader != nil{
                self.view?.loader.stopAnimating()
            }
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