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
    
}
