//
//  SettingsViewController.swift
//  owlr
//
//  Created by Kevin Carbone on 2/7/15.
//  Copyright (c) 2015 Kevin Carbone. All rights reserved.
//


import UIKit
import Foundation
import CoreLocation
import MapKit


class SettingsViewController: UIViewController{
    
    var locationDelegate : LocationChangeProtocol?
    var currentLocation : CLLocation?
    var radius : Double? = 50

    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var radiusLabel: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)

    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        var coord = self.currentLocation?.coordinate
        self.mapview.centerCoordinate = coord!
        var ann = MKPointAnnotation()
        ann.coordinate = coord!
        var currentLocation = CLLocation(latitude: ann.coordinate.latitude, longitude: ann.coordinate.longitude)
        self.currentLocation = currentLocation
        mapview.removeAnnotations(mapview.annotations)
        mapview.addAnnotation(ann)
        self.updateSlider()
    }
    
    @IBAction func globeButtonPressed(sender: AnyObject) {
        self.locationDelegate?.didUpdateLocation(self.currentLocation!, radius: self.radius!)
        self.dismissViewControllerAnimated(true, completion: {() in
        
        })
        
    }
    
    func updateSlider(){
        self.radiusSlider.setValue(Float(self.radius!), animated: true)
        radiusLabel.text = "\(Int(self.radius!))"
    }
    
    @IBAction func sliderValueChanged(sender: AnyObject) {
        let radiusNum = Int(radiusSlider.value)
        self.radius = Double(radiusSlider.value)
        radiusLabel.text = "\(radiusNum)"
    }
    
    @IBAction func mapTapped(sender: UITapGestureRecognizer) {
        
            var point = sender.locationInView(self.mapview)
            var tapPoint = self.mapview.convertPoint(point, toCoordinateFromView: self.mapview)
            var ann = MKPointAnnotation()
            ann.coordinate = tapPoint
            var currentLocation = CLLocation(latitude: ann.coordinate.latitude, longitude: ann.coordinate.longitude)
            self.currentLocation = currentLocation
            mapview.removeAnnotations(mapview.annotations)
            mapview.addAnnotation(ann)
        
    }

}