//
//  LocationViewController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/26/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, UITextFieldDelegate {
    
    var mapString: String?
    var coordinate: CLLocationCoordinate2D?
    
    let submitButton = UIButton(type: .system)
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var topLabel: UILabel!
   
    @IBOutlet weak var bottomLabel: UILabel!
    
    
    
    var origin : UIViewController!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "Where are you\nStudying\nToday?"
        textView.textAlignment = .center
        
        textField.delegate = self
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor(red: 2/255, green: 179/255, blue: 228/255, alpha: 1)
        //searchButton.setTitle("Find on the Map", for: .normal)
        //submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }

    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func find(_ sender: UIButton) {
        
        if searchButton.titleLabel?.text == "Submit" && textField.text?.characters.count != 0 {
            submit()
            print("Submitted")
        } else if textField.text?.characters.count != 0 {
            
            mapString = textField.text
            let searchText = mapString!
            
            // Remove all views
            stackView.arrangedSubviews.forEach {
                stackView.removeArrangedSubview($0)
            }
            
            // Hide Label
            //bottomLabel.isHidden = true
            bottomLabel.backgroundColor = UIColor(white: 1, alpha: 0.5)
            //searchButton.isHidden = true
            textView.isHidden = true
            // top label change color
            topLabel.isHidden = true
            cancelButton.titleLabel?.textColor = .white
            
            
            // Add text field view
            textField.text = ""
            textField.keyboardType = .URL
            textField.placeholder = "Enter a Link to Share Here"
            
            let titleConstraints: [NSLayoutConstraint] = [
                NSLayoutConstraint(item: textField, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: textField, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 60),
                NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            ]
            self.view.addConstraints(titleConstraints)
            
            stackView.addArrangedSubview(textField)
            
            // Add map view
            let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            stackView.addArrangedSubview(mapView)
            
            self.view.addConstraint(
                
                NSLayoutConstraint(
                    item: mapView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: textField,
                    attribute: .bottom,
                    multiplier: 1.0,
                    constant: 30
            ))
            
            
            // Add button view
            
            //submitButton.setTitle("Submit", for: .normal)
            //stackView.addArrangedSubview(submitButton)
            searchButton.setTitle("Submit", for: .normal)
            
            
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.center = view.center
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            // Create search request
            let request = MKLocalSearchRequest()
            request.region = mapView.region
            request.naturalLanguageQuery = searchText
            
            // Start search for location
            let search = MKLocalSearch(request: request)
            search.start {
                
                activityIndicator.stopAnimating()
                
                if $0.1 == nil {
                    guard let response = $0.0 else {
                        return
                    }
                    
                    let coordinate = response.mapItems.first?.placemark.coordinate
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate!
                    mapView.addAnnotation(annotation)
                    
                    let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate!, 5000, 5000)
                    let adjustedRedion = mapView.regionThatFits(viewRegion)
                    mapView.setRegion(adjustedRedion, animated: true)
                    
                    self.coordinate = coordinate
                } else {
                    let alertController = UIAlertController(title: "Location Error", message: "No such location found", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func submit() {
        if textField.text?.characters.count != 0 {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let uniqueKey = appDelegate.uniqueKey
            
            let firstName = appDelegate.firstName
            let lastName = appDelegate.lastName
            
            let mapString = self.mapString!
            let mediaUrl = textField.text!
            
            let latitude = Double(self.coordinate!.latitude)
            let longitude = Double(self.coordinate!.longitude)
            
            let body = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
            
            let api = API(domain: .Parse)
            api.post(body: body, handler: {
                if $0.1 == nil {
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "Post Successful", message: "Successfully posted your location", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                            MapPin.downloadPins()
                            print(MapPin.getPins().count)
                            self.dismiss(animated: true, completion: nil)
                        })
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        let alertController = UIAlertController(title: "Post Error", message: "Could not post the location", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    })
                }
            })
        }
    }

}
