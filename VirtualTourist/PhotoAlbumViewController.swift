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
private let itemsPerRow: CGFloat = 3

class PhotoAlbumViewController: CoreDataCollectionViewController {
    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backgroundView: UIView!
    var pinCoordinates = CLLocationCoordinate2D()
    var currentPin : Pin?
    var mapType = UInt()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        addAnnotationAndCenterMap()
        setupCoreData()
        collectionView.backgroundView = backgroundView
        guard let mapType = MKMapType(rawValue: mapType) else {
            return
        }
        mapView.mapType = mapType
        collectionView.reloadData()
    }
    @IBAction func newCollectionButtonTapped(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text else {
            return
        }
        switch text {
        case "Remove Selected Pictures":
            var photosToDelete = [Photo]()
            guard let selectedItems = collectionView.indexPathsForSelectedItems else {
                return
            }
            for indexPath in selectedItems.enumerated() {
                guard let photoToDelete = fetchedResultsController?.object(at: indexPath.element) as? Photo else {
                    return
                }
                photosToDelete.append(photoToDelete)
            }
            for photo in photosToDelete{
                delegate.stack.context.delete(photo)
                try! delegate.stack.context.save()
            }
            newCollectionButton.setTitle("New Collection", for: .normal)
        default:
            guard let currentPin = currentPin else{
                return
            }
            guard let photoCollection = currentPin.photo?.allObjects as? [Photo] else {
                return
            }
            for photo in photoCollection {
                delegate.stack.context.delete(photo)
                try! delegate.stack.context.save()
            }
            let randomPage = arc4random_uniform(UInt32(currentPin.pages))
            FlickrClient.sharedInstance().getAndStoreImages(pinCoordinates, pagenumber: Int(randomPage))
            collectionView.reloadData()
        }
    }
    
    
    func setupCoreData(){
        let stack = delegate.stack
        
        //Create fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
        guard let currentPin = currentPin else{
            return
        }
        fr.predicate = NSPredicate(format: "pin == %@", currentPin)
        //Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let picture = fetchedResultsController!.object(at: indexPath) as! Photo
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoAlbumCell
        cell?.setImage(photo: picture)
        return cell!
    }
    
    private func addAnnotationAndCenterMap(){
        let annotation = MKPointAnnotation()
        let span = MKCoordinateSpanMake(0.05, 0.05)
        annotation.coordinate = pinCoordinates
        mapView.addAnnotation(annotation)
        mapView.region = MKCoordinateRegionMake(pinCoordinates, span)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }
    
    func setButtonText(){
        guard let selectedItemCount = collectionView.indexPathsForSelectedItems?.count else {
            return
        }
        selectedItemCount > 0 ? newCollectionButton.setTitle("Remove Selected Pictures", for: .normal) : newCollectionButton.setTitle("New Collection", for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setButtonText()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        setButtonText()
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize()
        }
        let paddingSpace = collectionViewLayout.sectionInset.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let sizePerItem = availableWidth / itemsPerRow
        return CGSize(width: sizePerItem, height: sizePerItem)
    }
    
    
}

