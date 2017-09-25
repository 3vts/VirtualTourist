//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/17/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "Cell"
//fileprivate var selectedPhotos = [FlickrPhoto]()
fileprivate let itemsPerRow: CGFloat = 3

class PhotoAlbumViewController: CoreDataCollectionViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backgroundView: UIView!
    var pinCoordinates = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAnnotationAndCenterMap()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack

        //Create fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]

        //Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        collectionView.backgroundView = backgroundView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let picture = fetchedResultsController!.object(at: indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoAlbumCell
        cell?.imageView.image = UIImage(data: picture.data! as Data)
        
        return cell!
    }
    
    func addAnnotationAndCenterMap(){
        let annotation = MKPointAnnotation()
        let span = MKCoordinateSpanMake(0.05, 0.05)
        annotation.coordinate = pinCoordinates
        mapView.addAnnotation(annotation)
        mapView.region = MKCoordinateRegionMake(pinCoordinates, span)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)!
//        if cell.isSelected == true {
//            collectionView.deselectItem(at: indexPath, animated: true)
//        }
    }

}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let paddingSpace = (collectionViewLayout?.sectionInset.left)! * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
}

