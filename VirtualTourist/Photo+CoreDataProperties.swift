//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/24/17.
//  Copyright © 2017 3vts. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var pin: Pin?

}
