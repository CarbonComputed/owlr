//
//  Photo.swift
//  owlr
//
//  Created by Kevin Carbone on 2/6/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import Foundation
import UIKit

class Photo {
    
    var photo : UIImage?
    var jsonData : [String : AnyObject?]
    
    init(photo : UIImage, jsonData : [String : AnyObject?]){
        self.photo = photo
        self.jsonData = jsonData
    }
    
    
}