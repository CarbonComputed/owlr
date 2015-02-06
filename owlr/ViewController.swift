//
//  ViewController.swift
//  owlr
//
//  Created by Kevin Carbone on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone Natasha Martinez Ali Batayneh. All rights reserved.
//

import UIKit
import CoreLocation
import SwifteriOS

<<<<<<< Updated upstream
class ViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
=======


class ViewController: UIViewController,APIControllerProtocol,CLLocationManagerDelegate {
    @IBOutlet weak var imageView1: UIImageView!

>>>>>>> Stashed changes
    @IBOutlet weak var textView: UITextView!
    var locationManager:CLLocationManager!
    var isImage1:Bool = false
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
        
        // Swipe left
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
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
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                swap()
            default:
                break
            }
        }
    }
    
<<<<<<< Updated upstream
    func swap(){
        let toImage = UIImage(named:"checkers.png")
        UIView.transitionWithView(self.imageView,
            duration:2,
            options: .TransitionCrossDissolve,
            animations: { self.imageView.image = toImage },
            completion: nil)
=======
    func didReceiveAPIResults(statuses: [JSONValue]?){
        println(statuses)
>>>>>>> Stashed changes
    }

    func photosDidLoad(statuses: [JSONValue]?){
        
    }
    
    func updateText(caption: NSString ){
        textView.text = caption
    }
    
    func loadNewImage(nextImage: UIImage){
        imageView.image = nextImage
    }
    
}

