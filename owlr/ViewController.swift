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

    var currentLocation : CLLocation?
    var currentState : State?

    enum State{
        case DownloadingImages
        case Nothing
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
        currentState = State.Nothing
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
            self.apiController.loadImages(location.coordinate.latitude,long: location.coordinate.longitude,radius: 0.1,count: 50, maxId: nil)
            println("didUpdateLocations:  \(location.coordinate.latitude), \(location.coordinate.longitude)")

        }

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

        println("NEW \(newStatuses.count)")
        for status in newStatuses{
            var url = status["entities"]?["media"][0]["media_url"]
            var urlString = url!.string

            var id = status["id_str"]
            var idString = id!.string
            if(urlString != nil){
                currentState = State.DownloadingImages
                ImageLoader.sharedLoader.imageForUrl(urlString!, completionHandler:{(image: UIImage?, url: String) in
                    var photo = Photo(id : idString!, photo: image!, jsonData: status, url: urlString!)
                    newPhotos.append(photo)

                    self.photoQueue.append(photo)
                    self.photosLoaded()
                    if statuses?.count == newPhotos.count {
                        //All Photos Downloaded
                        self.currentState = State.Nothing
                        self.photoQueue = self.filterDups(newPhotos)
//                        self.hold = self.filterDups(self.filterOutdated(newPhotos))

                    }


                })
            }




        }


    }


    func filterDups(photos: [Photo]) -> [Photo]{
        var check = [String : Photo]()
        for (i,photo) in enumerate(photos){
            check[photo.url!] = photo
        }
        var newPhotoList : [Photo] = []
        for photo in check.values{
            newPhotoList.append(photo)
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

    func photosLoaded(){
        if currentImage == nil && photoQueue.count != 0 && self.imageView != nil{
            currentImage = photoQueue[0]
            swap(currentImage?.photo)
        }

    }

    // moves current image to a backup array, and then sets the first element in array of photoqueue to the current image
    func swipe(){
        println("Count \(photoQueue.count)")
        if !photoQueue.isEmpty  {
            photoQueue.removeAtIndex(0)
            if photoQueue.isEmpty{
                var maxId = currentImage?.id
                currentImage = nil
                dispatch_async(dispatch_get_main_queue()) {
                    var long = self.currentLocation?.coordinate.longitude
                    var lat = self.currentLocation?.coordinate.latitude
                    self.apiController.loadImages(lat!, long: long!,radius: 0.1,count: 50, maxId : maxId!)
                }
            }else{
                println(photoQueue[0].url)
                println(currentImage?.url)
                if currentImage?.url == photoQueue[0].url{
                    swipe()
                }
                else{
                    currentImage = photoQueue[0]
                }
                
            }


        }
        
        else
        {
            //photoQueue = hold // since photoqueu should be empty, then the backup hold array will be replaced for photoqueue
            //hold = []
            //swipe()
        }
        
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
