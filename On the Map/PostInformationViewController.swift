//
//  PostInformationViewController.swift
//  On the Map
//
//  Created by Alp Eren Can on 26/01/16.
//  Copyright © 2016 Alp Eren Can. All rights reserved.
//

import UIKit
import MapKit

class PostInformationViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    lazy var geocoder = CLGeocoder()
    var location: CLPlacemark?
    
    var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        linkTextField.delegate = self
        
        configureTextField(locationTextField, tintColor: UIColor.whiteColor())
        configureTextField(linkTextField, tintColor: UIColor.whiteColor())
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = view.center
        view.addSubview(activityIndicator!)
    }
    
    // MARK: Actions
    
    @IBAction func findLocation(sender: UIButton) {
        
        guard let locationText = locationTextField.text else {
            return
        }
        
        activityIndicator?.startAnimating()
        
        geocoder.geocodeAddressString(locationText) { (placemarks, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let error = error {
                    self.activityIndicator?.stopAnimating()
                    self.alertUser(title: "Geocoding failed.", message: error.localizedDescription)
                    return
                }
                
                if let placemarks = placemarks, let location = placemarks.first {
                    self.activityIndicator?.stopAnimating()
                    
                    self.location = location
                    
                    self.changeView()
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = (location.location?.coordinate)!
                    
                    self.mapView.addAnnotation(annotation)
                    self.mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpanMake(0.1, 0.1)), animated: true)
                }
                
            }
        }
    }
    
    @IBAction func submitLocation(sender: UIButton) {
        if linkTextField.text == "" {
            alertUser(title: "Empty link", message: "Link cannot be empty. Please provide a link to share.")
            return
        }
        
        ParseClient.sharedInstance().submitStudentLocation(location!, locationName: locationTextField.text!, link: linkTextField.text!) { (success, error) -> Void in
            if success {
                StudentLocations.sharedInstance().getStudentLocations { (success, error) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if success {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            self.alertUser(title: "Post successful", message: "But, getting updated student locations failed to download. Simply close this view and refresh.")
                        }
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.alertUser(title: "Post unsuccessful", message: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: PostInformationViewController
    
    func changeView() {
        
        let navBar = navigationController?.navigationBar
        
        navBar?.barTintColor = UIColor.customLightBlueColor()
        navBar?.tintColor = UIColor.whiteColor()
        
        topContainer.backgroundColor = UIColor.customLightBlueColor()
        questionLabel.hidden = true
        linkTextField.hidden = false
        
        locationTextField.hidden = true
        mapView.hidden = false
        
        bottomContainer.alpha = 0.7
        findButton.hidden = true
        submitButton.hidden = false
        
    }
    
    // MARK: Text Field Delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            alertUser(title: "Empty location", message: "Provide a location to find on the map.")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

}
