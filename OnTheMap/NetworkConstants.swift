//
//  UdaCityConstants.swift
//  OnTheMap
//
//  Created by 근성가이 on 2017. 3. 9..
//  Copyright © 2017년 근성가이. All rights reserved.
//

extension NetworkClient {
    struct Contrants {
        
        // MARK: URLs
        static let Scheme = "https"
        
        static let UdaCityHost = "www.udacity.com"
        static let UdaCityPath = "/api"
        
        static let ParseHost = "parse.udacity.com"
        static let ParsePath = "/parse"
        
        static let UdacitySignUpPath = "https://www.udacity.com/account/auth#!/signup"
        
    }
    
    struct Methods {
        static let UdaCitySession = "/session"
        static let UdaCityUsers = "/users/{id}"
        
        static let ParseLocation = "/classes/StudentLocation"
    }
    
    struct ParseKeys {
        static let ParseApplicationIDValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApplicationIDKey = "X-Parse-Application-Id"
        
        static let ParseRESTAPIValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseRESTAPIKey = "X-Parse-REST-API-Key"
    }
    
    enum NetworkData {
        case Session, User, Location
    }
}
