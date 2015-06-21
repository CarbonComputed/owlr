//
//  ImageDownloader.swift
//  owlr
//
//  Created by Kevin Carbone on 6/20/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import UIKit

class ImageDownloader: NSOperation {
    let photo: Photo
    
    //2
    init(photo: Photo) {
        self.photo = photo
    }
    
    //3
    override func main() {
        //4
        if self.cancelled {
            return
        }
        //5
        let imageData = NSData(contentsOfURL:self.photo.url)
        
        //6
        if self.cancelled {
            return
        }
        
        //7
        if imageData?.length > 0 {
            self.photo.image = UIImage(data:imageData!)
            self.photo.state = .Downloaded
        }
        else
        {
            self.photo.state = .Failed
            self.photo.image = UIImage(named: "Failed")
        }
    }
}
