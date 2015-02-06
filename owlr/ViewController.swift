//
//  ViewController.swift
//  owlr
//
//  Created by Kevin Carbone on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//

import UIKit
import CoreLocation
import SwifteriOS

class ViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var imageView1: UIImageView!

    @IBOutlet weak var textView: UITextView!
    var locationManager:CLLocationManager!
    let apiController = APIController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter  = 10.0
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            println(".NotDetermined")
            break
            
        case .Authorized:
            println(".Authorized")
            locationManager.startUpdatingLocation()
            break
            
        case .Denied:
            println(".Denied")
            break
            
        default:
            println("Unhandled authorization status")
            break
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as CLLocation
        apiController.loadImages(location.coordinate.latitude,long: location.coordinate.longitude,radius: 0.1,count: 25)
        println("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        println("locations = \(locations)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Checks is update location should be called (30 min have passed)
    func timerGPS(){
        
    }
    
    func photosDidLoad(statuses: [JSONValue]?){
        
    }
    
    func swipe(){
        
    }
    
    func updateText(caption: NSString ){
        textView.text = caption
    }
    
    func loadNewImage(nextImage: UIImage){
        imageView1.image = nextImage
    }
    
}

