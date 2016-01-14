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
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func replace(string: String, replacement: String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func indexOf(target: String) -> Int {
        let range = self.rangeOfString(target)
        
        if let range = range {
            return startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    subscript(i: Int) -> Character {
        get {
            let index = startIndex.advancedBy(i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
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

func loadNotifications() -> [Notification] {
    let path = getDocumentsDirectory().stringByAppendingPathComponent("notifications.json")
    var notifications = [Notification]()
    
    if let jsonData = NSData(contentsOfFile: path) {
        for data in JSON(data: jsonData).arrayValue {
            notifications.append(Notification(data: data))
        }
        
        log.debug("\(notifications.count) Notifications loaded")
    }
    else {
        saveNotifications(notifications)
    }
    
    return notifications
}

func loadLoadouts() -> [Loadout] {
    let path = getDocumentsDirectory().stringByAppendingPathComponent("loadouts.json")
    var loadouts = [Loadout]()
    
    if let jsonData = NSData(contentsOfFile: path) {
        for data in JSON(data: jsonData).arrayValue {
            loadouts.append(Loadout(data: data))
        }
        
        log.debug("\(loadouts.count) Loadouts loaded")
    }
    else {
        saveLoadouts(loadouts)
    }
    
    return loadouts
}

func saveNotifications(notifications: [Notification]) -> Bool {
    let path = getDocumentsDirectory().stringByAppendingPathComponent("notifications.json")
    var notificationJSON = [JSON]()
    
    for notification in notifications {
        notificationJSON.append(notification.jsonRepresentation())
    }
    
    do {
        try JSON(notificationJSON).rawString()!.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        log.debug("Notifications saved")
        return true
    } catch {
        log.error("Could not write notification file")
        log.error("File: \(path)")
        log.error("Contents: \(JSON(notificationJSON).rawString()!)")
        return false
    }
}

func saveLoadouts(loadouts: [Loadout]) -> Bool {
    let path = getDocumentsDirectory().stringByAppendingPathComponent("loadouts.json")
    var loadoutJSON = [JSON]()
    
    for loadout in loadouts {
        loadoutJSON.append(loadout.jsonRepresentation())
    }
    
    do {
        try JSON(loadoutJSON).rawString()!.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        log.debug("Loadouts saved")
        return true
    } catch {
        log.error("Could not write loadout file")
        log.error("File: \(path)")
        log.error("Contents: \(JSON(loadoutJSON).rawString()!)")
        return false
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
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = NSUserDefaults.standardUserDefaults().boolForKey("militaryTime") ? "HH:mm" : "h:mm a"
    dateFormatter.timeZone = NSTimeZone()
    
    return dateFormatter.stringFromDate(date)
}
