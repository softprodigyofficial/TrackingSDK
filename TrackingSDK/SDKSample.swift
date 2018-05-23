//
//  TrackingSDK.swift
//  TrackingSDK
//
//  Created by Radha on 4/6/18.
//  Copyright © 2018 SoftProdigy. All rights reserved.
//

import Foundation
import AdSupport
import UIKit
import CoreTelephony

public class TrackingSDK {
    
    let tech = String()
    public static let sharedInstance = TrackingSDK()
    
    var appPackageName = ""
    var eventType = ""
    var eventKey = ""
    var eventValue = ""
    var sessionId = ""
    var apiKey = ""
    
    private init() {
        debugPrint("SDK Sample Intializer")
    }
    
    public static func configure()
    {
        self.eventapi(fromEvent:"configure")
    }
    
    //Event Traking Api
    public static func eventapi(fromEvent:String) {
        
        let ticks = Date().ticks
        print(ticks)
        let bundleID = "\(Bundle.main.bundleIdentifier!)"
        
        NetworkManager.eventTrack(appPackageName: bundleID, timestamp: TimeInterval(ticks) , eventType: TrackingSDK.sharedInstance.eventType, eventKey: TrackingSDK.sharedInstance.eventKey, eventValue: TrackingSDK.sharedInstance.eventValue, sessionId: TrackingSDK.sharedInstance.sessionId, fromEvent:fromEvent ){ (message)  in
            DispatchQueue.main.async {
                
            }
        }
    }
    
    //Event Traking Method
    public static func eventTraking(eventKey : String , eventType: String,eventValue: String) {
        sharedInstance.eventKey = eventKey
        sharedInstance.eventType = eventType
        sharedInstance.eventValue = eventValue
        
        TrackingSDK.eventapi(fromEvent:"eventTraking")
    }
    
    public static func appLaunch(eventType: String)
    {
        sharedInstance.eventType = eventType
        TrackingSDK.eventapi(fromEvent:"appLaunch")
    }
    
    //Session Start Event
    public static func sessionStart(eventType : String)
    {
        var IDFA = String()
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            IDFA = String(describing: ASIdentifierManager.shared().advertisingIdentifier)
        }
        
        let ticks = Date().ticks
        let time = "\(IDFA)\(ticks)"
        let stringConvertedToMD5 = "\(time.utf8.md5)"
        
        sharedInstance.eventType = eventType
        sharedInstance.sessionId = stringConvertedToMD5
        
        TrackingSDK.eventapi(fromEvent:"sessionStart")
    }
    
    //Session End Event
    public static func SessionEnd(eventType : String)
    {
        sharedInstance.eventType = eventType
        TrackingSDK.eventapi(fromEvent:"SessionEnd")
    }
    
    //API key
    public static func setApiKey(apiKey : String)
    {
        sharedInstance.apiKey = apiKey
    }
}

//Get Timevent
extension Date
{
    var ticks: UInt64 {
        return UInt64(NSDate().timeIntervalSince1970)
    }
}


