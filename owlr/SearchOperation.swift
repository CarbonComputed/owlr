//
//  SearchOperation.swift
//  owlr
//
//  Created by Kevin Carbone on 6/20/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import UIKit
import OAuthSwift

class SearchOperation: NSOperation {
    let baseURL : String
    let params : Dictionary<String,AnyObject>
    let oauthswift : OAuth1Swift
    
    var photos : [Photo] = []

    var ex : Bool = true
    var fin: Bool = false
    
    
    init(oauthswift : OAuth1Swift, baseURL : String, params : Dictionary<String,AnyObject>) {
        self.baseURL = baseURL
        self.params = params
        self.oauthswift = oauthswift
    }
    override func start(){
        if self.cancelled {
            return
        }
        if !NSThread.isMainThread(){
            dispatch_async(dispatch_get_main_queue(), {
                self.start()
            })
            return
        }
        self.willChangeValueForKey("isExecuting")
        self.willChangeValueForKey("isFinished")
        self.ex = true
        self.fin = false
        self.didChangeValueForKey("isFinished")
        self.didChangeValueForKey("isExecuting")


        oauthswift.client.get(baseURL, parameters: params,
            success: {
                data, response in
                
                var parsingError: NSError?
                if let json = JSON(data : data) as JSON?{
                    self.handleJSON(json)
                    self.willChangeValueForKey("isExecuting")
                    self.willChangeValueForKey("isFinished")
                    self.ex = false
                    self.fin = true
                    self.didChangeValueForKey("isFinished")
                    self.didChangeValueForKey("isExecuting")
//                    self.completionBlock!()

                }
                else{
                    println("An error occured parsing JSON")
                }
            }, failure: {(error:NSError!) -> Void in
                println(error)
                self.willChangeValueForKey("isExecuting")
                self.willChangeValueForKey("isFinished")
                self.ex = false
                self.fin = true
                self.didChangeValueForKey("isFinished")
                self.didChangeValueForKey("isExecuting")
//                self.completionBlock!()
        })
    }
    

    override var asynchronous: Bool {
        return true
    }
    
    override var executing: Bool {
        return ex
    }
    
    override var finished: Bool {
        return fin
    }
    
    
    func toString() -> String{
        return self.baseURL + " " + self.params.description
    }
    
    func handleJSON(json : JSON){
        println("Abstract, should be overrwritten by provider")

    }

}
