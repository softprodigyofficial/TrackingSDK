//
//  networkManagerTest.swift
//  TrackingSDKTests
//
//  Created by Surbhi Handa on 4/23/18.
//  Copyright © 2018 SoftProdigy. All rights reserved.

import XCTest
@testable import TrackingSDK
import CoreTelephony
import AdSupport
import SystemConfiguration.CaptiveNetwork

class networkManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // checkNetwork.init(NetworkManager.init())
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func test()
    {
        
        var IDFA = String()
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            IDFA = String(describing: ASIdentifierManager.shared().advertisingIdentifier)
        }
        
        let ticks = Date().ticks
        
        let time = "\(IDFA)\(ticks)"
        let stringConvertedToMD5 = time.MD5
        
        let promise = expectation(description: "Response: 202")
        let query : [String : Any] = ["appPackageName" : "com.info.sdk.TrackingSDK",
                                      "timestamp" : ticks,
                                      "eventType":"Traking Start",
                                      "eventKey":"App terminate",
                                      "eventValue" : "75766",
                                      "sessionId": stringConvertedToMD5]

        var yourArray = [[String : Any]]()
        yourArray.append(query)

        let url = URL(string: Config.BASE_URL+Config.event)
        
        let request = NSMutableURLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)

        request.httpMethod = "POST"
        let data = (try? JSONSerialization.data(withJSONObject: yourArray , options: .prettyPrinted)) ?? Data()
        request.httpBody = data
        debugPrint(data)
        
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        
        
        let headers : [String : String] = ["device-type" : "1",
                                           "app-version" : "1.0",
                                           "connection-type":"wifi",
                                           "country":NSLocale.current.regionCode!,
                                           "os-version" : UIDevice.current.systemVersion,
                                           "device-name" : UIDevice.current.name,
                                           "device-manufacturer" : "Apple",
                                           "timezone" : "\(TimeZone.current.identifier)",
                                           "idfa" : IDFA,
                                           "idfv": idfv!,
                                           "carrier" : "Airtel",
                                           "Cache-Control":  "no-cache",
                                           "Content-Type": "application/json",
                                           "Authorization": "Bearer "+"871049b2-8363-4a08-b2af-82904b26675b"]
        
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let status = (response as? HTTPURLResponse)?.statusCode {
                if status == 202 {
                    promise.fulfill()
                } else {
                    XCTAssert(false, "The returned code was: \(status)")
                }
                
                if (error != nil) {
                    print(error?.localizedDescription ?? "")
                    XCTAssert(false, "There was an error: \(error!.localizedDescription)")
                }
            }
        })
        
        dataTask.resume()
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}

