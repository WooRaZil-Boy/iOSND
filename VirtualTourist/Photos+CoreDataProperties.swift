//
//  Photos+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var annotation: Annotation?
}
