//
//  PhotoAlbumCell.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/17/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import UIKit

class PhotoAlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            imageView.alpha = isSelected ? 0.5 : 1
        }
    }
    
    func setImage(photo: Photo, _ sender: UIViewController){
        imageView.image = UIImage(data: photo.data! as Data)
        if photo.data == UIImagePNGRepresentation(#imageLiteral(resourceName: "default-placeholder"))! as NSData {
            activityIndicator.startAnimating()
            FlickrClient.sharedInstance().downloadImage(photo, { (error) in
                if error != nil {
                    FlickrClient.sharedInstance().showErrorMessage(error!, sender)
                }
            })
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

