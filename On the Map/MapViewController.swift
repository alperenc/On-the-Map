//
//  MapViewController.swift
//  On the Map
//
//  Created by Alp Eren Can on 19/10/15.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    let studentLocations = StudentLocations.sharedInstance()
    var annotations =  [MKPointAnnotation]()
    
    var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = view.center
        mapView.addSubview(activityIndicator!)
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
    
    // MARK: MapViewController
    
    func fetchStudentLocations(refresh refresh: Bool) {
        
        if studentLocations.locations.count == 0 || refresh {
            activityIndicator?.startAnimating()
            
            mapView.removeAnnotations(annotations)
            annotations.removeAll()
            
            studentLocations.getStudentLocations() { (success) -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.activityIndicator?.stopAnimating()
                    
                    if success {
                        self.createAnnotations(self.studentLocations.locations)
                    } else {
                        let alertController = UIAlertController(title: "Download failed!", message: "Student locations failed to download. Try again!", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        } else {
            createAnnotations(studentLocations.locations)
        }
    }
    
    func createAnnotations(locations: [StudentInformation]) {
        
        for info in locations {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
            annotation.title = "\(info.firstName) \(info.lastName)"
            annotation.subtitle = "\(info.mediaURL)"
            
            annotations.append(annotation)
            
        }
        
        mapView.addAnnotations(annotations)
        
    }
    
    
    // MARK: Map View Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "studentInfo"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.customOrangeColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
}

