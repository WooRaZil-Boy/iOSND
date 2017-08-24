//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by 근성가이 on 2017. 3. 12..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import MapKit

class FlickrClient {
    //MARK: - Properties
    var session = URLSession.shared
}

//MARK: - Networking
extension FlickrClient {
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: @escaping TaskHandler) -> URLSessionDataTask {
        let request = URLRequest(url: flickrURLFromParameters(parameters))
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }
    
    func downloadPhoto(url: URL, completionHandlerForPhoto: @escaping (_ image: NSData?, _ error: NSError?) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("downloadPhoto_Error")
                completionHandlerForPhoto(nil, error as NSError?)
                return
            }
            
            completionHandlerForPhoto(data as NSData?, nil)
        }
        
        task.resume()
    }
}

//MARK: - Singleton
extension FlickrClient {
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

//MARK: - Methods
extension FlickrClient {
    func flickrFetch(coordinate: CLLocationCoordinate2D, completionHandler: @escaping TaskHandler) {
        let methodParameters = [
            Constants.Flickr.ParameterKeys.Method: Constants.Flickr.ParameterValues.SearchMethod,
            Constants.Flickr.ParameterKeys.APIKey: Constants.Flickr.ParameterValues.APIKey,
            Constants.Flickr.ParameterKeys.BoundingBox: flickrBboxString(coordinate: coordinate),
            Constants.Flickr.ParameterKeys.SafeSearch: Constants.Flickr.ParameterValues.UseSafeSearch,
            Constants.Flickr.ParameterKeys.Extras: Constants.Flickr.ParameterValues.MediumURL,
            Constants.Flickr.ParameterKeys.Format: Constants.Flickr.ParameterValues.ResponseFormat,
            Constants.Flickr.ParameterKeys.NoJSONCallback: Constants.Flickr.ParameterValues.DisableJSONCallback,
            Constants.Flickr.ParameterKeys.PerPage: Constants.Flickr.ParameterValues.PhotosPerPage,
            Constants.Flickr.ParameterKeys.Page: "\(arc4random_uniform(250))"
        ]
        
        let _ = taskForGETMethod(parameters: methodParameters as [String : AnyObject], completionHandlerForGET: completionHandler)
    }
    
    func flickrBboxString(coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
        let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
        let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: TaskHandler) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
