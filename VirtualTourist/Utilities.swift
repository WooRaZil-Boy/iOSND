//
//  Utilities.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 13..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

typealias TaskHandler = (_ result: AnyObject?, _ error: NSError?) -> Void

struct Constants {
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        
        struct ParameterKeys {
            static let Method = "method"
            static let APIKey = "api_key"
            static let GalleryID = "gallery_id"
            static let Extras = "extras"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let SafeSearch = "safe_search"
            static let Text = "text"
            static let BoundingBox = "bbox"
            static let Page = "page"
            static let PerPage = "per_page"
        }
        
        struct ParameterValues {
            static let SearchMethod = "flickr.photos.search"
            static let APIKey = "YOUR_API_KEY"
            static let ResponseFormat = "json"
            static let DisableJSONCallback = "1" /* 1 means "yes" */
            static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
            static let GalleryID = "5704-72157622566655097"
            static let MediumURL = "url_m"
            static let UseSafeSearch = "1"
            static let PhotosPerPage = "15"
        }
        
        struct ResponseKeys {
            static let Status = "stat"
            static let Photos = "photos"
            static let Photo = "photo"
            static let Title = "title"
            static let MediumURL = "url_m"
            static let Pages = "pages"
            static let Total = "total"
        }
        
        struct ResponseValues {
            static let OKStatus = "ok"
        }
    }
    
    struct CoreData {
        static let ModelName = "VirtualTourist"
        static let Annotaion = "Annotation"
        static let Photos = "Photos"
    }
    
    struct Segue {
        static let PhotoAlbum = "PhotoAlbumSegue"
    }
    
    struct View {
        static let PhotoAlbumCollectionViewCell = "PhotoAlbumCollectionViewCell"
        static let CameraAltitude = 20000.0
    }
}
