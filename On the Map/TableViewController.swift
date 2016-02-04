//
//  TableViewController.swift
//  On the Map
//
//  Created by Alp Eren Can on 19/10/15.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    // MARK: Properties
    
    var studentLocations = StudentLocations.sharedInstance()
    
    var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = tableView.center
        tableView.addSubview(activityIndicator!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchStudentLocations(refresh: false)
    }
    
    // MARK: Actions
    
    @IBAction func logout(sender: UIBarButtonItem) {
        activityIndicator?.startAnimating()
        
        UdacityClient.sharedInstance().logout { (success) -> Void in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.activityIndicator?.stopAnimating()
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print("Logout failed.")
                }
            }
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        fetchStudentLocations(refresh: true)
    }
    
    // MARK: TableViewController
    
    func fetchStudentLocations(refresh refresh: Bool) {
        if studentLocations.locations.count == 0 || refresh {
            activityIndicator?.startAnimating()
            studentLocations.getStudentLocations() { (success, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.activityIndicator?.stopAnimating()
                    
                    if success {
                        self.tableView.reloadData()
                    } else {
                        self.alertUser(title: "Download failed!", message: (error?.localizedDescription)!)
                    }
                }
            }
        }
    }
    
    // MARK: Table View Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as UITableViewCell!
        
        let studentInfo = studentLocations.locations[indexPath.row]
        
        cell.textLabel?.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        cell.detailTextLabel?.text = studentInfo.mediaURL
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = studentLocations.locations[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: studentInfo.mediaURL)!)
    }
    
}

