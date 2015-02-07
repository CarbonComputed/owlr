//
//  Photo.swift
//  owlr
//
//  Created by Kevin Carbone on 2/6/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import Foundation
import UIKit
import SwifteriOS

class Photo {

    var photo : UIImage?
    var jsonData : [String : JSONValue]

    init(photo : UIImage, jsonData : [String : JSONValue]){
        self.photo = photo
        self.jsonData = jsonData
    }


}
