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

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations: [MKPointAnnotation] = MapPin.getPins().map {
            let latitude = CLLocationDegrees($0.latitude)
            let longitude = CLLocationDegrees($0.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let firstName = $0.firstName
            let lastName = $0.lastName
            let title = "\(firstName) \(lastName)"
            
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.subtitle = $0.mediaUrl
            annotation.coordinate = coordinate

        
            return annotation
            
        }
        

        
        mapView.addAnnotations(annotations)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidLoad), name:NSNotification.Name(rawValue: "ReloadData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReloadData"), object: nil)
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let string = view.annotation?.subtitle! {
                let url = URL(string: string)
                app.open(url!, options: [:], completionHandler: nil)
                
            }
        }
    }    

}
