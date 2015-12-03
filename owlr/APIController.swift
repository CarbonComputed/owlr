//
//  APIController.swift
//  owlr
//
//  Created by Student on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone Natasha Martinez Ali Batayneh. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

protocol APIControllerProtocol {
    func setMaxID(id : String)
    func loadPhoto(photo: Photo)
    func apiError()
}

class APIController  {
    var delegate: APIControllerProtocol?
    var photoDictionary = Set<String>()
    lazy var apiCallsInProgress = [String:SearchOperation]()

    lazy var apiCallQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "API Call Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var downloadsInProgress = [String:ImageDownloader]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Image Download Queue"
        return queue
    }()

    init(){
    }
    
    
    
    func loadAPIRequest(lat: Double, long: Double, radius: Double, count: Int, maxId: String?){

        let searchOp = TwitterSearchOp(lat: lat, long: long, radius: radius, count: count, maxId: maxId)
        if apiCallsInProgress[searchOp.toString()] != nil {
            return
        }
        
        
        searchOp.completionBlock = {
            if searchOp.cancelled {
                return
            }
            print("API Call Completed")
            self.apiCallsInProgress.removeValueForKey(searchOp.toString())

            if searchOp.photos.count > 0{
                if !searchOp.cancelled{
                    self.delegate?.setMaxID(searchOp.photos[searchOp.photos.count-1].id)
                }
            }
            if !searchOp.cancelled{
                self.retrieveImages(searchOp.photos)
            }

        }
        print("API Call Added")
        self.apiCallsInProgress[searchOp.toString()] = searchOp
        self.apiCallQueue.addOperation(searchOp)
    }

    func startDownloadForRecord(photo: Photo){
        if let _ = downloadsInProgress[photo.url.absoluteString] {
            return
        }
        
        let downloader = ImageDownloader(photo: photo)
        downloader.completionBlock = {
            if downloader.cancelled {
                return
            }
            self.downloadsInProgress.removeValueForKey(photo.url.absoluteString)
            self.photoDictionary.insert(photo.url.absoluteString)
            if !downloader.cancelled{
                self.delegate?.loadPhoto(photo)

            }
        }
        self.downloadsInProgress[photo.url.absoluteString] = downloader

        self.downloadQueue.addOperation(downloader)
    }
    
    func retrieveImages(photos : [Photo]){
        for photo in photos{
            if !self.photoDictionary.contains(photo.url.absoluteString){
                self.startDownloadForRecord(photo)
            }
        }
        if photos.count <= 0{
            self.delegate?.apiError()
        }
    }
    
    func cancelAllRequests(){
        self.apiCallQueue.cancelAllOperations()
        self.downloadQueue.cancelAllOperations()
        self.downloadsInProgress.removeAll(keepCapacity: true)
        self.apiCallsInProgress.removeAll(keepCapacity: true)
    }
    

}