//
//  Annotation+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

extension Annotation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Annotation> {
        return NSFetchRequest<Annotation>(entityName: Constants.CoreData.Annotaion);
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: NSSet?
}

// MARK: Generated accessors for photos
extension Annotation {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photos)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photos)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
}
