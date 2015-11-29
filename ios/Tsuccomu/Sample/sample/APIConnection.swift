//
//  APIConnection.swift
//  Tsuccomu
//
//  Created by shogo okamuro on 11/28/15.
//  Copyright © 2015 speechrec. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON


enum API: String {
    case photo = "/photos"
    case user_photo = "/update2"
    
    func url() -> String {
        
        return Config.baseURLString + "/api/" + Config.api_version + self.rawValue
    }
    
    
}

class APIConnection: NSObject {
    static func siteInfoWithMethod(type: Alamofire.Method, url: String, params: [String:AnyObject]?, completionHandler: (JSON) -> (), errorHandler: (ErrorType?,Int) -> ()) -> () {
        print("connectove!z")
        Alamofire.request(type,  url, parameters: params).responseSwiftyJSON({(request,response,json,error) in
            guard let res: NSHTTPURLResponse = response else { return }
            if res.statusCode < 200 || res.statusCode >= 300 {
                print("error! code = " + String(res.statusCode))
                errorHandler(error,res.statusCode)
                return
            }
            print("success!")
            print(json)
            completionHandler(json)
            
        })
    }
    
    
    static func invite(information_id: String,user_id: String , completionHandler:() -> (), errorHandler: (ErrorType?,Int) -> ()) {
        APIConnection.siteInfoWithMethod(.POST, url: "", params: ["user_id":user_id,"information_id":information_id,"device_token":""], completionHandler: { (json) -> () in
            
            completionHandler()
            }) { (error, status) -> () in
                errorHandler(error,status)
        }
        
    }
}
