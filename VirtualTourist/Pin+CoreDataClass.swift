//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, pages: Int32, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.pages = pages
        }else {
            fatalError("Unable to find Entity name!")
        }
    }

}
