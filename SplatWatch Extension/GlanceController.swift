//
//  GlanceController.swift
//  SplatWatch Extension
//
//  Created by Kevin Sullivan on 1/16/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON

class GlanceController: WKInterfaceController {
    @IBOutlet var lblTime: WKInterfaceLabel!
    @IBOutlet var lblMap1: WKInterfaceLabel!
    @IBOutlet var lblMap2: WKInterfaceLabel!
    @IBOutlet var lblMap3: WKInterfaceLabel!
    @IBOutlet var lblMap4: WKInterfaceLabel!
    @IBOutlet var imgMode: WKInterfaceImage!
    
    var rotationData: JSON!
    var updateTimer: NSTimer?
    var endEpoch: Double = -1
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        rotationData = loadData()
        
        refreshData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        refreshData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func refreshData() {
        updateTimer?.invalidate()
        
        if getTimeRemainingSeconds() <= 0 {
            loadMaps { data in
                if data["errorCode"].int != nil {
                    NSLog("Error")
                }
                else {
                    self.rotationData = data
                    self.saveData(data)
                    self.updateView()
                }
            }
        } else {
            self.updateView()
        }
    }
    
    func updateView() {
        endEpoch = rotationData["endTimes"][0].doubleValue
        
        lblMap1.setText(rotationData["rankedMaps"][0].stringValue)
        lblMap2.setText(rotationData["rankedMaps"][1].stringValue)
        lblMap3.setText(rotationData["turfMaps"][0].stringValue)
        lblMap4.setText(rotationData["turfMaps"][1].stringValue)
        
        let mode = rotationData["rankedModes"][0].stringValue
        
        if mode == "Rainmaker" {
            imgMode.setImageNamed("rainmakerIcon")
        }
        else if mode == "Splat Zones" {
            imgMode.setImageNamed("zonesIcon")
        }
        else if mode == "Tower Control" {
            imgMode.setImageNamed("towerIcon")
        }
        
        update()
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(GlanceController.update), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(updateTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func update() {
        let timeRemainingSeconds = getTimeRemainingSeconds()
        
        if timeRemainingSeconds <= 0 {
            refreshData()
        } else {
            lblTime.setText(getTimeRemainingText(timeRemainingSeconds))
        }
    }
    
    func getTimeRemainingSeconds() -> Int {
        return Int(endEpoch - NSDate().timeIntervalSince1970)
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
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
