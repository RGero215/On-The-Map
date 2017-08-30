//
//  API.swift
//  On The Map
//
//  Created by Ramon Geronimo on 8/29/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import Foundation


enum Domain: String {
    case Parse = "https://parse.udacity.com/parse/classes/StudentLocation"
    case Udacity = "https://www.udacity.com/api/session"
}

func Error(code: Int, error: String, domain: String) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: error]
    return NSError(domain: domain, code: code, userInfo: userInfo)
}

struct API {
    
    let domain: Domain
    
    init(domain: Domain) {
        self.domain = domain
    }
    
    func get(data: String?, handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let url: String
        
        if domain == .Udacity {
            url = "https://www.udacity.com/api/users/\(data!)"
        } else {
            url = domain.rawValue + "?limit=100&order=-updatedAt".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        request.httpMethod = "GET"
        Header(request: request)
        
        Task(request: request, handler: handler)
    }
    
    func post(body: String, handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: domain.rawValue)! as URL)
        
        request.httpMethod = "POST"
        Header(request: request)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        Task(request: request, handler: handler)
    }
    
    func put(objectId: String, body: String, handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: domain.rawValue + objectId)! as URL)
        
        request.httpMethod = "PUT"
        Header(request: request)
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        Task(request: request, handler: handler)
    }
    
    func delete(handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: domain.rawValue)! as URL)
        
        let cookieStorage = HTTPCookieStorage.shared
        
        let xsrfCookie = cookieStorage.cookies?.filter {
            $0.name == "XSRF-TOKEN"
            }.first
        
        guard xsrfCookie != nil else {
            handler(nil, Error(code: 0, error: "No cookie found", domain: "API"))
            return
        }
        
        request.setValue(xsrfCookie?.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        
        request.httpMethod = "DELETE"
        Header(request: request)
        
        Task(request: request, handler: handler)
    }
    
    private func Header(request: NSMutableURLRequest) {
        switch domain {
        case .Parse:
            request.addValue(Constants.Parse.ApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.Parse.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        case .Udacity:
            break
        }
    }
    
    private func Task(request: NSMutableURLRequest, handler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                handler(nil, Error(code: 0, error: "Data task error", domain: "API"))
                return
            }
            
            guard let invalidCredentials = (response as? HTTPURLResponse)?.statusCode, invalidCredentials != 403 else {
                handler(nil, Error(code: 403, error: "Response status code 403", domain: "API"))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                handler(nil, Error(code: 200, error: "Response status code not 2xx", domain: "API"))
                return
            }
            
            guard data != nil else {
                handler(nil, Error(code: 204, error: "No data recieved from the server", domain: "API"))
                return
            }
            
            let newData: Data?
            
            if self.domain == .Udacity {
                let range = Range(5..<data!.count)
                newData = data?.subdata(in: range) /* subset response data! */
            } else {
                newData = data
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments)
                handler(parsedData as AnyObject, nil)
            } catch {
                handler(nil, Error(code: 1, error: "Cannot parse JSON data", domain: "API"))
                return
            }
            
        }
        
        task.resume()
    }
}
