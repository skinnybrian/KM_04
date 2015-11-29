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
    case all = "/tsukkomi_all" //GET
    case analysis = "/analysis" //POST
    //case user_photo = "/update2"
    
    func url() -> String {
        
        return Config.baseURLString + self.rawValue
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
    
    
//    static func invite(information_id: String,user_id: String , completionHandler:(Int) -> (), errorHandler: (ErrorType?,Int) -> ()) {
//        APIConnection.siteInfoWithMethod(.POST, url: "", params: ["user_id":user_id,"information_id":information_id,"device_token":""], completionHandler: { (json) -> () in
//            
//            completionHandler(7)
//            }) { (error, status) -> () in
//                errorHandler(error,status)
//        }
//        
//    }
    
    
    static func postTsukkomi(xml:NSMutableString,completionHandler:(String,String) -> ()){
        APIConnection.siteInfoWithMethod(.POST, url: "", params: ["xml":xml], completionHandler: { (json) -> () in
            
            completionHandler(json["tsukkomi"].stringValue,json["id"].stringValue)
            }) { (error, status) -> () in
                //errorHandler(status)
        }
        
    }
    
    static func getVoice(completionHandler:([String],String) -> ()){
        APIConnection.siteInfoWithMethod(.GET , url: "", params: nil, completionHandler: { (json) -> () in
            var array: [String] = []
            
            for file in json["voice"].arrayValue {
                array.append(file.stringValue)
            }
            
            
            
            completionHandler(array,json["base_url"].stringValue)
            }) { (error, status) -> () in
                //errorHandler(error,status)
        }
        
    }
    
}
