//
//  Helpers.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

class PlaceholderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.backgroundColor = UIColor.clearColor()
    }
}

extension String {
    func replace(string: String, replacement: String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

extension Array {
    // Returns a subset of the array based on the boolean array passed
    func booleanFilter<T : Equatable>(boolArr: [Bool]) -> [T]? {
        if self.count != boolArr.count {
            log.warning("Array.booleanFilter provided a boolArr of incorrect size - returning nil")
            return nil
        }
        
        var returnArr = [T]()
        for i in 0...self.count - 1 {
            if boolArr[i] { returnArr.append(self[i] as! T) }
        }
        
        return returnArr
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func loadNotifications() -> JSON {
    let path = getDocumentsDirectory().stringByAppendingPathComponent("notifications.json")
    var notificationJSON = JSON([])
    
    if let jsonData = NSData(contentsOfFile: path) {
        notificationJSON = JSON(data: jsonData)
        log.debug("Notifications loaded")
    }
    else {
        saveNotifications(notificationJSON)
    }
    
    return notificationJSON
}

func saveNotifications(notificationJSON: JSON) -> Bool {
    let path = getDocumentsDirectory().stringByAppendingPathComponent("notifications.json")
    
    do {
        try notificationJSON.rawString()!.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        log.debug("Notifications saved")
        return true
    } catch {
        log.error("Could not write notification file")
        log.error("File: \(path)")
        log.error("Contents: \(notificationJSON.rawString()!)")
        return false
    }
}

func loginNNID(completion: (NSError?) -> ()) {
    let nnid = NNID.sharedInstance
    nnid.updateCookie("")
    
    let NNIDLoginURL = "https://id.nintendo.net/oauth/authorize"
    let parameters = [
        "client_id": "12af3d0a3a1f441eb900411bb50a835a",
        "response_type": "code",
        "redirect_uri": "https://splatoon.nintendo.net/users/auth/nintendo/callback",
        "username": nnid.username,
        "password": nnid.password
    ]
    
    request(.POST, NNIDLoginURL, encoding: .URL, parameters: parameters)
        .response { request, response, data, error in
            // Handle request failure
            if error != nil {
                log.error("Search Error")
                debugPrint(response)
                completion(error)
                
                return
            }
            
            let headers = JSON(response!.allHeaderFields).dictionaryObject! as! [String : String]
            
            if let cookie = NSHTTPCookie.cookiesWithResponseHeaderFields(headers, forURL: response!.URL!).last {
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookie(cookie)
                nnid.updateCookie(cookie.value)
                completion(nil)
            }
            else {
                nnid.updateCookie("")
                completion(NSError(domain: "com.sideapps.SplatPal", code: 42, userInfo: [NSLocalizedDescriptionKey : "Incorrect username or password"]))
            }
    }
}

func loadMaps(completion: (JSON) -> ()) {
    let splatoonAPIString = "https://splatoon.ink/schedule.json"
    let nintendoAPIString = "https://splatoon.nintendo.net/schedule/index.json"
    
    // Use Splatoon.ink if we don't have an NNID cookie
    if NNID.sharedInstance.cookie == "" {
        request(.GET, splatoonAPIString, encoding: .URL, headers: ["Cache-Control" : "max-age=0"])
            .responseJSON { response in
                // Handle request failure
                if response.result.isFailure {
                    log.error("Error Loading Schedule: \(response.result.error)")
                    
                    completion(JSON(["errorCode" : response.result.error!.code, "errorMessage" : response.result.error!.localizedDescription]))
                } else {
                    let json = JSON(response.result.value!)
                    let splatfest = json["splatfest"].boolValue
                    var startTimes = [NSTimeInterval]()
                    var endTimes = [NSTimeInterval]()
                    var turfMaps = [String]()
                    var rankedMaps = [String]()
                    var rankedModes = [String]()
                    
                    if splatfest {
                        let schedule = json["schedule"][0]
                        var teams = [String]()
                        
                        startTimes.append(schedule["startTime"].doubleValue / 1000)
                        endTimes.append(schedule["endTime"].doubleValue / 1000)
                        for x in 0...2 {
                            turfMaps.append(schedule["regular"]["maps"][x]["nameEN"].stringValue)
                        }
                        teams.append(schedule["regular"]["teams"][0].stringValue)
                        teams.append(schedule["regular"]["teams"][1].stringValue)
                        
                        let dataDict = ["startTimes" : startTimes, "endTimes" : endTimes, "turfMaps" : turfMaps, "teams" : teams, "splatfest" : splatfest]
                        completion(JSON(dataDict))
                    }
                    else {
                        for entry in json["schedule"].arrayValue {
                            startTimes.append(entry["startTime"].doubleValue / 1000)
                            endTimes.append(entry["endTime"].doubleValue / 1000)
                            turfMaps.append(entry["regular"]["maps"][0]["nameEN"].stringValue)
                            turfMaps.append(entry["regular"]["maps"][1]["nameEN"].stringValue)
                            rankedMaps.append(entry["ranked"]["maps"][0]["nameEN"].stringValue)
                            rankedMaps.append(entry["ranked"]["maps"][1]["nameEN"].stringValue)
                            rankedModes.append(entry["ranked"]["rulesEN"].stringValue)
                        }
                        
                        // Check for outdatedness
                        while endTimes[0] != 0 && NSDate().compare(NSDate(timeIntervalSince1970: endTimes[0])) == .OrderedDescending {
                            for x in 0...1 {
                                startTimes[x] = startTimes[x + 1]
                                endTimes[x] = endTimes[x + 1]
                                turfMaps[x * 2] = turfMaps[(x + 1) * 2]
                                turfMaps[x * 2 + 1] = turfMaps[(x + 1) * 2 + 1]
                                rankedMaps[x * 2] = rankedMaps[(x + 1) * 2]
                                rankedMaps[x * 2 + 1] = rankedMaps[(x + 1) * 2 + 1]
                                rankedModes[x] = rankedModes[x + 1]
                            }
                            
                            startTimes[2] = 0
                            endTimes[2] = 0
                            turfMaps[4] = ""
                            turfMaps[5] = ""
                            rankedMaps[4] = ""
                            rankedMaps[5] = ""
                            rankedModes[2] = ""
                        }
                        
                        // All data is out of date
                        if startTimes[0] == 0 {
                            completion(JSON(["errorCode" : 503, "errorMessage" : "Splatoon.ink data is not available"]))
                        } else {
                            let dataDict = ["startTimes" : startTimes, "endTimes" : endTimes, "turfMaps" : turfMaps, "rankedMaps" : rankedMaps, "rankedModes" : rankedModes, "splatfest" : splatfest]
                            completion(JSON(dataDict))
                        }
                    }
                }
        }
    }
    // If we have an NNID cookie we can use Nintendo's API directly
    else {
        request(.GET, nintendoAPIString, encoding: .URL, headers: ["Cache-Control" : "max-age=0"])
            .responseJSON { response in
                // Handle request failure
                if response.result.isFailure {
                    log.error("Error Loading Schedule: \(response.result.error)")
                    
                    completion(JSON(["errorCode" : response.result.error!.code, "errorMessage" : response.result.error!.localizedDescription]))
                } else {
                    let json = JSON(response.result.value!)
                    let splatfest = json["festival"].boolValue
                    var startTimes = [NSTimeInterval]()
                    var endTimes = [NSTimeInterval]()
                    var turfMaps = [String]()
                    var rankedMaps = [String]()
                    var rankedModes = [String]()
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"
                    
                    if splatfest {
                        let schedule = json["schedule"][0]
                        var teams = [String]()
                        
                        startTimes.append(schedule["startTime"].doubleValue / 1000)
                        endTimes.append(schedule["endTime"].doubleValue / 1000)
                        for stage in schedule["stages"].arrayValue {
                            turfMaps.append(stage["name"].stringValue)
                        }
                        teams.append(schedule["team_alpha_name"].stringValue)
                        teams.append(schedule["team_bravo_name"].stringValue)
                        
                        let dataDict = ["startTimes" : startTimes, "endTimes" : endTimes, "turfMaps" : turfMaps, "teams" : teams, "splatfest" : splatfest]
                        completion(JSON(dataDict))
                    }
                    else {
                        for entry in json["schedule"].arrayValue {
                            startTimes.append(dateFormatter.dateFromString(entry["datetime_begin"].stringValue)!.timeIntervalSince1970)
                            endTimes.append(dateFormatter.dateFromString(entry["datetime_end"].stringValue)!.timeIntervalSince1970)
                            turfMaps.append(entry["stages"]["regular"][0]["name"].stringValue)
                            turfMaps.append(entry["stages"]["regular"][1]["name"].stringValue)
                            rankedMaps.append(entry["stages"]["gachi"][0]["name"].stringValue)
                            rankedMaps.append(entry["stages"]["gachi"][1]["name"].stringValue)
                            rankedModes.append(entry["gachi_rule"].stringValue)
                        }
                        
                        // Check for outdatedness
                        while endTimes[0] != 0 && NSDate().compare(NSDate(timeIntervalSince1970: endTimes[0])) == .OrderedDescending {
                            for x in 0...1 {
                                startTimes[x] = startTimes[x + 1]
                                endTimes[x] = endTimes[x + 1]
                                turfMaps[x * 2] = turfMaps[(x + 1) * 2]
                                turfMaps[x * 2 + 1] = turfMaps[(x + 1) * 2 + 1]
                                rankedMaps[x * 2] = rankedMaps[(x + 1) * 2]
                                rankedMaps[x * 2 + 1] = rankedMaps[(x + 1) * 2 + 1]
                                rankedModes[x] = rankedModes[x + 1]
                            }
                            
                            startTimes[2] = 0
                            endTimes[2] = 0
                            turfMaps[4] = ""
                            turfMaps[5] = ""
                            rankedMaps[4] = ""
                            rankedMaps[5] = ""
                            rankedModes[2] = ""
                        }
                        
                        // All data is out of date
                        if startTimes[0] == 0 {
                            completion(JSON(["errorCode" : 503, "errorMessage" : "Splatoon.ink data is not available"]))
                        } else {
                            let dataDict = ["startTimes" : startTimes, "endTimes" : endTimes, "turfMaps" : turfMaps, "rankedMaps" : rankedMaps, "rankedModes" : rankedModes, "splatfest" : splatfest]
                            completion(JSON(dataDict))
                        }
                    }
                }
        }
    }
    
}

func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func epochDateString(input: NSTimeInterval) -> String {
    let date = NSDate(timeIntervalSince1970: input)
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    dateFormatter.timeZone = NSTimeZone()
    
    return dateFormatter.stringFromDate(date)
}

func epochTimeString(input: NSTimeInterval) -> String {
    let date = NSDate(timeIntervalSince1970: input)
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = NSTimeZone()
    
    return dateFormatter.stringFromDate(date)
}
