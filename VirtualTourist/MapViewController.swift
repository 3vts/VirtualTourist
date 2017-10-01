//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: CoreDataCollectionViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewSelector: UISegmentedControl!
    @IBOutlet weak var editBannerHeight: NSLayoutConstraint!
    let epsilon = 0.00001
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapLocation()
        setAnnotations()
    }

    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            addPin(gestureRecognizer: sender)
        }
    }

    @IBAction func mapSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .hybrid
        }
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "defaultMapType")
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if editButton.title == "Edit" {
            editBannerHeight.constant = 60
            editButton.title = "Done"
        }else {
            editBannerHeight.constant = 0
            editButton.title = "Edit"
        }
        
    }
    
    func setAnnotations(){
        guard let annotations = fetchObjects() as? [Pin] else {
            return
        }
        for annotation in annotations {
            let coordinates = CLLocationCoordinate2DMake(annotation.latitude, annotation.longitude)
            createAnnotation(coordinates)
        }
    }
    
    fileprivate func setMapLocation() {
        if let latitude = UserDefaults.standard.value(forKey: "defaultLatitude"),  let longitude = UserDefaults.standard.value(forKey: "defaultLongitude"), let spanLatitude = UserDefaults.standard.value(forKey: "defaultSpanLatitude"), let spanLongitude = UserDefaults.standard.value(forKey: "defaultSpanLongitude") {
            let region2D = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
            let span = MKCoordinateSpanMake(spanLatitude as! CLLocationDegrees, spanLongitude as! CLLocationDegrees)
            let region = MKCoordinateRegionMake(region2D, span)
            self.mapView.setRegion(region, animated: false)
        }
        if let mapTypeValue = UserDefaults.standard.value(forKey: "defaultMapType"), let mapType = MKMapType(rawValue: mapTypeValue as! UInt) {
            self.mapView.mapType = mapType
            self.mapViewSelector.selectedSegmentIndex = mapTypeValue as! Int
        }
    }

}

