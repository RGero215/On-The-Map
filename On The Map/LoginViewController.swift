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
    
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
   let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        if emailTextField.text?.characters.count != 0 && passwordTextField.text?.characters.count != 0 {
            let email = emailTextField.text
            let password = passwordTextField.text
            let credentials = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(password!)\"}}"
            
            let api = API(domain: .Udacity)
            api.post(body: credentials, handler: {
                if let result = $0.0 {
                    let info = try! Parser.parseSession(json: result)
                    
                    if info.0 {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.uniqueKey = info.1
                        
                        DispatchQueue.main.async(execute: {
                            let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "Navigation Controller")
                            self.present(navigationController!, animated: true, completion: nil)
                        })
                    } else {
                        print(info.1)
                    }
                    
                } else {
                    if $0.1?.code == 403 {
                        DispatchQueue.main.async(execute: {
                            let alertController = UIAlertController(title: "Invalid Credentials", message: "The entered email or password is incorrect", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            let alertController = UIAlertController(title: "Failure to Connect", message: "Could not connect to the server", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                }
            })
        } else {
            let alertController = UIAlertController(title: "Blank Fields", message: "Please enter email address and password", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func facebookLogin(_ sender: UIButton) {
        
        
    }
    
    
    
    
}

    
    



