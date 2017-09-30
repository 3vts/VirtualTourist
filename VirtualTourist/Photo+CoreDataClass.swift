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
    
    convenience init(data: NSData, url: String = "", context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.data = data
            self.url = url
        }else {
            fatalError("Unable to find Entity name!")
        }
    }

}
