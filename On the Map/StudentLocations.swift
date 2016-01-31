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
    
    func getStudentLocations(completion: (success: Bool) -> Void) {
        
        locations.removeAll()
        
        let parameters = [ParseClient.ParameterKeys.Limit: 100]
        
        ParseClient.sharedInstance().getStudentLocations(parameters) { (locations, error) -> Void in
            guard let studentLocations = locations else {
                completion(success: false)
                return
            }
            
            self.locations = studentLocations
            completion(success: true)
        }
    }
    
}
