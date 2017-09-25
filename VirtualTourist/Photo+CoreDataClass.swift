//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Alvaro Santiesteban on 9/16/17.
//  Copyright © 2017 3vts. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(data: NSData, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.data = data
        }else {
            fatalError("Unable to find Entity name!")
        }
    }

}
