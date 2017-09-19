//
//  MapViewController.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/26/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit



class MapViewController: UIViewController, MKMapViewDelegate {
    // MARK: Properties
    static var mapView: MKMapView = MKMapView()
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapViewController.mapView = mapView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidLoad), name:Notification.Name("ReloadData"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ReloadData"), object: nil)
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Add custom pin & callout accessory view to the map
        let Identifier = "LocationPin"
        var annotationView: MKAnnotationView?
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier)
            annotationView?.image = UIImage(named: "Map Pin")
            annotationView?.canShowCallout = true
            
            let rightButton = UIButton(type: .custom)
            rightButton.frame = CGRect(x: 0.0, y: 0.0, width: 45.0, height: 45.0)
            rightButton.setImage(UIImage(named: "Right Arrow"), for: .normal)
            rightButton.adjustsImageWhenHighlighted = false
            annotationView?.rightCalloutAccessoryView = rightButton
            //annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // Dismiss annotation
        let annotation = view.annotation
        mapView.deselectAnnotation(annotation, animated: true)
        
        if control == view.rightCalloutAccessoryView {
            let url = URL(string: (view.annotation?.subtitle!)!)
            
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
    }
    
    // MARK: Class Functions
    func reloadMapView() {
        
        let studentsLocation = StudentLocationTabBarController.studentInformation
        var annotations = [MKPointAnnotation]()
        
        // Rebuild latest map annotations
        for studentLocation in studentsLocation {
            let latitude = CLLocationDegrees(studentLocation.latitude)
            let longitude = CLLocationDegrees(studentLocation.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let firstName: String = studentLocation.firstName
            let lastName: String = studentLocation.lastName
            var fullName: String = ((firstName + " " + lastName).trimmingCharacters(in: .whitespaces)).capitalized
            fullName = (fullName != "") ? fullName : "[No Name]"
            
            var url: String = (studentLocation.mediaURL).trimmingCharacters(in: .whitespaces).lowercased()
            url = (url != "") ? url : "[No Media URL]"
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = fullName
            annotation.subtitle = url
            
            annotations.append(annotation)
        }
        
        // Remove and re-add annotations
        MapViewController.mapView.removeAnnotations(MapViewController.mapView.annotations)
        MapViewController.mapView.addAnnotations(annotations)
    }
    
    func displayError(_ title: String?, _ message: String?) {
        
        // Display Error
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
