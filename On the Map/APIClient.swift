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
    var session: URLSession
    
    // MARK: Initializers
    
    override init() {
        session = URLSession.shared
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
    
    func post(_ urlString: String, method: String, parameters: [String: AnyObject], customHeaders: [String: AnyObject]?, customBody: [String: AnyObject], completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Build the url and configure the request
        let url = URL(string: urlString + method + APIClient.escapedParameters(parameters))
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if let bodyData = try? JSONSerialization.data(withJSONObject: customBody, options: .prettyPrinted) {
            request.httpBody = bodyData
        }
        
        // Make the request and return the task
        return makeRequest(request as URLRequest, completion: completion)
    }
    
    // MARK: GET
    
    func get(_ urlString: String, method: String, parameters: [String: AnyObject], customHeaders: [String: AnyObject]?, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Build the url and configure the request
        let url = URL(string: urlString + method + APIClient.escapedParameters(parameters))
        let request = NSMutableURLRequest(url: url!)
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        // Make the request and return the task
        return makeRequest(request as URLRequest, completion: completion)
        
    }
    
    // MARK: PUT
    
    func put(_ urlString: String, method: String, customHeaders: [String: AnyObject]?, customBody: [String: AnyObject], completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Build the url and configure the request
        let url = URL(string: urlString + method)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if let bodyData = try? JSONSerialization.data(withJSONObject: customBody, options: .prettyPrinted) {
            request.httpBody = bodyData
        }
        
        // Make the request and return the task
        return makeRequest(request as URLRequest, completion: completion)
    }
    
    // MARK: DELETE
    
    func delete(_ urlString: String, method: String, customHeaders:[String: AnyObject]?, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // Build the url and configure the request
        let url = URL(string: urlString + method)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        if let headers = customHeaders {
            for (key, value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        // Make the request and return the task
        return makeRequest(request as URLRequest, completion: completion)
    }
    
    // MARK: Helpers
    
    /* Helper: Make the request, check the data and return the task */
    func makeRequest(_ request: URLRequest, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            // Was there an error with the request?
            guard error == nil else {
                print("There was an error with your request: \(error)")
                completion(nil, error as NSError?)
                return
            }
            
            // Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Invalid response!"]
                completion(nil, NSError(domain: "invalidResponse", code: 0, userInfo: userInfo))
                
                return
            }
            
            // Was there any data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "No data returned!"]
                completion(nil, NSError(domain: "noData", code: 0, userInfo: userInfo))
                return
            }
            
            // Return data in completion
            completion(data as AnyObject?, nil)
        }) 
        
        // Start the request
        task.resume()
        
        return task
        
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }

}
