//
//  InterfaceController.swift
//  SplatWatch Extension
//
//  Created by Kevin Sullivan on 1/16/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import WatchKit
import ClockKit
import Foundation
import Alamofire
import SwiftyJSON

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

class InterfaceController: WKInterfaceController {
    
    var rotationData: JSON!
    var loading = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure NNID cookies
        let nnid = NNID.sharedInstance
        
        if !nnid.saveLogin {
            nnid.clearCookies()
        }
        else {
            if let cookie = nnid.cookieObj {
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookie(NSHTTPCookie(properties: cookie)!)
            } else { loginNNID { error in } }
        }
        
        rotationData = loadData()
        reloadViews()
    }
    
    @IBAction func refreshTapped() {
        guard !loading else { return }
        
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        do {
            try "".writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch { }
        
        reloadViews()
    }
    
    func reloadViews() {
        if getTimeRemainingSeconds() < 0 {
            loading = true
            
            loadMaps { data in
                self.loading = false
                
                if data["errorCode"].int != nil {
                    NSLog("Error")
                }
                else {
                    self.rotationData = data
                    self.saveData(data)
                    self.transitionViews()
                    self.reloadComplications()
                }
            }
        } else {
            self.transitionViews()
        }
    }
    
    private func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                    NSLog("Reloading complication \(complication.debugDescription)...")
                }
            }
        }
    }
    
    func transitionViews() {
        if rotationData["splatfest"].boolValue {
            NSLog("Splatfest found")
            
            let splatData: [String : String] = [
                "teamA" : rotationData["teams"][0].stringValue,
                "teamB" : rotationData["teams"][1].stringValue,
                "map1" : rotationData["turfMaps"][0].stringValue,
                "map2" : rotationData["turfMaps"][1].stringValue,
                "map3" : rotationData["turfMaps"][2].stringValue,
            ]
            
            WKInterfaceController.reloadRootControllers([("splatfest", splatData)])
        } else {
            var rotation1 = [String : AnyObject]()
            var rotation2 = [String : AnyObject]()
            var rotation3 = [String : AnyObject]()
            
            rotation1["current"] = true
            rotation1["rankedMode"] = rotationData["rankedModes"][0].stringValue
            rotation1["start"] = rotationData["startTimes"][0].doubleValue
            rotation1["end"] = rotationData["endTimes"][0].doubleValue
            rotation1["map1"] = rotationData["rankedMaps"][0].stringValue
            rotation1["map2"] = rotationData["rankedMaps"][1].stringValue
            rotation1["map3"] = rotationData["turfMaps"][0].stringValue
            rotation1["map4"] = rotationData["turfMaps"][1].stringValue
            
            rotation2["current"] = false
            rotation2["rankedMode"] = rotationData["rankedModes"][1].stringValue
            rotation2["start"] = rotationData["startTimes"][1].doubleValue
            rotation2["end"] = rotationData["endTimes"][1].doubleValue
            rotation2["map1"] = rotationData["rankedMaps"][2].stringValue
            rotation2["map2"] = rotationData["rankedMaps"][3].stringValue
            rotation2["map3"] = rotationData["turfMaps"][2].stringValue
            rotation2["map4"] = rotationData["turfMaps"][3].stringValue
            
            rotation3["current"] = false
            rotation3["rankedMode"] = rotationData["rankedModes"][2].stringValue
            rotation3["start"] = rotationData["startTimes"][2].doubleValue
            rotation3["end"] = rotationData["endTimes"][2].doubleValue
            rotation3["map1"] = rotationData["rankedMaps"][4].stringValue
            rotation3["map2"] = rotationData["rankedMaps"][5].stringValue
            rotation3["map3"] = rotationData["turfMaps"][4].stringValue
            rotation3["map4"] = rotationData["turfMaps"][5].stringValue
            
            WKInterfaceController.reloadRootControllers(
                [("rotation", rotation1), ("rotation", rotation2), ("rotation", rotation3)])
        }
    }
    
    func getTimeRemainingSeconds() -> Int {
        return Int(rotationData["endTimes"][0].doubleValue - NSDate().timeIntervalSince1970)
    }
    
    func saveData(data: JSON) -> Bool {
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        do {
            try data.rawString()!.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch {
            return false
        }
    }
    
    func loadData() -> JSON {
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        if let jsonData = NSData(contentsOfFile: path) {
            return JSON(data: jsonData)
        }
        
        return JSON([:])
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

class SplatfestInterface: WKInterfaceController {
    @IBOutlet var lblTeamA: WKInterfaceLabel!
    @IBOutlet var lblTeamB: WKInterfaceLabel!
    @IBOutlet var lblMap1: WKInterfaceLabel!
    @IBOutlet var lblMap2: WKInterfaceLabel!
    @IBOutlet var lblMap3: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let splatData: Dictionary = context as? [String : String] {
            lblTeamA.setText(splatData["teamA"])
            lblTeamB.setText(splatData["teamB"])
            lblMap1.setText(splatData["map1"])
            lblMap2.setText(splatData["map2"])
            lblMap3.setText(splatData["map3"])
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func refreshTapped() {
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        do {
            try "".writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch { }
        
        refresh()
    }
    
    func refresh() {
        WKInterfaceController.reloadRootControllersWithNames(["loader"], contexts: nil)
    }
}

class RotationInterface: WKInterfaceController {
    @IBOutlet var lblTime: WKInterfaceLabel!
    @IBOutlet var lblMap1: WKInterfaceLabel!
    @IBOutlet var lblMap2: WKInterfaceLabel!
    @IBOutlet var lblMap3: WKInterfaceLabel!
    @IBOutlet var lblMap4: WKInterfaceLabel!
    @IBOutlet var imgRanked: WKInterfaceImage!
    
    var startTime: Double = -1.0
    var endTime: Double = -1.0
    var updateTimer: NSTimer?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let splatData: Dictionary = context as? [String : AnyObject] {
            startTime = splatData["start"] as! Double
            endTime = splatData["end"] as! Double
            
            lblMap1.setText(splatData["map1"] as? String)
            lblMap2.setText(splatData["map2"] as? String)
            lblMap3.setText(splatData["map3"] as? String)
            lblMap3.setText(splatData["map4"] as? String)
            
            let mode = splatData["rankedMode"] as! String
            
            if mode == "Rainmaker" {
                imgRanked.setImageNamed("rainmakerIcon")
            }
            else if mode == "Splat Zones" {
                imgRanked.setImageNamed("zonesIcon")
            }
            else if mode == "Tower Control" {
                imgRanked.setImageNamed("towerIcon")
            }
            
            if (splatData["current"] as! Bool) {
                update()
                updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
                NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
            } else {
                lblTime.setText("\(epochTimeString(startTime)) - \(epochTimeString(endTime))")
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func update() {
        let timeRemainingSeconds = Int(endTime - NSDate().timeIntervalSince1970)
        
        if timeRemainingSeconds <= 0 {
            refresh()
        } else {
            lblTime.setText(getTimeRemainingText(timeRemainingSeconds))
        }
    }
    
    @IBAction func refreshTapped() {
        let path = getDocumentsDirectory().stringByAppendingPathComponent("dataBuffer.json")
        
        do {
            try "".writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        } catch { }
        
        refresh()
    }
    
    func refresh() {
        updateTimer?.invalidate()
        WKInterfaceController.reloadRootControllersWithNames(["loader"], contexts: nil)
    }
    
    func getTimeRemainingText(epochInt: Int) -> String {
        var seconds = epochInt
        var minutes = seconds / 60
        let hours = minutes / 60
        seconds -= minutes * 60
        minutes -= hours * 60
        let secondsText = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        let minutesText = minutes < 10 && hours > 0 ? "0\(minutes)" : "\(minutes)"
        
        return hours > 0 ? "\(hours):\(minutesText):\(secondsText)" : "\(minutesText):\(secondsText)"
    }
}
