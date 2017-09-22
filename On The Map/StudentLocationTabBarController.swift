//
//  StudentLocationTabBarController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 9/5/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

// MARK: Student Location Tab Bar Controller
class StudentLocationTabBarController: UITabBarController, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    //static var studentInformation: [StudentInformation] = [StudentInformation]()
    static var studentInformation =  StudentInformation.sharedInstance()
    
    var overwriting = false
    
    // MARK: Actions
    @IBAction func logoutAndExit(_ sender: UIBarButtonItem) {
        
        // Logout of Udacity and Facebook
        setUIEnabled(false)
        startAnimating()
        logoutAndExit()

        
    }
    
    @IBAction func reloadStudentList(_ sender: UIBarButtonItem) {
        
        // Refresh
        setUIEnabled(false)
        startAnimating()
        getStudentsInformation()
    }
    
    @IBAction func addStudentInformation(_ sender: UIBarButtonItem) {
        
        // Get student name and present student information view
        setUIEnabled(false)
        startAnimating()
        
        for student in StudentLocationTabBarController.studentInformation {
            if student.uniqueKey == UdacityAPIMethods.sharedInstance().userID {
                overwriting = true
                //overwriteLocation()
                print("**********\(student.objectId)")
                LocationViewController.objID = student.objectId
                print("**********\(LocationViewController.objID)")
                
                print("/////////////////\(student.uniqueKey)")
                print("/////////////////\(UdacityAPIMethods.sharedInstance().userID!)")
                
                break
                
            }
        }
        if overwriting == true {
            overwriteLocation()
        } else {
            overwriting = false
            getStudentNameAndExit()
            
        }

        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Initialize
        setUIEnabled(true)
        getStudentsInformation()
        startAnimating()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        stopAnimating()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopAnimating()
    }
    
    
    
    // MARK: Class Functions
    
    func logoutAndExit() {
        
        // Chain completion handlers for each request so that they run one after the other
        logoutOfUdacity() { (success, error) in
            
            // Success: logged out of Udacity
            if success {
                self.logoutOfFacebook() { (success, error) in
                    
                    // Success: logged out of Facebook
                    if success {
                        
                        // Exit
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.displayError(Constants.ErrorMessage.logoutStatus.title.description, error)
                    }
                }
            } else {
                self.displayError(Constants.ErrorMessage.logoutStatus.title.description, error)
            }
        }
    }
    
    func logoutOfUdacity(completionHandlerForUdacityLogout: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Logout of Udacity
        UdacityAPIMethods.sharedInstance().deleteSession() { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    completionHandlerForUdacityLogout(true, nil)
                } else {
                    completionHandlerForUdacityLogout(false, error)
                }
            }
        }
    }
    
    func logoutOfFacebook(completionHandlerForFacebookLogout: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Logout of Facebook
        //if (FBSDKAccessToken.current() != nil) {
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        //}
        
        completionHandlerForFacebookLogout(true, nil)
    }
    
    func getStudentsInformation() {
        
        // Get current information
        ParseAPIMethods.sharedInstance().getStudentsInformation { (success, error, studentInformation) in
            performUIUpdatesOnMain {
                if success {
                    if let studentInformation = studentInformation {
                        StudentLocationTabBarController.studentInformation = studentInformation
                        ListViewController.studentTableView.reloadData()
                        MapViewController().reloadMapView()
                        self.setUIEnabled(true)
                        self.stopAnimating()
                    } else {
                        self.displayError(Constants.ErrorMessage.accessStatus.title.description, error)
                    }
                } else {
                    self.displayError(Constants.ErrorMessage.accessStatus.title.description, error)
                }
            }
        }
    }
    
    func getStudentNameAndExit() {
        
        // Get student name
        UdacityAPIMethods.sharedInstance().getStudentName { (success, error) in
            performUIUpdatesOnMain {
                if success {
                    
                    // Success: present student information view
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "Location Controller") as! LocationViewController
                    self.present(controller, animated: true, completion: nil)
                } else {
                    self.displayError(Constants.ErrorMessage.accessStatus.title.description, error)
                }
            }
        }
    }
    
    func displayError(_ title: String?, _ message: String?) {
        
        // Reset UI
        setUIEnabled(true)
        stopAnimating()
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func overwriteLocation() {
        
        let alert = UIAlertController(title: "Overwrite", message: "You Have Already Posted A Student Location.  Would You Like To Overwrite Your Current Location? ", preferredStyle: .alert)
        let overwrite = UIAlertAction(title: "Overwrite", style: .destructive, handler: { (action: UIAlertAction!) in

            self.getStudentNameAndExit()
            
        
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        })
        
        alert.addAction(overwrite)
        alert.addAction(cancel)
        

        self.present(alert, animated: true, completion: nil)
       
        
        
    
    }
}

// MARK: - StudentLocationTabBarController (Configure UI)
private extension StudentLocationTabBarController {
    
    func setUIEnabled(_ enabled: Bool) {
        
        // Enable or disable UI elements
        self.view.isUserInteractionEnabled = enabled
    }
    
    func startAnimating() {
        
        MapViewController.activityIndicator.startAnimating()
        ListViewController.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        
        MapViewController.activityIndicator.stopAnimating()
        ListViewController.activityIndicator.stopAnimating()
        
    }
}
