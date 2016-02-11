//
//  ViewController.swift
//  owlr
//
//  Created by Kevin Carbone on 2/5/15.
//  Copyright (c) 2015 Kevin Carbone Natasha Martinez Ali Batayneh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol LocationChangeProtocol{
    func didUpdateLocation(location : CLLocation, radius : Double)
}

class ViewController: UIViewController, CLLocationManagerDelegate, LocationChangeProtocol, APIControllerProtocol {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var locationManager:CLLocationManager!
    
    var locationDelegate : LocationChangeProtocol?
    
    // vars for the swip func: ali did this
    var photoQueue : [Photo] = []
    var currentIndex = -1
    
    var currentLocation : CLLocation?
    var currentRadius : Double = 50


    var apiController : APIController?
    
    var currentMax : String?
    var waitingForNext : Bool = true
    
    var defaultImage : UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.apiController = APIController()
        self.apiController?.delegate = self
        if(currentLocation==nil){
            currentLocation = CLLocation(latitude: 37.331789, longitude: -122.029620)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultImage = self.imageView.image
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter  = 10.0
        locationManager.requestAlwaysAuthorization()
    }

    func loadPhoto(photo: Photo) {
        self.photoQueue.append(photo)
        if self.waitingForNext {
            self.waitingForNext = false
            self.currentIndex += 1
            self.refreshPhotos()
        }
        
        if apiController?.downloadsInProgress.count == 0 && apiController?.apiCallsInProgress.count == 0{
            self.loader.stopAnimating()
        }
    }
    
    func apiError() {
        if apiController?.downloadsInProgress.count == 0 && apiController?.apiCallsInProgress.count == 0{
            self.loader.stopAnimating()
        }
    }
    
    func refreshPhotos() {
        if photoQueue.count == 0{
            self.imageView.image = self.defaultImage
            self.textView.text = ""
        }
        else if currentIndex < photoQueue.count{
            dispatch_async(dispatch_get_main_queue()) {
                UIView.transitionWithView( self.imageView,
                                           duration:0.6,
                                           options: .TransitionCrossDissolve,
                                           animations: { self.imageView.image = self.photoQueue[self.currentIndex].image},
                                           completion: { (Bool) in
                                                self.textView.text = self.photoQueue[self.currentIndex].text
                                                self.textView.textColor = UIColor.whiteColor()
                                           }
                )
            }
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        
        switch status {
            case .NotDetermined:
                print(".NotDetermined")
                break
                
            case .AuthorizedAlways:
                print("Location Authorized")
                if ( oauthswiftTwitter.client.credential.oauth_token.characters.count <= 0 ) {
                    
                    oauthswiftTwitter.authorizeWithCallbackURL(
                        NSURL(string: "oauth-swift://oauth-callback/twitter")!,
                        
                        success: { (credential, response) -> Void in
                            print(credential.oauth_token)
                            print(credential.oauth_token_secret)
                        
                        }, failure: { (error) -> Void in
                           print(error)
                    })
                }

                locationManager.startUpdatingLocation()
                break
                
            case .Denied:
                print(".Denied")
                break
                
            default:
                print("Unhandled authorization status")
                break
        }
    }
    
    func loadNewImages(){
        let long = self.currentLocation?.coordinate.longitude
        let lat = self.currentLocation?.coordinate.latitude
        self.loader.startAnimating()
        self.apiController!.loadAPIRequest(lat!, long: long!,radius: self.currentRadius ,count: 5, maxId : currentMax)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.didUpdateLocation(locations.last!, radius: self.currentRadius)
    }

    func didUpdateLocation(location : CLLocation, radius: Double){
        self.currentLocation = location
        self.currentRadius = radius
        print("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        self.apiController?.cancelAllRequests()
        self.currentMax = nil
        self.currentIndex = -1
        self.waitingForNext = true
        self.photoQueue = []
        self.refreshPhotos()
        self.loadNewImages()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swipedLeft(sender: UISwipeGestureRecognizer) {
        if self.currentIndex + 1 < self.photoQueue.count{
            self.currentIndex += 1
        }
        else{
            waitingForNext = true
        }
        if self.photoQueue.count - (self.currentIndex + 1) <= 5 && self.apiController?.apiCallsInProgress.count == 0{
            self.loadNewImages()
        }
        self.refreshPhotos()

    }
    

    @IBAction func swipedRight(sender: UISwipeGestureRecognizer) {
        if self.currentIndex - 1 >= 0{
            self.currentIndex -= 1
            self.refreshPhotos()
        }
    }
    
    func setMaxID(id : String){
        self.currentMax = id
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "SettingsSegue") {
            // pass data to next view
            let next = segue.destinationViewController as! SettingsViewController
            next.locationDelegate = self
            next.currentLocation = self.currentLocation
            next.radius = self.currentRadius
            
        }
        
    }

}
