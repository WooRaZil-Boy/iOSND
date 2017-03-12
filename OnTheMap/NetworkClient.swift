//
//  UdaCityClient.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class NetworkClient {
    //MARK: - Properties
    var session = URLSession.shared
}

//MARK: - CRED
extension NetworkClient {
    //MARK: - GET
    func taskForGETMethod(isParse: Bool = true, method: String, query: [String: AnyObject]? = nil, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: urlFromParameters(isParse, withPathExtension: method, withQuery: query))
        
        if isParse { setParseKey(request) }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if self.catchError(data: data, response: response, error: error, handler: completionHandlerForGET) == false {
                self.convertDataWithCompletionHandler(self.checkNetworkData(method: method), data: data!, completionHandlerForConvertData: completionHandlerForGET)
            }
        }
        
        task.resume()
        
        return task
    }
    
    //MARK: - POST, PUT
    func taskForPOST_PUTMethod(httpMethod: String = "POST", isParse: Bool = true, method: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: urlFromParameters(isParse, withPathExtension: method))
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        if isParse { setParseKey(request) }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if self.catchError(data: data, response: response, error: error, handler: completionHandlerForPOST) == false {
                self.convertDataWithCompletionHandler(self.checkNetworkData(method: method), data: data!, completionHandlerForConvertData: completionHandlerForPOST)
            }
        }
        
        task.resume()
        
        return task
    }
    
    //MARK: - DELETE
    func taskForDELETEMethod(method: String, completionHandlerForDelete: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: urlFromParameters(false, withPathExtension: method))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if self.catchError(data: data, response: response, error: error, handler: completionHandlerForDelete) == false {
                self.convertDataWithCompletionHandler(self.checkNetworkData(method: method), data: data!, completionHandlerForConvertData: completionHandlerForDelete)
            }
        }
        
        task.resume()
        
        return task
    }
}

//MARK: - UdaCity
extension NetworkClient {
    func getSession(email: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        let _ = taskForPOST_PUTMethod(isParse: false, method: Methods.UdaCitySession, jsonBody: jsonBody) { results, error in
            guard error == nil else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let resultDictionary = results?["account"] as? [String: AnyObject] else {
                completionHandler(false, "Can't covert getSession_results")
                return
            }
            
            guard let userID = resultDictionary["key"] as? String else {
                completionHandler(false, "Can't covert getSession_accountDictionary")
                return
            }
            
            Student.sharedInstance().userID = userID
            
            completionHandler(true, nil)
        }
    }

    func deleteSession(completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let _ = taskForDELETEMethod(method: Methods.UdaCitySession) { results, error in
            guard error == nil else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            completionHandler(true, nil)
        }
    }
}

//MARK: - Parse
extension NetworkClient {
    func getStudentLocations(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let query = ["limit": 100, "order" : "-updatedAt"] as [String : Any]
        let _ = taskForGETMethod(method: Methods.ParseLocation, query: query as [String : AnyObject]?) { results, error in
            guard error == nil else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let resultsArray = results?["results"] as? [[String: AnyObject]] else {
                completionHandler(false, "Can't convert getStudentLocations_results")
                return
            }

            Student.sharedInstance().locations = Student.locationsFromResults(resultsArray)
            
            completionHandler(true, nil)
        }
    }
    
    func getStudentLocation(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ objectID: String?) -> Void) {
        let query = ["where": "{\"uniqueKey\":\"\(Student.sharedInstance().userID!)\"}" as AnyObject]
        
        let _ = taskForGETMethod(method: Methods.ParseLocation, query: query) { results, error in
            guard error == nil else {
                completionHandler(false, error?.localizedDescription, nil)
                return
            }
            
            guard let resultsArray = results?["results"] as? [[String: AnyObject]] else {
                completionHandler(false, "Can't convert getStudentLocation_results", nil)
                return
            }
            
            if resultsArray.isEmpty {
                completionHandler(true, nil, nil)
            
                return
            }
            
            let locationDictionary = resultsArray[resultsArray.endIndex - 1]

            guard let objectID = locationDictionary["objectId"] as? String else {
                completionHandler(false, "Can't convert getStudentLocation_locationDictionary", nil)
                return
            }
            
            Student.sharedInstance().objectID = objectID
            
            completionHandler(true, nil, objectID)
        }
    }
    
    func setStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        var httpMethod: String
        var method: String
        
        if Student.sharedInstance().objectID == nil {
            httpMethod = "POST"
            method = Methods.ParseLocation
        } else {
            httpMethod = "PUT"
            method = Methods.ParseLocation + "/" + Student.sharedInstance().objectID!
        }
        
        var mutableMethod: String = Methods.UdaCityUsers
        mutableMethod = substituteKeyInMethod(mutableMethod, key: "id", value: String(Student.sharedInstance().userID!))!
        
        let _ = taskForGETMethod(isParse: false, method: mutableMethod) { results, error in
            guard error == nil else {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let userDictionary = results?["user"] as? [String: AnyObject] else {
                completionHandler(false, "setStudentLocation_results")
                return
            }
            
            guard let firstName = userDictionary["first_name"] as? String, let lastName = userDictionary["last_name"] as? String else {
                completionHandler(false, "setStudentLocation_names")
                return
            }
            
            let _ = self.taskForPOST_PUTMethod(httpMethod: httpMethod, method: method, jsonBody: "{\"uniqueKey\": \"\(Student.sharedInstance().userID!)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}") { results, error in
                guard error == nil else {
                    completionHandler(false, error?.localizedDescription)
                    return
                }
                
                completionHandler(true, nil)
            }
        }
    }
}

//MARK: - Helper Methods
extension NetworkClient {
    class func sharedInstance() -> NetworkClient {
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        return Singleton.sharedInstance
    }
    
    func urlFromParameters(_ isParse: Bool = true, withPathExtension: String? = nil, withQuery query: [String: AnyObject]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = NetworkClient.Contrants.Scheme
        components.host = isParse ? NetworkClient.Contrants.ParseHost : NetworkClient.Contrants.UdaCityHost
        let path =  isParse ? NetworkClient.Contrants.ParsePath: NetworkClient.Contrants.UdaCityPath
        components.path = path + (withPathExtension ?? "")
        
        if let query = query {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in query {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    func checkNetworkData(method: String) -> NetworkData {
        var networkDataType: NetworkData
        let newMethod = method.contains(Methods.ParseLocation) ? Methods.ParseLocation : method
        
        switch newMethod {
        case Methods.UdaCitySession :
            networkDataType = NetworkData.Session
        case Methods.ParseLocation :
            networkDataType = NetworkData.Location
        default:
            networkDataType = NetworkData.User
        }
        
        return networkDataType
    }
    
    func setParseKey(_ request: NSMutableURLRequest) {
        request.addValue(ParseKeys.ParseApplicationIDValue, forHTTPHeaderField: ParseKeys.ParseApplicationIDKey)
        request.addValue(ParseKeys.ParseRESTAPIValue, forHTTPHeaderField: ParseKeys.ParseRESTAPIKey)
    }
    
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    func convertDataWithCompletionHandler(_ type: NetworkData, data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        
        switch type {
        case NetworkData.Session, NetworkData.User :
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data.subdata(in: Range(uncheckedBounds: (lower: data.startIndex.advanced(by: 5), upper: data.endIndex))), options: .allowFragments) as AnyObject?
            } catch let error as NSError {
                print("ERROR convertDataWithCompletionHandler_Session \(error.localizedDescription)")
                completionHandlerForConvertData(nil, error)
            }
        case NetworkData.Location :
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject?
            } catch let error as NSError {
                print("ERROR convertDataWithCompletionHandler_Location \(error.localizedDescription)")
                completionHandlerForConvertData(nil, error)
            }
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}

//MARK: - ErrorHandling
extension NetworkClient {
    func sendError(_ error: String, handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let userInfo = [NSLocalizedDescriptionKey : error]
        handler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
    }
    
    func catchError(data: Data?, response: URLResponse?, error: Error?, handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> Bool {
        guard (error == nil) else {
            sendError("There was an error with your request: \(error)", handler: handler)
            return true
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            
            self.sendError("Your request returned a status code other than 2xx!", handler: handler)
            return true
        }
        guard let _ = data else {
            self.sendError("No data was returned by the request!", handler: handler)
            return true
        }
        
        return false
    }
}
