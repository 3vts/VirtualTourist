//
//  MapViewController+MapDelegate.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController : MKMapViewDelegate {
    
    func addPin(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        FlickrClient.sharedInstance().getAndStoreImages(newCoordinates)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "defaultSpanLatitude")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "defaultSpanLongitude")
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "defaultLatitude")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "defaultLongitude")
        UserDefaults.standard.synchronize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            let pin = mapView.selectedAnnotations[0]
            let photoAlbum = segue.destination as? PhotoAlbumViewController
            photoAlbum?.pinCoordinates = pin.coordinate
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if editButton.title == "Done"{
            mapView.removeAnnotation(view.annotation!)
        } else {
            performSegue(withIdentifier: "showPhotos", sender: self)
        }
    }
    
}
