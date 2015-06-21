//
//  Photo.swift
//  owlr
//
//  Created by Kevin Carbone on 2/6/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import Foundation
import UIKit

enum PhotoState {
    case New, Downloaded, Failed
}
class Photo {

    var image : UIImage?
    var url : NSURL
    var id : String
    var text : String?
    var state = PhotoState.New

    init(id : String, url: NSURL, text: String?){
        self.id = id
        self.image = nil
        self.url = url
        self.text = text
    }


}
