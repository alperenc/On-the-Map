//
//  ParseClient.swift
//  On the Map
//
//  Created by Alp Eren Can on 2015-12-29.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit
import MapKit

class ParseClient: APIClient {
    
    // MARK: Shared Instance
    
    override class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func getStudentLocations(parameters: [String: AnyObject], completion:(locations: [StudentInformation]?, error: NSError?) -> Void) {
        
        // Specify parameters, method (if has {key}), custom headers and body (if POST)
        let parameters = parameters
        
        let headers = [HeaderKeys.ApplicationID: Constants.ApplicationID,
            HeaderKeys.RESTAPIKey: Constants.RESTAPIKey]
        
        // Get student locations
        APIClient.sharedInstance().get(Constants.BaseSecureURL, method: Methods.StudentLocation, parameters: parameters, customHeaders: headers) { (result, error) -> Void in
            if let data = result as? NSData {
                APIClient.parseJSONWithCompletionHandler(data) { (result, error) -> Void in
                    guard let results = result["results"] as? [[String: AnyObject]] else {
                        print("Failed to retrieve student locations.")
                        completion(locations: nil, error: error)
                        return
                    }
                    
                    completion(locations: self.createStudentLocations(results), error: nil)
                }
            } else {
                completion(locations: nil, error: error)
            }
            
        }
    }
    
    func submitStudentLocation(location: CLPlacemark, locationName: String, link: String, completion: (success: Bool, error: NSError?) -> Void) {
        
        // Check for user
        guard let user = UdacityClient.sharedInstance().user else {
            let userInfo = [NSLocalizedDescriptionKey : "User must be logged in"]
            completion(success: false, error: NSError(domain: "noUser", code: 0, userInfo: userInfo))
            return
        }
        
        // Specify parameters, method (if has {key}), custom headers and body (if POST)
        let parameters = [String: AnyObject]()
        
        let headers = [HeaderKeys.ApplicationID: Constants.ApplicationID,
            HeaderKeys.RESTAPIKey: Constants.RESTAPIKey]
        
        let body : [String: AnyObject] = [BodyKeys.UniqueKey: user.id,
            BodyKeys.FirstName: user.firstName,
            BodyKeys.LastName: user.lastName,
            BodyKeys.MapString: locationName,
            BodyKeys.MediaURL: link,
            BodyKeys.Latitude: (location.location?.coordinate.latitude)!,
            BodyKeys.Longitude: (location.location?.coordinate.longitude)!]
        
        // Post student location
        APIClient.sharedInstance().post(Constants.BaseSecureURL, method: Methods.StudentLocation, parameters: parameters, customHeaders: headers, customBody: body) { (result, error) -> Void in
            if error == nil {
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        }
        
    }
    
    func createStudentLocations(results: [[String: AnyObject]]) -> [StudentInformation] {
        var locations = [StudentInformation]()
        
        for studentInfo in results {
            let studentLocation = StudentInformation(info: studentInfo)
            locations.append(studentLocation)
        }
        
        return locations
    }

}

extension ParseClient {
    
    struct Constants {
        
        // MARK: Application ID and REST API Key
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let BaseSecureURL = "https://api.parse.com/1/classes/"
        
    }
    
    struct Methods {
        
        // MARK: StudentLocation
        static let StudentLocation = "StudentLocation"
        
    }
    
    struct ParameterKeys {
        
        // MARK: Optional parameters for GET method
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        
    }
        
    struct HeaderKeys {
        
        // MARK: Application ID and REST API Key
        static let ApplicationID = "X-Parse-Application-Id"
        static let RESTAPIKey = "X-Parse-REST-API-Key"
    
    }
    
    struct BodyKeys {
        
        // MARK: StudentLocation fields
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
    }
        
}

