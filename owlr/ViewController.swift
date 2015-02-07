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
    @IBOutlet weak var searchButton: UIButton!

    var locationManager:CLLocationManager!
    var isImage1:Bool = false
    
    // vars for the swip func: ali did this
    var photoQueue : [Photo] = []
    var hold : [Photo] = []
    var currentImage : Photo?
    
    var currentLocation : CLLocation?
    
    @IBOutlet var edgeRight: UIScreenEdgePanGestureRecognizer!
    let apiController = APIController()

    
    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    

    @IBAction func swipeRightAction(sender: AnyObject) {
        
    }
    @IBAction func swipeRightPan(sender: AnyObject) {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        currentImage = nil
        currentLocation = CLLocation(latitude: 37.331789, longitude: -122.029620)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter  = 10.0
        locationManager.requestAlwaysAuthorization()
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
        self.currentLocation = location
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
                swipe()
                var photo = currentImage?.photo
                swap( photo )
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
    
    func swap( nextImage: UIImage?){
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
        var newStatuses = cleanJSON(statuses!)
        var downloaded = 0
        var newPhotos : [Photo] = []
        for status in newStatuses{
            var url = status["entities"]?["media"][0]["media_url"]
            var urlString = url!.string
            if(urlString != nil){
                ImageLoader.sharedLoader.imageForUrl(urlString!, completionHandler:{(image: UIImage?, url: String) in
                    downloaded += 1
                    var photo = Photo(photo: image!, jsonData: status, url: urlString!)
                    //                photoQueue[imageDownCount] = photo
                    if self.photoQueue.count > 0{
                        self.photoQueue.insert(photo, atIndex: 1)
                    }
                    else{
                        self.photoQueue.append(photo)
                        
                    }
                    newPhotos.append(photo)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photosLoaded()
                    }
                    if statuses?.count == newPhotos.count {
                        //All Photos Downloaded
                        self.photoQueue = self.filterOutdated(newPhotos)
                        self.hold = self.filterOutdated(newPhotos)
                    }
                    
                    
                })
            }

            
            
            
        }
        
        
    }
    

    
    func filterOutdated(newPhotos : [Photo]) -> [Photo]{
        var newPhotoList : [Photo] = self.photoQueue.filter
            { (photo) -> Bool in
                for p in newPhotos{
                    if p.url! == photo.url!{
                        return true
                    }
                }
                var first = self.photoQueue[0] as Photo
                return false || (first.url! == photo.url!)
            }

        return newPhotoList
        
    }
    
    func photosLoaded(){
        if currentImage == nil && photoQueue.count != 0{
            currentImage = photoQueue[0]
            self.imageView.image = currentImage?.photo
        }
    }
    
    // moves current image to a backup array, and then sets the first element in array of photoqueue to the current image
    func swipe(){
        if !photoQueue.isEmpty  {  // if photoqueue isnt empty
            hold.append(photoQueue[0]) // first element in photoqueue is added to the hold array
            photoQueue.removeAtIndex(0) // removes the first element in photoqueue
            if photoQueue.isEmpty{
                dispatch_async(dispatch_get_main_queue()) {
                    var long = self.currentLocation?.coordinate.longitude
                    var lat = self.currentLocation?.coordinate.latitude
                        self.apiController.loadImages(lat!, long: long!,radius: 0.1,count: 25)
                    
                }
                
            }else{
                currentImage = photoQueue[0] // current image pointer is set equal to the first element in photoqueue array
                imageView.image = currentImage?.photo
            }

            
        }
        else
        {
            photoQueue = hold // since photoqueu should be empty, then the backup hold array will be replaced for photoqueue
            hold = []
        }
        
    }
    
    
    func cleanJSON(statuses: [JSONValue]) -> [[String : JSONValue]]{
        var newStatuses = [[String : JSONValue]]()
        let fields = ["text","entities"]
        for (index, status) in enumerate(statuses){
            
            var cleanJson = [String : JSONValue]()
            for field in fields{

               
                cleanJson[field] = status[field]
                
            }
            newStatuses.append(cleanJson)
            

        }
        return newStatuses
    }
    

    // moves current image to a backup array, and then sets the first element in array of photoqueue to the current image

    
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

