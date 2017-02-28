//
//  StudentLocations.swift
//  On the Map
//
//  Created by Alp Eren Can on 24/01/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation

class StudentLocations {
    
    // MARK: Properties
    
    var locations = [StudentInformation]()
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> StudentLocations {
        
        struct Singleton {
            static var sharedInstance = StudentLocations()
        }
        
        return Singleton.sharedInstance
    }
    
    func getStudentLocations(_ completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        locations.removeAll()
        
        let parameters = [ParseClient.ParameterKeys.Limit: 100,
            ParseClient.ParameterKeys.Order: "-updatedAt"] as [String : Any]
        
        ParseClient.sharedInstance().getStudentLocations(parameters as [String : AnyObject]) { (locations, error) -> Void in
            guard let studentLocations = locations else {
                completion(false, error)
                return
            }
            
            self.locations = studentLocations
            completion(true, nil)
        }
    }
    
}
