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
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.center = view.center
        view.addSubview(activityIndicator!)
    }
    
    // MARK: Actions
    
    @IBAction func login(_ sender: UIButton) {
        
        // Check for username and password
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            alertUser(title: "Empty username or password", message: "Please make sure you entered your email and password.")
            return
        }
        
        activityIndicator?.startAnimating()
        
        UdacityClient.sharedInstance().login(username: username, password: password) { (success, error) in
            
            DispatchQueue.main.async { () -> Void in
                self.activityIndicator?.stopAnimating()
                
                if success {
                    self.completeLogin()
                } else {
                    if let errorCode = error?.code, errorCode == 0 {
                        self.alertUser(title: "Wrong username or password", message: "Please make sure you entered correct email and password combination.")
                    } else {
                        self.alertUser(title: "Network connection failed", message: (error?.localizedDescription)!)
                    }
                }
            }
        }
    }

    @IBAction func signUp(_ sender: UIButton) {
        
        // Open Udacity's sign up page in Safari
        UIApplication.shared.openURL(URL(string: UdacityClient.Constants.SignUpURL)!)
    }
    
    // MARK: LoginViewController
    
    func completeLogin() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }

}

extension UIViewController {
    
    // MARK: Show alert to user
    
    func alertUser(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Configure text field
    
    func configureTextField(_ textField: UITextField, tintColor: UIColor) {
        
        textField.tintColor = tintColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
    }
}
