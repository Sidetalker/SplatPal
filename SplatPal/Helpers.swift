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

let splatoonAPIString = "https://splatoon.ink/schedule.json"

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
