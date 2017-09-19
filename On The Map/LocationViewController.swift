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

class LocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var parameters: [String:AnyObject] = [String:AnyObject]()
    
    static var mapString: String = String()
    static var latitude: Double = Double()
    static var longitude: Double = Double()
    static var mediaURL: String = String()
    static var objID: String = String()
    
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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        definesPresentationContext = true

        
        
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
            
        } else if textField.text?.characters.count != 0 {
            
            LocationViewController.mapString = textField.text!
            let searchText = LocationViewController.mapString
            
            
                            
            // Remove all views
            self.stackView.arrangedSubviews.forEach {
                self.stackView.removeArrangedSubview($0)
            }
            
            // Hide Label
            //bottomLabel.isHidden = true
            self.bottomLabel.backgroundColor = UIColor(white: 1, alpha: 0.5)
            //searchButton.isHidden = true
            self.textView.isHidden = true
            // top label change color
            self.topLabel.isHidden = true
            self.cancelButton.titleLabel?.textColor = .white
            
            
            // Add text field view
            self.textField.text = ""
            self.textField.keyboardType = .URL
            self.textField.placeholder = "Enter a Link to Share Here"
            self.textField.becomeFirstResponder()
            
            let titleConstraints: [NSLayoutConstraint] = [
                NSLayoutConstraint(item: self.textField, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.textField, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self.textField, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 60),
                NSLayoutConstraint(item: self.textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            ]
            self.view.addConstraints(titleConstraints)
            
            self.stackView.addArrangedSubview(self.textField)
            
            // Add map view
            let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.stackView.addArrangedSubview(mapView)
            
            self.view.addConstraint(
                
                NSLayoutConstraint(
                    item: mapView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: self.textField,
                    attribute: .bottom,
                    multiplier: 1.0,
                    constant: 30
            ))
            
            
            // Add button view
            
            
            self.searchButton.setTitle("Submit", for: .normal)
            
            
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
        
        
        
            //Create search request
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
                    LocationViewController.mapString = self.textField.text!
                    LocationViewController.latitude = coordinate!.latitude
                    LocationViewController.longitude = coordinate!.longitude
                    
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
    
    
    
    
    func submit() {
        let submitOption = StudentLocationTabBarController()
        if textField.text?.characters.count != 0 && submitOption.overwriting == true {
            
            MapViewController.mapView.deselectAnnotation(MapViewController.mapView.annotations[0], animated: true)
            
            // Success: verify URL and get media string
            self.getMediaURL() { (success, error) in
                if success {
                    print("========\(LocationViewController.mediaURL)")
                    self.setParameters()
                    print("*************************\(self.setParameters())")
                    // Success: present information posting view
                    ParseAPIMethods.sharedInstance().updateStudentLocation(self.parameters) { (success, error) in
                        print("*************************==========\(self.parameters)")
                        performUIUpdatesOnMain {
                            if success {
                            
                                let alertController = UIAlertController(title: "Post Successful", message: "Successfully posted your location", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                                    self.setAnnotation()
                                    self.dismiss(animated: true, completion: nil)
                                })
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                                
                                print("============= Overwrited")
                                
                            } else {
                                self.displayError(Constants.ErrorMessage.updateStatus.title.description, error)
                            }
                        }
                    }
                    
                
                } else {
                    self.displayError(Constants.ErrorMessage.general.title.description, error)
                }
            }
            
            
        } else if textField.text?.characters.count != 0 && submitOption.overwriting == false {
            
            MapViewController.mapView.deselectAnnotation(MapViewController.mapView.annotations[0], animated: true)
            // Success: verify URL and get media string
            self.getMediaURL() { (success, error) in
                if success {
                    self.setParameters()
                    // Add new location and media URL
                    ParseAPIMethods.sharedInstance().createNewStudentLocation(self.parameters) { (success, error) in
                        performUIUpdatesOnMain {
                            if success {
                                
                                let alertController = UIAlertController(title: "Post Successful", message: "Successfully posted your location", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                                    self.setAnnotation()
                                    self.dismiss(animated: true, completion: nil)
                                })
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                                
                                print("============= New Stundet Location")
                                
                            } else {
                                self.displayError(Constants.ErrorMessage.updateStatus.title.description, error)
                            }
                        }
                    }
                } else {
                    self.displayError(Constants.ErrorMessage.general.title.description, error)
                }
            }
        }
            
            
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    func displayError(_ title: String?, _ message: String?) {
        
        // Reset UI
        //setUIEnabled(true)
        //stopAnimating()
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) { handler -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func setParameters() {
        
        // Step-1: Set the parameters
        parameters = [
            Parse.JSONKeys.UniqueKey: UdacityAPIMethods.sharedInstance().userID as AnyObject,
            Parse.JSONKeys.FirstName: UdacityAPIMethods.sharedInstance().firstName as AnyObject,
            Parse.JSONKeys.LastName: UdacityAPIMethods.sharedInstance().lastName as AnyObject,
            Parse.JSONKeys.MapString: LocationViewController.mapString as AnyObject,
            Parse.JSONKeys.Latitude: LocationViewController.latitude as AnyObject,
            Parse.JSONKeys.Longitude: LocationViewController.longitude as AnyObject,
            Parse.JSONKeys.MediaURL: LocationViewController.mediaURL as AnyObject,
        ]

    }
    
    func setAnnotation() {
        
        // Set annotation
        let latitude = CLLocationDegrees(parameters[Parse.JSONKeys.Latitude] as! Double)
        let latitudeDelta: CLLocationDegrees = 1/180.0
        
        let longitude = CLLocationDegrees(parameters[Parse.JSONKeys.Longitude] as! Double)
        let longitudeDelta: CLLocationDegrees = 1/180.0
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        
        let coordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
        MapViewController.mapView.setRegion(coordinateRegion, animated: true)
        
        var address: String = (parameters[Parse.JSONKeys.MapString])!.trimmingCharacters(in: .whitespaces).capitalized
        address = (address != "") ? address : "[No Address]"
        
        var url: String = (parameters[Parse.JSONKeys.MediaURL])!.trimmingCharacters(in: .whitespaces).lowercased()
        url = (url != "") ? url : "[No Media URL]"
        
        // Add and display annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = address
        annotation.subtitle = url
        MapViewController.mapView.addAnnotation(annotation)
        MapViewController.mapView.selectAnnotation(MapViewController.mapView.annotations[0], animated: true)
    }

    
    func getMediaURL(completionHandlerForMediaURL: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let url = URL(string: textField.text!)
        
        // Guard if no URL was returned
        guard (url != nil) else {
            completionHandlerForMediaURL(false, Constants.ErrorMessage.notMediaURL.description)
            return
        }
        
        // Verify and save valid URL
        if UIApplication.shared.canOpenURL(url!) {
            LocationViewController.mediaURL = (url?.absoluteString)!
            
            completionHandlerForMediaURL(true, nil)
        } else {
            completionHandlerForMediaURL(false, Constants.ErrorMessage.invalidMediaURL.description)
        }
    }

}


