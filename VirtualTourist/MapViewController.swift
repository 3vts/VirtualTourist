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

class MapViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editBannerHeight: NSLayoutConstraint!
    let region = MKCoordinateRegion()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
//            executeSearch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapLocation()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        //Create FetchRequest
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "locationName", ascending: true)]
        //Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
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
    
    fileprivate func setMapLocation() {
        if let latitude = UserDefaults.standard.value(forKey: "defaultLatitude"),  let longitude = UserDefaults.standard.value(forKey: "defaultLongitude"), let spanLatitude = UserDefaults.standard.value(forKey: "defaultSpanLatitude"), let spanLongitude = UserDefaults.standard.value(forKey: "defaultSpanLongitude") {
            let region2D = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
            let span = MKCoordinateSpanMake(spanLatitude as! CLLocationDegrees, spanLongitude as! CLLocationDegrees)
            let region = MKCoordinateRegionMake(region2D, span)
            self.mapView.setRegion(region, animated: false)
        }
    }

}

