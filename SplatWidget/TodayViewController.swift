//
//  TodayViewController.swift
//  SplatWidget
//
//  Created by Kevin Sullivan on 12/21/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    let prefs = NSUserDefaults.init(suiteName: "group.com.sideapps.SplatPal")!
    
    @IBOutlet weak var lblRanked1: UILabel!
    @IBOutlet weak var lblTime1: UILabel!
    @IBOutlet weak var lblRanked2: UILabel!
    @IBOutlet weak var lblTime2: UILabel!
    @IBOutlet weak var lblRanked3: UILabel!
    @IBOutlet weak var lblTime3: UILabel!
    
    @IBOutlet weak var lblMap1a: UILabel!
    @IBOutlet weak var lblMap1b: UILabel!
    @IBOutlet weak var lblMap1c: UILabel!
    @IBOutlet weak var lblMap1d: UILabel!
    
    @IBOutlet weak var lblMap2a: UILabel!
    @IBOutlet weak var lblMap2b: UILabel!
    @IBOutlet weak var lblMap2c: UILabel!
    @IBOutlet weak var lblMap2d: UILabel!
    
    @IBOutlet weak var lblMap3a: UILabel!
    @IBOutlet weak var lblMap3b: UILabel!
    @IBOutlet weak var lblMap3c: UILabel!
    @IBOutlet weak var lblMap3d: UILabel!
    
    @IBOutlet weak var dividerCenter: UIView!
    @IBOutlet weak var divider1and2: UIView!
    @IBOutlet weak var divider2and3: UIView!
    
    @IBOutlet weak var splatfestView: UIView!
    @IBOutlet weak var splatfestTeamA: UILabel!
    @IBOutlet weak var splatfestTeamB: UILabel!
    @IBOutlet weak var splatfestMap1: UILabel!
    @IBOutlet weak var splatfestMap2: UILabel!
    @IBOutlet weak var splatfestMap3: UILabel!
    
    @IBOutlet weak var conHeight2: NSLayoutConstraint!
    @IBOutlet weak var conHeight3: NSLayoutConstraint!
    @IBOutlet weak var conDividerHeight: NSLayoutConstraint!
    
    var updateTimer: NSTimer!
    var rotationEndTime = 0.0
    var expanded = false
    var splatfest = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 1)
        
        // Hide all views before initial load
        for view in self.view.subviews {
            view.alpha = 0.0
        }
        
        splatfestView.backgroundColor = UIColor.clearColor()
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(updateTimer, forMode: NSRunLoopCommonModes)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped"))
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(4, 6, 4, 6)
    }
    
    func getTimeRemainingSeconds() -> Int {
        return Int(rotationEndTime - NSDate().timeIntervalSince1970)
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
    
    func update() {
        if rotationEndTime == 0.0 { return }
        
        let timeRemainingSeconds = getTimeRemainingSeconds()
        
        if timeRemainingSeconds <= 0 {
            lblTime1.text = "Updating"
            updateData()
        } else {
            lblTime1.text = getTimeRemainingText(timeRemainingSeconds)
        }
    }
    
    func tapped() {
        expanded = !expanded
        
        updateDisplay()
    }
    
    func updateDisplay() {
        if splatfest { return }
        
        if !expanded {
//            self.conDividerHeight.constant = 58
            
            UIView.animateWithDuration(0.5, animations: {
                self.lblRanked3.alpha = 0.0
                self.lblTime3.alpha = 0.0
                self.lblMap3a.alpha = 0.0
                self.lblMap3b.alpha = 0.0
                self.lblMap3c.alpha = 0.0
                self.lblMap3d.alpha = 0.0
                self.divider2and3.alpha = 0.0
                self.lblRanked2.alpha = 0.0
                self.lblTime2.alpha = 0.0
                self.lblMap2a.alpha = 0.0
                self.lblMap2b.alpha = 0.0
                self.lblMap2c.alpha = 0.0
                self.lblMap2d.alpha = 0.0
                self.divider1and2.alpha = 0.0
                self.dividerCenter.setNeedsDisplay()
            })
            
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 60)
        } else {
            self.conDividerHeight.constant = 188
            
            UIView.animateWithDuration(0.5, animations: {
                self.lblRanked3.alpha = 1.0
                self.lblTime3.alpha = 1.0
                self.lblMap3a.alpha = 1.0
                self.lblMap3b.alpha = 1.0
                self.lblMap3c.alpha = 1.0
                self.lblMap3d.alpha = 1.0
                self.divider2and3.alpha = 1.0
                self.lblRanked2.alpha = 1.0
                self.lblTime2.alpha = 1.0
                self.lblMap2a.alpha = 1.0
                self.lblMap2b.alpha = 1.0
                self.lblMap2c.alpha = 1.0
                self.lblMap2d.alpha = 1.0
                self.divider1and2.alpha = 1.0
                self.dividerCenter.setNeedsDisplay()
            })
            
            self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 190)
        }
    }
    
    func updateData() {
        loadMaps { data in
            if data["errorCode"].int != nil {
                NSLog("Error")
            }
            else {
                if data["splatfest"].boolValue {
                    NSLog("Splatfest found")
                    self.splatfest = true
                    
                    self.splatfestTeamA.text = data["teams"][0].stringValue
                    self.splatfestTeamB.text = data["teams"][1].stringValue
                    self.splatfestMap1.text = data["turfMaps"][0].stringValue
                    self.splatfestMap2.text = data["turfMaps"][1].stringValue
                    self.splatfestMap3.text = data["turfMaps"][2].stringValue
                    
                    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 80)
                    
                    if self.splatfestView.alpha == 0.0 {
                        self.splatfestView.alpha = 1.0
                    }
                } else {
                    self.splatfest = false
                    
                    // Unhide all views if they're hidden
                    if self.dividerCenter.alpha == 0.0 {
                        for view in self.view.subviews {
                            if view != self.splatfestView { view.alpha = 1.0 }
                        }
                        
                        self.updateDisplay()
                    }
                    
                    self.lblRanked1.text = data["rankedModes"][0].stringValue
                    
                    self.lblTime1.text = "Updating"
                    
                    self.lblMap1a.text = data["rankedMaps"][0].stringValue
                    self.lblMap1b.text = data["rankedMaps"][1].stringValue
                    self.lblMap1c.text = data["turfMaps"][0].stringValue
                    self.lblMap1d.text = data["turfMaps"][1].stringValue
                    
                    self.rotationEndTime = data["endTimes"][0].doubleValue
                    
                    if data["rankedMaps"].arrayValue.count > 1 {
                        self.lblRanked2.text = data["rankedModes"][1].stringValue
                        
                        let start2 = data["startTimes"][1].doubleValue
                        let end2 = data["endTimes"][1].doubleValue
                        self.lblTime2.text = "\(epochTimeString(start2)) - \(epochTimeString(end2))"
                        
                        self.lblMap2a.text = data["rankedMaps"][2].stringValue
                        self.lblMap2b.text = data["rankedMaps"][3].stringValue
                        self.lblMap2c.text = data["turfMaps"][2].stringValue
                        self.lblMap2d.text = data["turfMaps"][3].stringValue
                    }
                    
                    if data["rankedMaps"].arrayValue.count > 2 {
                        self.lblRanked3.text = data["rankedModes"][2].stringValue
                        
                        let start3 = data["startTimes"][2].doubleValue
                        let end3 = data["endTimes"][2].doubleValue
                        self.lblTime3.text = "\(epochTimeString(start3)) - \(epochTimeString(end3))"
                        
                        self.lblMap3a.text = data["rankedMaps"][4].stringValue
                        self.lblMap3b.text = data["rankedMaps"][5].stringValue
                        self.lblMap3c.text = data["turfMaps"][4].stringValue
                        self.lblMap3d.text = data["turfMaps"][5].stringValue
                    }
                }
            }
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
        
        updateData()
    }
}
