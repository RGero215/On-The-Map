//
//  ViewController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/20/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var accessToken = ""
    
   let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email",  "public_profile"]
    
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.center = view.center
        loginButtonDesign()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        
//        facebookLogin()
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        facebookLogin()
    }
    
    
    
    
    func loginButtonDesign() {
        let verticalPosition: CGFloat = 4.0
        let positionOfFrame = view.center.y - view.center.y / verticalPosition
        let positionX = view.center.x - (loginButton.frame.width + 60) / 2
        let positionY = view.center.y - (loginButton.frame.height + 15) / 2
        let finalPositionY = positionY + positionOfFrame
        
        let widthOfFBButton = loginButton.frame.width + 60
        let heightOfFBButton = loginButton.frame.height + 15
        
        loginButton.frame = CGRect(x: positionX, y: finalPositionY, width: widthOfFBButton, height: heightOfFBButton)
        view.addSubview(loginButton)
    }

    
    
    @IBAction func loginButton(_ sender: UIButton) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayError(Constants.ErrorMessage.loginStatus.title.description, Constants.ErrorMessage.emptyCredentials.description)
        } else {
            
            // Step-1: Set the parameters
            let parameters: [String:String] = [
                Udacity.JSONBodyKeys.Username: emailTextField.text!,
                Udacity.JSONBodyKeys.Password: passwordTextField.text!
            ]
            
            // Authenticate with Udacity login
            UdacityAPIMethods.sharedInstance().loginWithID(parameters, authentication: Udacity.JSONBodyKeys.UdacityLogin) { (success, error) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        self.displayError(Constants.ErrorMessage.loginStatus.title.description, error)
                    }
                }
            }
        }

        
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        
        // Open Udacity signup page in Safari
        if let url = URL(string: Udacity.Constants.SignUpURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    

    
    func facebookLogin() {


        // Step-1: Set the parameters
        
        if let token = FBSDKAccessToken.current() {
                    accessToken = token.tokenString
    
        }
        let parameters: [String:String] = [
        Udacity.JSONBodyKeys.AccessToken: self.accessToken
        ]
        let authentication = Udacity.JSONBodyKeys.FacebookLogin
         //print("********************/////////////************\(parameters)")
        // Authenticate with Udacity login
        UdacityAPIMethods.sharedInstance().loginWithID(parameters, authentication: authentication ) { (success, error) in
            print("********************/////////////************\(authentication)")
            print("********************/////////////************\(parameters)")
            performUIUpdatesOnMain {
                if error != nil {
                    self.displayError(Constants.ErrorMessage.loginStatus.title.description, error)
                } else {
                   
                    self.completeLogin()
                }
            }
        }
    }
    
    
    
    // MARK: Class Functions
    func completeLogin() {
        
        
        
        //clearTextFields()
        
        // Present student location views
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "Navigation Controller") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
    func displayError(_ title: String?, _ message: String?) {
        

        stopAnimating()
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func startAnimating() {
        
        LoginViewController.activityIndicator.startAnimating()
        self.view.alpha = 0.75
    }
    
    func stopAnimating() {
        
        LoginViewController.activityIndicator.stopAnimating()
        self.view.alpha = 1.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
}

    
    



