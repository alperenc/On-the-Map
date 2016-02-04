//
//  LoginViewController.swift
//  On the Map
//
//  Created by Alp Eren Can on 19/10/15.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var activityIndicator: UIActivityIndicatorView?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        configureTextField(usernameTextField, tintColor: UIColor.customDarkOrangeColor())
        configureTextField(passwordTextField, tintColor: UIColor.customDarkOrangeColor())
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = view.center
        view.addSubview(activityIndicator!)
    }
    
    // MARK: Actions
    
    @IBAction func login(sender: UIButton) {
        
        // Check for username and password
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            alertUser(title: "Empty username or password", message: "Please make sure you entered your email and password.")
            return
        }
        
        activityIndicator?.startAnimating()
        
        UdacityClient.sharedInstance().login(username: username, password: password) { (success, error) in
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.activityIndicator?.stopAnimating()
                
                if success {
                    self.completeLogin()
                } else {
                    if let errorCode = error?.code where errorCode == 0 {
                        self.alertUser(title: "Wrong username or password", message: "Please make sure you entered correct email and password combination.")
                    } else {
                        self.alertUser(title: "Network connection failed", message: (error?.localizedDescription)!)
                    }
                }
            }
        }
    }

    @IBAction func signUp(sender: UIButton) {
        
        // Open Udacity's sign up page in Safari
        UIApplication.sharedApplication().openURL(NSURL(string: UdacityClient.Constants.SignUpURL)!)
    }
    
    // MARK: LoginViewController
    
    func completeLogin() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        presentViewController(controller, animated: true, completion: nil)
    }

}

extension UIViewController {
    
    // MARK: Show alert to user
    
    func alertUser(title title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Configure text field
    
    func configureTextField(textField: UITextField, tintColor: UIColor) {
        
        textField.tintColor = tintColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 20, textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .Always
        
    }
}
