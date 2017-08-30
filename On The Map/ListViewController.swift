//
//  ListViewController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/26/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

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
    
    

}

extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapPin.getPins().count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pin = MapPin.getPins()[indexPath.row]
        let app = UIApplication.shared
        let url = URL(string: pin.mediaUrl)
        app.open(url!, options: [:], completionHandler: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pin = MapPin.getPins()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        cell.textLabel?.text = pin.firstName + " " + pin.lastName
        
        return cell
    }
}
