//
//  UdacityClient.swift
//  On the Map
//
//  Created by Alp Eren Can on 2015-12-28.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit

class UdacityClient: APIClient {
    
    // MARK: Properties
    
    var sessionID: String?
    var userID: String?
    var user: User?
    
    // MARK: Shared Instance
    
    override class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Login
    
    func login(username username: String?, password: String?, completion: (success: Bool, error: NSError?) -> Void) {
        
        // Specify parameters, method (if has {key}), custom headers and body (if POST)
        let parameters = [String: AnyObject]()
        
        let body = ["udacity": ["username": username!, "password": password!]]
        
        // Post the session
        APIClient.sharedInstance().post(Constants.BaseSecureURL, method: Methods.Session, parameters: parameters, customHeaders: nil, customBody: body) { (result, error) in
            if let error = error {
                print("Login failed with error: \(error)")
                completion(success: false, error: error)
            } else {
                if let data = result as? NSData {
                    UdacityClient.parseJSONWithCompletionHandler(data) { (result, error) in
                        guard let session = result["session"] as? [String: AnyObject],
                        let account = result["account"] as? [String: AnyObject] else {
                            print("No such keys: session, account")
                            return
                        }
                        
                        self.sessionID = session["id"] as? String
                        self.userID = account["key"] as? String
                        
                        UdacityClient.sharedInstance().getUserData { (userInfo, error) -> Void in
                            if let info = userInfo {
                                self.user = User(info: info)
                                completion(success: true, error: nil)
                            } else {
                                completion(success: false, error: error)
                            }
                        }
                    }
                } else {
                    print("Login failed. No valid data is returned from Udacity server.")
                    let userInfo = [NSLocalizedDescriptionKey : "No valid data is returned from Udacity server."]
                    completion(success: false, error: NSError(domain: "invalidData", code: 0, userInfo: userInfo))
                }
            }
        }
    }
    
    // MARK: Get User Data
    
    func getUserData(completion: (userInfo: [String: AnyObject]?, error: NSError?) -> Void) {
        
        // Specify parameters, method (if has {key}), custom headers and body (if POST)
        let parameters = [String: AnyObject]()
        
        guard let userID = UdacityClient.sharedInstance().userID else {
            print("User ID hasn't been obtained yet. First, post a session and get a user ID.")
            return
        }
        
        guard let method = APIClient.subtituteKeyInMethod(Methods.User, key: URLKeys.UserID, value: userID) else {
            print("Invalid API method for getting user data.")
            return
        }
        
        // Get user data
        APIClient.sharedInstance().get(Constants.BaseSecureURL, method: method, parameters: parameters, customHeaders: nil) { (result, error) in
            
            if let error = error {
                print("Getting public user data failed with error: \(error)")
                completion(userInfo: nil, error: error)
            } else {
                if let data = result as? NSData {
                    UdacityClient.parseJSONWithCompletionHandler(data) { (result, error) in
                        guard let user = result["user"] as? [String: AnyObject] else {
                            print("No such key: user")
                            return
                        }
                        
                        completion(userInfo: user, error: nil)
                    }
                }
            }
        }
    }
    
    // MARK: Logout
    
    func logout(completion:(success: Bool) -> Void) {
        
        // Specify parameters, method (if has {key}), custom headers and body (if POST)
        var xsrfCookie: NSHTTPCookie? = nil
        var headers = [String:AnyObject]()
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            headers["X-XSRF-TOKEN"] = xsrfCookie.value
        }
        
        // Delete the session
        APIClient.sharedInstance().delete(Constants.BaseSecureURL, method: Methods.Session, customHeaders: headers) { (result, error) -> Void in
            if let error = error {
                print("Logout failed with error: \(error)")
                completion(success: false)
            } else {
                self.user = nil
                self.sessionID = nil
                self.userID = nil
                
                completion(success: true)
            }
        }
        
    }
    
    // MARK: Helpers
    
    /*  Helper: Given raw JSON, return a usable Foundation object
        Modified to skip the first 5 characters of the response from Udacity API */
    override class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        super.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
    }

}

extension UdacityClient {
    
    struct Constants {
        
        // MARK: URLs
        static let BaseSecureURL = "https://www.udacity.com/api/"
        static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
        
    }
    
    struct Methods {
        
        // MARK: Session
        static let Session = "session"
        
        // MARK: User
        static let User = "users/{user-id}"
    }
    
    struct URLKeys {
        
        // MARK: UseraID
        static let UserID = "user-id"
        
    }
}
