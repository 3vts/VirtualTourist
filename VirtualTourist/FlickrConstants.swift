//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        static let MaxImages: UInt32 = 4000
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Tags = "tags"
        static let TagMode = "tag_mode"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "e5ca2fa988937be570de3394084145d5"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_m"
        static let PerPage = "18"
        static let Tags = "nature,landscape,park,street,lake,river,bird,trees,snow,green,flowers,sky,beach,sunset"
        static let TagMode = "or"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
        static let Pages = "pages"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}
