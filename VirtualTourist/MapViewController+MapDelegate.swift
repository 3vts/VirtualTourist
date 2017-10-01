//
//  MapViewController+MapDelegate.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension MapViewController : MKMapViewDelegate {
    
    func addPin(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let stack = delegate.stack
        let pin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, pages: 0, context: stack.context)
        stack.save()
        createAnnotation(newCoordinates)
        FlickrClient.sharedInstance().getAndStoreImages(pin, { (error) in
            if error != nil {
                FlickrClient.sharedInstance().showErrorMessage(error!, self)
            }
        })
    }
    
    func fetchObjects(_ predicate: NSPredicate? = nil) -> [AnyObject]? {

        let stack = delegate.stack
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        if let predicate = predicate {
            fr.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            return nil
        }
        return fetchedObjects
    }
    
    func createAnnotation(_ newCoordinates: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "defaultSpanLatitude")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "defaultSpanLongitude")
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "defaultLatitude")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "defaultLongitude")
        UserDefaults.standard.synchronize()
    }
    
    
    
    func fetchAnnotationPin(_ coordinate: CLLocationCoordinate2D) -> Pin? {
        let predicate = NSPredicate(format: "latitude > %f AND latitude < %f AND longitude > %f AND longitude < %f", coordinate.latitude - epsilon,  coordinate.latitude + epsilon, coordinate.longitude - epsilon, coordinate.longitude + epsilon)
        if let objects = fetchObjects(predicate)?.first as? Pin {
            return objects
        } else{
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            guard let selectedAnnotation = mapView.selectedAnnotations.first else {
                return
            }
            let coordinate = selectedAnnotation.coordinate
            guard let photoAlbum = segue.destination as? PhotoAlbumViewController else {
                return
            }
            photoAlbum.pinCoordinates = selectedAnnotation.coordinate
            guard let pin = fetchAnnotationPin(coordinate) else {
                return
            }
            photoAlbum.currentPin = pin
            photoAlbum.mapType = mapView.mapType.rawValue
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editButton.title == "Done"{
            let stack = delegate.stack
            guard let annotation = view.annotation else {
                return
            }
            mapView.removeAnnotation(annotation)
            guard let pin = fetchAnnotationPin(annotation.coordinate) else {
                return
            }
            stack.context.delete(pin)
            stack.save()
        } else {
            performSegue(withIdentifier: "showPhotos", sender: self)
        }
    }
    
}
