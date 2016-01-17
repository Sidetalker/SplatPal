//
//  InterfaceController.swift
//  SplatWatch Extension
//
//  Created by Kevin Sullivan on 1/16/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class InterfaceController: WKInterfaceController {

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
        
        loadMaps { data in
            if data["errorCode"].int != nil {
                NSLog("Error")
            }
            else {
                if data["splatfest"].boolValue {
                    NSLog("Splatfest found")
                    
                    let splatData: [String : String] = [
                        "teamA" : data["teams"][0].stringValue,
                        "teamB" : data["teams"][1].stringValue,
                        "map1" : data["turfMaps"][0].stringValue,
                        "map2" : data["turfMaps"][1].stringValue,
                        "map3" : data["turfMaps"][2].stringValue,
                    ]
                    
                    WKInterfaceController.reloadRootControllers([("splatfest", splatData)])
                    
                    //                    self.splatfest = true
                    //
                    //                    self.splatfestTeamA.text = data["teams"][0].stringValue
                    //                    self.splatfestTeamB.text = data["teams"][1].stringValue
                    //                    self.splatfestMap1.text = data["turfMaps"][0].stringValue
                    //                    self.splatfestMap2.text = data["turfMaps"][1].stringValue
                    //                    self.splatfestMap3.text = data["turfMaps"][2].stringValue
                    //
                    //                    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 80)
                    //
                    //                    if self.splatfestView.alpha == 0.0 {
                    //                        self.splatfestView.alpha = 1.0
                    //                    }
                } else {
//                    WKInterfaceController.reloadRootControllersWithNames(<#T##names: [String]##[String]#>, contexts: <#T##[AnyObject]?#>)
                    
                    //                    self.splatfest = false
                    //
                    //                    // Unhide all views if they're hidden
                    //                    if self.dividerCenter.alpha == 0.0 {
                    //                        for view in self.view.subviews {
                    //                            if view != self.splatfestView { view.alpha = 1.0 }
                    //                        }
                    //
                    //                        self.updateDisplay()
                    //                    }
                    //
                    //                    self.lblRanked1.text = data["rankedModes"][0].stringValue
                    //
                    //                    self.lblTime1.text = "Updating"
                    //
                    //                    self.lblMap1a.text = data["rankedMaps"][0].stringValue
                    //                    self.lblMap1b.text = data["rankedMaps"][1].stringValue
                    //                    self.lblMap1c.text = data["turfMaps"][0].stringValue
                    //                    self.lblMap1d.text = data["turfMaps"][1].stringValue
                    //
                    //                    self.rotationEndTime = data["endTimes"][0].doubleValue
                    //
                    //                    if data["rankedMaps"].arrayValue.count > 1 {
                    //                        self.lblRanked2.text = data["rankedModes"][1].stringValue
                    //
                    //                        let start2 = data["startTimes"][1].doubleValue
                    //                        let end2 = data["endTimes"][1].doubleValue
                    //                        self.lblTime2.text = "\(epochTimeString(start2)) - \(epochTimeString(end2))"
                    //
                    //                        self.lblMap2a.text = data["rankedMaps"][2].stringValue
                    //                        self.lblMap2b.text = data["rankedMaps"][3].stringValue
                    //                        self.lblMap2c.text = data["turfMaps"][2].stringValue
                    //                        self.lblMap2d.text = data["turfMaps"][3].stringValue
                    //                    }
                    //                    
                    //                    if data["rankedMaps"].arrayValue.count > 2 {
                    //                        self.lblRanked3.text = data["rankedModes"][2].stringValue
                    //                        
                    //                        let start3 = data["startTimes"][2].doubleValue
                    //                        let end3 = data["endTimes"][2].doubleValue
                    //                        self.lblTime3.text = "\(epochTimeString(start3)) - \(epochTimeString(end3))"
                    //                        
                    //                        self.lblMap3a.text = data["rankedMaps"][4].stringValue
                    //                        self.lblMap3b.text = data["rankedMaps"][5].stringValue
                    //                        self.lblMap3c.text = data["turfMaps"][4].stringValue
                    //                        self.lblMap3d.text = data["turfMaps"][5].stringValue
                    //                    }
                }
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
}

class RotationInterface: WKInterfaceController {
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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
