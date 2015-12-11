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

func loadMaps(completion: (JSON?) -> ()) {
    request(.GET, splatoonAPIString, encoding: .URL, headers: ["Cache-Control" : "max-age=0"])
        .responseJSON { response in
            // Handle request failure
            if response.result.isFailure {
                log.error("Error Loading Schedule: \(response.result.error)")
                
                completion(nil)
            } else {
                let json = JSON(response.result.value!)
                
                if json["splatfest"].boolValue { log.warning("Splatfest, IDK WHAT TO DO!!!") }
                
                var startTimes = [NSTimeInterval]()
                var endTimes = [NSTimeInterval]()
                var turfMaps = [String]()
                var rankedMaps = [String]()
                var rankedModes = [String]()
                
                for entry in json["schedule"].arrayValue {
                    startTimes.append(entry["startTime"].doubleValue / 1000)
                    endTimes.append(entry["endTime"].doubleValue / 1000)
                    turfMaps.append(entry["regular"]["maps"][0]["nameEN"].stringValue)
                    turfMaps.append(entry["regular"]["maps"][1]["nameEN"].stringValue)
                    rankedMaps.append(entry["ranked"]["maps"][0]["nameEN"].stringValue)
                    rankedMaps.append(entry["ranked"]["maps"][1]["nameEN"].stringValue)
                    rankedModes.append(entry["ranked"]["rulesEN"].stringValue)
                }
                
                let dataDict = ["startTimes" : startTimes, "endTimes" : endTimes, "turfMaps" : turfMaps, "rankedMaps" : rankedMaps, "rankedModes" : rankedModes]
                
                completion(JSON(dataDict))
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
