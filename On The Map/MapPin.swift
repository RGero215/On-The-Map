//
//  MapPin.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/29/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import Foundation


import UIKit

struct MapPin {
    
    static var MapPins = [MapPin]()
    
    let firstName: String
    let lastName: String
    
    let latitude: Float
    let longitude: Float
    
    let mapString: String
    let mediaUrl: String
    
    let objectId: String
    let uniqueKey: String
    
    init(firstName: String, lastName: String, latitude: Float, longitude: Float, mapString: String, mediaUrl: String, objectId: String, uniqueKey: String) {
        self.firstName = firstName
        self.lastName = lastName
        
        self.latitude = latitude
        self.longitude = longitude
        
        self.mapString = mapString
        self.mediaUrl = mediaUrl
        
        self.objectId = objectId
        self.uniqueKey = uniqueKey
    }
    
    init(pin: [String: AnyObject]) {
        
        if let _firstName = pin["firstName"] as? String {
            firstName = _firstName
        } else {
            firstName = ""
        }
        
        if let _lastName = pin["lastName"] as? String {
            lastName = _lastName
        } else {
            lastName = ""
        }
        
        
        if let _latitude = pin["latitude"] as? Float {
            latitude = _latitude
        } else {
            latitude = 0
        }
        
        if let _longitude = pin["longitude"] as? Float {
            longitude = _longitude
        } else {
            longitude = 0
        }
        
        
        if let _mapString = pin["mapString"] as? String {
            mapString = _mapString
        } else {
            mapString = ""
        }
        
        if let _mediaUrl = pin["mediaURL"] as? String {
            mediaUrl = _mediaUrl
        } else {
            mediaUrl = ""
        }
        
        
        if let _objectId = pin["objectId"] as? String {
            objectId = _objectId
        } else {
            objectId = ""
        }
        
        if let _uniqueKey = pin["uniqueKey"] as? String {
            uniqueKey = _uniqueKey
        } else {
            uniqueKey = ""
        }
        
    }
    
    static func getPins() -> [MapPin] {
        return MapPins
    }
    
    static func setPins(mapPins: [MapPin]) {
        MapPins = mapPins
    }
    
    static func downloadPins() {
        let api = API(domain: .Parse)
        api.get(data: nil, handler: {
            if $0.0 != nil {
                let result = $0.0 as! [String: AnyObject]
                setPins(mapPins: try! Parser.parseMapPins(json: result)!)
                NotificationCenter.default.post(name: Notification.Name("ReloadData"), object: nil)
                
            } else {
                NotificationCenter.default.post(name: Notification.Name("ReloadDataError"), object: nil)
                
            }
        })
    }
    
    static func downloadPin() {
        let api = API(domain: .Parse)
        api.get(data: nil, handler: {
            if $0.0 != nil {
                let result = $0.0 as! [String: AnyObject]
                setPins(mapPins: try! Parser.parseMapPins(json: result)!)
                NotificationCenter.default.post(name: Notification.Name("ReloadData"), object: nil)
                
            } else {
                NotificationCenter.default.post(name: Notification.Name("ReloadDataError"), object: nil)
                
            }
        })
    }
}
