//
//  Annotation+CoreDataClass.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public class Annotation: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
