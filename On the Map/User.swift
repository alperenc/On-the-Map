//
//  User.swift
//  On the Map
//
//  Created by Alp Eren Can on 13/01/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import Foundation

class User {
    let id: String
    let firstName: String
    let lastName: String
    
    init(info: [String: AnyObject]) {
        id = info["key"] as! String
        firstName = info["first_name"] as! String
        lastName = info["last_name"] as! String
    }
}