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

class ViewController: UIViewController,APIControllerProtocol,CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!

    var locationManager:CLLocationManager!
    var isImage1:Bool = false
    
    @IBOutlet var edgeRight: UIScreenEdgePanGestureRecognizer!
    let apiController = APIController()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter  = 10.0
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        apiController.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        // Swipe left set up
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Edge left set up
        var edgeGesture : UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action:"respondToSwipeGesture:")
        edgeGesture.edges = UIRectEdge.Left
        self.view.addGestureRecognizer(edgeGesture)
        
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
        dispatch_async(dispatch_get_main_queue()) {
            self.apiController.loadImages(location.coordinate.latitude,long: location.coordinate.longitude,radius: 0.1,count: 25)
            println("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
        }

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
                swap( UIImage(named:"checkers.png")! )
            default:
                break
            }
        }
        
        else if let swipeGesture = gesture as? UIScreenEdgePanGestureRecognizer {
            switch swipeGesture.edges {
            case UIRectEdge.Left:
                showSearch()
            default:
                break
            }
        }
    }
    
    func swap( nextImage: UIImage){
        let toImage = nextImage
        UIView.transitionWithView(self.imageView,
            duration:0.6,
            options: .TransitionCrossDissolve,
            animations: { self.imageView.image = toImage },
            completion: nil)
    }
    
    func showSearch()
    {
        
    }
    

    func didReceiveAPIResults(statuses: [JSONValue]?){
        for status in statuses!{
            println(status["text"])
        }
    }
    
    func updateText(caption: NSString ){
        textView.text = caption
    }
    
    func loadNewImage(nextImage: UIImage){
        imageView.image = nextImage
    }
    
    @IBAction func circleTapped(sender:UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
}

