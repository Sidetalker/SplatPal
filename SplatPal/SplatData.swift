//
//  SplatData.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/21/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import Alamofire
import SwiftyJSON

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
                nnid.clearCookies()
                completion(error)
                
                return
            }
            
            let headers = JSON(response!.allHeaderFields).dictionaryObject! as! [String : String]
            
            if let cookie = NSHTTPCookie.cookiesWithResponseHeaderFields(headers, forURL: response!.URL!).last {
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookie(cookie)
                nnid.updateCookie(cookie.value)
                nnid.updateCookieObj(cookie.properties)
                completion(nil)
            }
            else {
                nnid.clearCookies()
                completion(NSError(domain: "com.sideapps.SplatPal", code: 42, userInfo: [NSLocalizedDescriptionKey : "Incorrect username or password"]))
            }
    }
}

func loadMaps(completion: (JSON) -> ()) {
    let splatoonAPIString = "https://splatoon.ink/schedule.json"
//    let splatoonAPIString = "http://127.0.0.1:8080/"
    let nintendoAPIString = "https://splatoon.nintendo.net/schedule/index.json"
    
    // Use Splatoon.ink if we don't have an NNID cookie
    if NNID.sharedInstance.cookie == "" {
        request(.GET, splatoonAPIString, encoding: .URL, headers: ["Cache-Control" : "max-age=0"])
            .responseJSON { response in
                // Handle request failure
                if response.result.isFailure {
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
                    completion(JSON(["errorCode" : response.result.error!.code, "errorMessage" : response.result.error!.localizedDescription]))
                    NNID.sharedInstance.clearCookies()
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
                    
                    if let _ = json["error"].string {
                        NNID.sharedInstance.clearCookies()
                        loginNNID { error in }
                        loadMaps { data in completion(data) }
                    }
                    
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

class NNID {
    static let sharedInstance = NNID()
    private let prefs = NSUserDefaults.init(suiteName: "group.com.sideapps.SplatPal")!
    var username = ""
    var password = ""
    var cookie = ""
    var cookieObj: [String : AnyObject]?
    var saveLogin = false
    var touchID = false
    
    private init() {
        if let
            username = prefs.stringForKey("NNIDUsername"),
            password = prefs.stringForKey("NNIDPassword"),
            cookie = prefs.stringForKey("NNIDCookie")
        {
            self.username = username
            self.password = password
            self.cookie = cookie
        }
        
        self.cookieObj = prefs.objectForKey("NNIDCookieObj") as? [String : AnyObject]
        self.saveLogin = prefs.boolForKey("NNIDSaveLogin")
        self.touchID = prefs.boolForKey("NNIDTouchID")
    }
    
    func hasCredentials() -> Bool {
        return username != "" && password != ""
    }
    
    func updateCredentials(username: String, password: String) {
        self.username = username
        self.password = password
        prefs.setObject(username, forKey: "NNIDUsername")
        prefs.setObject(password, forKey: "NNIDPassword")
    }
    
    func updateCookie(cookie: String) {
        self.cookie = cookie
        prefs.setObject(cookie, forKey: "NNIDCookie")
    }
    
    func updateCookieObj(cookie: [String : AnyObject]?) {
        self.cookieObj = cookie
        prefs.setObject(cookie, forKey: "NNIDCookieObj")
    }
    
    func updateSaveLogin(saveLogin: Bool) {
        self.saveLogin = saveLogin
        prefs.setBool(saveLogin, forKey: "NNIDSaveLogin")
    }
    
    func updateTouchID(touchID: Bool) {
        self.touchID = touchID
        prefs.setBool(touchID, forKey: "NNIDTouchID")
    }
    
    func clearCookies() {
        updateCookieObj(nil)
        updateCookie("")
    }
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
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = NSUserDefaults.standardUserDefaults().boolForKey("militaryTime") ? "HH:mm" : "h:mm a"
    dateFormatter.timeZone = NSTimeZone()
    
    return dateFormatter.stringFromDate(date)
}