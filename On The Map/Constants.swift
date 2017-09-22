//
//  Constants.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/28/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import Foundation
import UIKit

// MARK: Constants
struct Constants {

    // MARK: Error Description
    enum ErrorMessage: Error {
        
        // Title
        case loginStatus
        case logoutStatus
        case accessStatus
        case updateStatus
        case general
        
        var title: String {
            switch self {
            case .loginStatus:
                return "Login Failed"
            case .logoutStatus:
                return "Logout Failed"
            case .accessStatus:
                return "Access Failed"
            case .updateStatus:
                return "Update Failed"
            case .general:
                return "Failed"
            default:
                return ""
            }
        }
        
        // Description
        case emptyCredentials
        case invalidCredentials
        case sessionRequestError
        case sessionRequestResponseError
        case sessionRequestDataError
        case parseDataError
        case sessionID
        case userID
        case getStudentsInformationError
        case openMediaURL
        case userInfo
        case emptyInput
        case notMediaURL
        case invalidMediaURL
        case invalidLocation
        case createNewStudentLocationError
        
        var description: String {
            switch self {
            case .emptyCredentials:
                return "Empty Email or Password"
            case .invalidCredentials:
                return "Invalid Email or Password"
            case .sessionRequestError:
                return "The Internet connection appears to be offline."
            case .sessionRequestResponseError:
                return "Your request returned a status code other than 2xx"
            case .sessionRequestDataError:
                return "No data was returned by the request"
            case .parseDataError:
                return "Could not parse the data as JSON"
            case .sessionID:
                return "User Session Not Created"
            case .userID:
                return "User ID Not Found"
            case .getStudentsInformationError:
                return "Could Not Get Students Information"
            case .openMediaURL:
                return "Invalid URL"
            case .userInfo:
                return "User Info Not Found"
            case .emptyInput:
                return "Empty Student Location or Media URL"
            case .notMediaURL:
                return "Not an URL"
            case .invalidMediaURL:
                return "URL Must Start With http(s)://"
            case .invalidLocation:
                return "No Matching Addresses Found"
            case .createNewStudentLocationError:
                return "Could Not Create New Student Location"
            default:
                return ""
            }
        }
    }
}


