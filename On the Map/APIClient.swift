//
//  APIClient.swift
//  On the Map
//
//  Created by Alp Eren Can on 2015-12-30.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit

class APIClient: NSObject {
    
    // MARK: Properties
    
    // Shared session
    var session: NSURLSession
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> APIClient {
        
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: POST
    
    func post(urlString: String, method: String, parameters: [String: AnyObject], customHeaders: [String: AnyObject]?, customBody: [String: AnyObject], completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the url and configure the request
        let url = NSURL(string: urlString + method + APIClient.escapedParameters(parameters))
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if let bodyData = try? NSJSONSerialization.dataWithJSONObject(customBody, options: .PrettyPrinted) {
            request.HTTPBody = bodyData
        }
        
        // Make the request and return the task
        return makeRequest(request, completion: completion)
    }
    
    // MARK: GET
    
    func get(urlString: String, method: String, parameters: [String: AnyObject], customHeaders: [String: AnyObject]?, completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the url and configure the request
        let url = NSURL(string: urlString + method + APIClient.escapedParameters(parameters))
        let request = NSMutableURLRequest(URL: url!)
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        // Make the request and return the task
        return makeRequest(request, completion: completion)
        
    }
    
    // MARK: PUT
    
    func put(urlString: String, method: String, customHeaders: [String: AnyObject]?, customBody: [String: AnyObject], completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the url and configure the request
        let url = NSURL(string: urlString + method)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if let bodyData = try? NSJSONSerialization.dataWithJSONObject(customBody, options: .PrettyPrinted) {
            request.HTTPBody = bodyData
        }
        
        // Make the request and return the task
        return makeRequest(request, completion: completion)
    }
    
    // MARK: DELETE
    
    func delete(urlString: String, method: String, customHeaders:[String: AnyObject]?, completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the url and configure the request
        let url = NSURL(string: urlString + method)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        // Make the request and return the task
        return makeRequest(request, completion: completion)
    }
    
    // MARK: Helpers
    
    /* Helper: Make the request, check the data and return the task */
    func makeRequest(request: NSURLRequest, completion: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let task = APIClient.sharedInstance().session.dataTaskWithRequest(request) { (data, response, error) in
            // Was there an error with the request?
            guard error == nil else {
                print("There was an error with your request: \(error)")
                completion(result: nil, error: error)
                return
            }
            
            // Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Invalid response!"]
                completion(result: nil, error: NSError(domain: "invalidResponse", code: 0, userInfo: userInfo))
                
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "No data returned!"]
                completion(result: nil, error: NSError(domain: "noData", code: 0, userInfo: userInfo))
                return
            }
            
            // Return data in completion
            completion(result: data, error: nil)
        }
        
        // Start the request
        task.resume()
        
        return task
        
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}
