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
        objectId = info["objectId"] as! String
        uniqueKey = info["uniqueKey"] as! String
        firstName = info["firstName"] as! String
        lastName = info["lastName"] as! String
        mapString = info["mapString"] as! String
        mediaURL = info["mediaURL"] as! String
        latitude = info["latitude"] as! Double
        longitude = info["longitude"] as! Double
    }
}