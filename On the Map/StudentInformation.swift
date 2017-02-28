//
//  StudentInformation.swift
//  On the Map
//
//  Created by Alp Eren Can on 23/01/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    
    init(info: [String: AnyObject]) {
        objectId = info["objectId"] as? String != nil ? info["objectId"] as! String : String()
        uniqueKey = info["uniqueKey"] as? String != nil ? info["uniqueKey"] as! String : String()
        firstName = info["firstName"] as? String != nil ? info["firstName"] as! String : String()
        lastName = info["lastName"] as? String != nil ? info["lastName"] as! String : String()
        mapString = info["mapString"] as? String != nil ? info["mapString"] as! String : String()
        mediaURL = info["mediaURL"] as? String != nil ? info["mediaURL"] as! String : String()
        latitude = info["latitude"] as? Double != nil ? info["latitude"] as! Double : 0.0
        longitude = info["longitude"] as? Double != nil ? info["longitude"] as! Double : 0.0
    }
}
