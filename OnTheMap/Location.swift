//
//  Location.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import MapKit

class Location: NSObject {
    //MARK: - Properties
    var firstName: String
    var lastName: String
    var latitude: Double
    var longitude: Double
    var mapString: String
    var mediaURL: String
    var objectId: String
    var uniqueKey: String
    var fullName: String {
        if firstName == "" && lastName == "" {
            return "(No Name)"
        } else {
            return "\(firstName) \(lastName)"
        }
    }

    //MARK: - Initialization
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary["firstName"] as? String ?? ""
        lastName = dictionary["lastName"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
        mapString = dictionary["mapString"] as? String ?? ""
        mediaURL = dictionary["mediaURL"] as? String ?? ""
        objectId = dictionary["objectId"] as? String ?? ""
        uniqueKey = dictionary["uniqueKey"] as? String ?? ""
    }
    
    static func locationsFromResults(_ results: [[String: AnyObject]]) -> [Location] {
        var locations = [Location]()
        
        for result in results {
            locations.append(Location(dictionary: result))
        }
        
        return locations
    }
}

//MARK: - MKAnnotation
extension Location: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return fullName
    }
    
    var subtitle: String? {
        return mediaURL
    }
}
