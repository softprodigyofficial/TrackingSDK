//
//  NetworkManager.swift
//  Megafan
//
//  Created by MSS Softprodigy on 07/03/18.
//  Copyright © 2018 MSS Softprodigy. All rights reserved.
//

import UIKit
import CoreTelephony
import AdSupport
import SystemConfiguration.CaptiveNetwork


enum Result {
    case success
    case failure
}

class NetworkManager: NSObject {
    
    // call api method
    public static func callAPI(apiRequest: String, apiQuery: [[String: Any]]?, failed: ((_ error: String) -> Void)? = nil, completion: @escaping (_ jsonObject: String) -> ()) {
        
        guard let url = URL(string: Config.BASE_URL + apiRequest) else { completion(""); return }
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        
        var connectionType = String()
        var carrier = String()
        
        if  let wifiName = network().getSSID()
        {
            connectionType = "WIFI"
            carrier = wifiName
        }
        else
        {
            let networkInfo = CTTelephonyNetworkInfo()
            connectionType = String(describing: networkInfo.currentRadioAccessTechnology)
            carrier = (networkInfo.subscriberCellularProvider?.carrierName)!
        }
        
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        
        let apikey = TrackingSDK.sharedInstance.apiKey
        
        var IDFA = String()
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            IDFA = String(describing: ASIdentifierManager.shared().advertisingIdentifier) }
        
        let headers : [String : String] = ["device-type" : "1",
                                           "app-version" : (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String!)!,
                                           "connection-type":connectionType,
                                           "country":NSLocale.current.regionCode!,
                                           "os-version" : UIDevice.current.systemVersion,
                                           "device-name" : UIDevice.current.name,
                                           "device-manufacturer" : "Apple",
                                           "timezone" : "\(TimeZone.current.identifier)",
            "idfa" : IDFA,
            "idfv": idfv!,
            "carrier" : carrier,
            "Cache-Control":  "no-cache",
            "Content-Type": "application/json",
            "Authorization": "Bearer "+"\(apikey)"]
        
        print(headers)
        
        request.allHTTPHeaderFields = headers
        
        if apiQuery != nil {
            
            request.httpMethod = "POST"
            let data = (try? JSONSerialization.data(withJSONObject: apiQuery ?? [:], options: .prettyPrinted)) ?? Data()
            request.httpBody = data
            debugPrint(data)
        }
        else {
            request.httpMethod = "GET"
        }
        
        debugPrint("url: \(url)") // debug url
        debugPrint("apiQuery: \(String(describing: apiQuery))")
        debugPrint("allHTTPHeaderFields: \(String(describing: request.allHTTPHeaderFields))")
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            debugPrint(request)
            if let response = response as? HTTPURLResponse {
                if  response.statusCode == 202
                {
                    print(data!)
                    print(response)
                    let statuscode = response.statusCode
                    print("Success")
                }
                
                if (error != nil) {
                    print(error?.localizedDescription ?? "")
                    completion("")
                } else
                {
                    if data != nil {
                        print("String: \(String(describing: String(data: data!, encoding: .utf8)))")
                        
                        if let string = String(data: data!, encoding: .utf8)  {
                            completion(string)
                        }
                        else {
                            do {
                                if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Any] {
                                    print(json)
                                    completion("")
                                }
                            }
                            catch {
                                print(error)
                                completion("")
                            }
                        }
                    }
                    else {
                        completion("")
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- event track api
    public static func eventTrack(appPackageName: String,timestamp: TimeInterval,eventType: String,eventKey: String,eventValue: String,sessionId: String, fromEvent:String, completion: @escaping (_ message: String) -> ()) {
        //var query = [String : Any]()
        var query : [String : Any] = ["appPackageName" : appPackageName,
                                      "timestamp" : timestamp,
                                      "eventType":eventType,
                                      "eventKey":eventKey,
                                      "eventValue" : eventValue,
                                      "sessionId" : sessionId]
        if sessionId.isEmpty {
            query.removeValue(forKey: "sessionId")
        }
        if sessionId.isEmpty && eventValue.isEmpty && eventKey.isEmpty {
            query.removeValue(forKey: "eventValue")
            query.removeValue(forKey: "eventKey")
            
        }
        if fromEvent == "sessionStart" {
            query.removeValue(forKey: "eventValue")
            query.removeValue(forKey: "eventKey")
        }
        
        var yourArray = [[String : Any]]()
        yourArray.append(query)
        
        print("Request Parameters: \(yourArray)")
        // call api method
        NetworkManager.callAPI(apiRequest: Config.event, apiQuery: yourArray) { (response) in
            debugPrint("response: \(response)") // debug response
            completion("")
        }
    }
}

//get wifi network
class network : NSObject {
    
    func getSSID() -> String? {
        
        let interfaces = CNCopySupportedInterfaces()
        if interfaces == nil {
            return nil
        }
        
        let interfacesArray = interfaces as! [String]
        if interfacesArray.count <= 0 {
            return nil
        }
        
        let interfaceName = interfacesArray[0] as String
        let unsafeInterfaceData =     CNCopyCurrentNetworkInfo(interfaceName as CFString)
        if unsafeInterfaceData == nil {
            return nil
        }
        
        let interfaceData = unsafeInterfaceData as! Dictionary <String,AnyObject>
        print(interfaceData)
        return interfaceData["SSID"] as? String
    }
}
