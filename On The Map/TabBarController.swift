//
//  TabBarController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/29/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import Foundation

import UIKit

class TabBarController: UITabBarController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataError), name:NSNotification.Name(rawValue: "ReloadDataError"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReloadDataError"), object: nil)
    }
    
    override func viewDidLoad() {
        MapPin.downloadPins()
        
        getNames()
    }
    
    func getNames() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let uniqueKey = appDelegate.uniqueKey
        
        let api = API(domain: .Udacity)
        api.get(data: uniqueKey, handler: {
            if let result = $0.0 {
                let names = try! Parser.parseUserInfo(json: result)
                appDelegate.firstName = names.0
                appDelegate.lastName = names.1
            }
        })
    }
    
    func reloadDataError() {
        let alertController = UIAlertController(title: "Download Error", message: "Could not download the data", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
        let api = API(domain: .Udacity)
        api.delete(handler: {
            if $0.1 == nil {
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                print($0.1!)
            }
        })
    }
    
    @IBAction func refresh(sender: AnyObject) {
        MapPin.downloadPins()
    }
    
    @IBAction func pinOnTheMap(sender: AnyObject) {
        let locationViewController = storyboard?.instantiateViewController(withIdentifier: "Location Controller") as! LocationViewController
        present(locationViewController, animated: true, completion: nil)
    }
}
