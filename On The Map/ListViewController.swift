//
//  ListViewController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/26/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    static var studentTableView: UITableView = UITableView()
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var studentTableView: UITableView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidLoad), name:NSNotification.Name(rawValue: "ReloadData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReloadData"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentTableView.reloadData()
    }
    
    func displayError(_ title: String?, _ message: String?) {
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    

}

extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationTabBarController.studentInformation.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Initialize
        let cell = tableView.cellForRow(at: indexPath)
        let url = URL(string: (cell?.detailTextLabel?.text)!)
        
        // Guard if no URL was returned
        guard (url != nil) else {
            displayError(Constants.ErrorMessage.accessStatus.title.description, Constants.ErrorMessage.openMediaURL.description)
            return
        }
        
        // Display media link in Safari
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            displayError(Constants.ErrorMessage.accessStatus.title.description, Constants.ErrorMessage.openMediaURL.description)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Initialize
        let cell = studentTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let studentDetail = StudentLocationTabBarController.studentInformation[(indexPath as NSIndexPath).row]
        
        let firstName: String = studentDetail.firstName
        let lastName: String = studentDetail.lastName
        let fullName: String = ((firstName + " " + lastName).trimmingCharacters(in: .whitespaces)).capitalized
        
        let url: String = (studentDetail.mediaURL).trimmingCharacters(in: .whitespaces).lowercased()
        
        // Present
        cell.textLabel!.text = (fullName != "") ? fullName : "[No Name]"
        cell.detailTextLabel!.text = (url != "") ? url : "[No Media URL]"
        cell.imageView!.image = UIImage(named: "Map Pin")
        
        return cell
    }
}
