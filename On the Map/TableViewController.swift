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
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = tableView.center
        tableView.addSubview(activityIndicator!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchStudentLocations(refresh: false)
    }
    
    // MARK: Actions
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        activityIndicator?.startAnimating()
        
        UdacityClient.sharedInstance().logout { (success) -> Void in
            DispatchQueue.main.async { () -> Void in
                self.activityIndicator?.stopAnimating()
                
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Logout failed.")
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        fetchStudentLocations(refresh: true)
    }
    
    // MARK: TableViewController
    
    func fetchStudentLocations(refresh: Bool) {
        if studentLocations.locations.count == 0 || refresh {
            activityIndicator?.startAnimating()
            studentLocations.getStudentLocations() { (success, error) -> Void in
                DispatchQueue.main.async { () -> Void in
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell") as UITableViewCell!
        
        let studentInfo = studentLocations.locations[indexPath.row]
        
        cell?.textLabel?.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        cell?.detailTextLabel?.text = studentInfo.mediaURL
        
        return cell!
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentInfo = studentLocations.locations[indexPath.row]
        let app = UIApplication.shared
        app.openURL(URL(string: studentInfo.mediaURL)!)
    }
    
}

