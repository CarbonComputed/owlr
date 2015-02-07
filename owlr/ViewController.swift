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
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var searchHashtags: UITextField!
    @IBOutlet weak var radiusSlider: UISlider!
    
    var locationManager:CLLocationManager!
    var isImage1:Bool = false
    
    // vars for the swip func: ali did this
    var photoQueue : [Photo] = []
    var hold : [Photo] = []
    var currentImage : Photo?
    var photoDictionary = [String: Bool]()
    var radius : Double = 1
    var defaultRadius : Double = 1
    let maxRetry : Int = 5
    var currRetry : Int = 0
    
    var currentLocation : CLLocation?
    var currentState : State = State.Chilling
    
    enum State{
        case Downloading
        case Chilling
    }
    
    @IBAction func updateRadiusLabel(sender: AnyObject) {
        let radiusNum = Int(radiusSlider.value)
        radiusLabel.text = "\(radiusNum)"
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        radius = Double(radiusSlider.value)
    }
    
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
        self.radius = self.defaultRadius
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
        if currentState != State.Downloading{
            dispatch_async(dispatch_get_main_queue()) {
                self.currentState = State.Downloading
                self.apiController.loadImages(location.coordinate.latitude,long: location.coordinate.longitude,radius: self.radius,count: 5, maxId: nil)
                println("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")
                
            }
        }
        locationManager.stopUpdatingLocation()
        
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
                var photo = currentImage
                if photo != nil{
                    swap( photo! )

                }
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
    
    func swap( nextImage: Photo){
        if self.imageView != nil{
            let toImage = nextImage.photo
            UIView.transitionWithView(self.imageView,
                duration:0.6,
                options: .TransitionCrossDissolve,
                animations: { self.imageView.image = toImage },
                completion: nil)
            updateText(nextImage.text!)
        }
    }
    
    func showSearch()
    {
        
    }
    
    
    func didReceiveAPIResults(statuses: [JSONValue]?){
        var newStatuses = cleanJSON(statuses!)
        var downloaded = 0
        var newPhotos : [Photo] = []
        
        println("NEW \(newStatuses.count)")
        if(newStatuses.isEmpty){
            self.noPhotosLoaded()
        }
        var downloading = 0
        var failed = 0
        for status in newStatuses{
            var url = status["entities"]?["media"][0]["media_url"]
            var urlString = url!.string
            var id = status["id_str"]
            var idString = id!.string
            if(urlString != nil  && idString != nil && photoDictionary[urlString!] == nil ){
                downloading += 1
                self.radius = self.defaultRadius
                ImageLoader.sharedLoader.imageForUrl(urlString!, completionHandler:{(image: UIImage?, url: String) in
                    self.currRetry = 0
                    var photo = Photo(id : idString!, photo: image!, jsonData: status, url: urlString!)
                    newPhotos.append(photo)
                    self.photoLoaded(photo)
                    if downloading == newPhotos.count {
                        self.allPhotosLoaded(newPhotos)
                        
                    }
                    
                    
                })
            }
            else{
                failed += 1
                if failed == newStatuses.count && self.currRetry < self.maxRetry{
                    //increase radius
                    self.radius *= 2
                    self.noPhotosLoaded()
                }
                if self.currRetry >= self.maxRetry{
                    self.radius = self.defaultRadius
                    self.photoDictionary.removeAll(keepCapacity: true)
                    self.noPhotosLoaded()
                }
            }
            
            
            
            
        }
        
        
    }
    
    
    func filterDups(photos: [Photo]) -> [Photo]{
        var check = [String : Photo]()
        for (i,photo) in enumerate(photos){
            check[photo.url!] = photo
        }
        var newPhotoList : [Photo] = []
        for photo in self.photoQueue{
            var nphoto = check[photo.url!]
            if nphoto != nil{
                newPhotoList.append(nphoto!)
                check.removeValueForKey(photo.url!)
                
            }
        }
        return newPhotoList
        
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
    
    func noPhotosLoaded(){
        self.currRetry += 1
        dispatch_async(dispatch_get_main_queue()) {
            var long = self.currentLocation?.coordinate.longitude
            var lat = self.currentLocation?.coordinate.latitude
            self.currentState = State.Downloading
            self.apiController.loadImages(lat!, long: long!,radius: self.radius,count: 5, maxId : nil)
        }
    }
    
    func allPhotosLoaded(photos : [Photo]){
        self.photoQueue = self.filterDups(photos)
        self.currentImage = self.photoQueue[0]
    }
    
    func photoLoaded(photo : Photo){
        self.photoQueue.append(photo)
        if currentImage == nil && photoQueue.count > 0{
            currentImage = photoQueue[0]
            swap(currentImage!)
            
        }
        //        if currentImage == nil && photoDictionary[photoQueue[0].url!] != nil{
        //            swipe()
        //        }
        //        if self.currentState == State.Chilling && photoQueue.isEmpty{
        //            swipe()
        //        }
        //        if currentImage == nil && photoQueue.count != 0 && self.imageView != nil{
        //            currentImage = photoQueue[0]
        //            swap(currentImage?.photo)
        //        }
        
        
    }
    
    
    
    
    
    
    // checks if 75 % or more of urls are same
    func urlChecker(){
        
        var index : Int = 0
        var counter : Int = 0
        
        for index in 0...photoQueue.count-1 {  //for index in 0 through last index of photoque
            if photoDictionary.indexForKey(photoQueue[index].url!) != nil {     // check if the photos are same
                counter += 1
            }
        }
        
        
        if  Double(counter)/Double(photoQueue.count) >= 0.75   {
            
            var long = self.currentLocation?.coordinate.longitude
            var lat = self.currentLocation?.coordinate.latitude
            //                self.apiController.loadImages(lat!, long: long!,radius: radius+0.1,count: 25)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // moves current image to a backup array, and then sets the first element in array of photoqueue to the current image
    func swipe(){
        println("Count \(photoQueue.count)")
        println(currentImage?.url)
        if photoQueue.isEmpty{
            self.currentImage = nil
            self.noPhotosLoaded()
        }
        else{
            photoDictionary[photoQueue[0].url!] = true
            photoQueue.removeAtIndex(0)
            if photoQueue.isEmpty{
                self.currentImage = nil
                self.noPhotosLoaded()
            }
            else{
                println(photoQueue[0].url)
                self.currentImage = photoQueue[0]
            }
            
            
            if photoQueue.count <= 2 && self.currentImage != nil{//and not already downloading
                var maxId = currentImage?.id
                dispatch_async(dispatch_get_main_queue()) {
                    var long = self.currentLocation?.coordinate.longitude
                    var lat = self.currentLocation?.coordinate.latitude
                    self.currentState = State.Downloading
                    self.apiController.loadImages(lat!, long: long!,radius: self.radius,count: 5, maxId : maxId)
                }
            }
            
        }
        println("swiped")
    }
    
    
    func cleanJSON(statuses: [JSONValue]) -> [[String : JSONValue]]{
        var newStatuses = [[String : JSONValue]]()
        let fields = ["text","entities","id_str"]
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
        textView.textColor = UIColor.whiteColor()
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
