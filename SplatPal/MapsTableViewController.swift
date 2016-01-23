//
//  MapsTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

let mapRefreshCooldown = 300

class MapsTableViewController: UITableViewController {
    
    var matchData: JSON?
    var mapsUpdating = false
    var mapsUpdateCooldown = -1
    var mapError = false
    var mapErrorCode = -1
    var mapErrorMessage = ""
    
    var liveLabel: UILabel?
    var liveLabelTimer: NSTimer!
    
    let sectionMask = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView = UIView(frame: tableView.frame)
        let patternColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        backgroundView.backgroundColor = patternColor
        
        matchData = JSON([:])
        matchData?["errorCode"] = 0
        matchData?["errorMessage"] = "Loading shit"
        
        sectionMask.backgroundColor = patternColor
        sectionMask.frame = tableView.dequeueReusableCellWithIdentifier("cellTimeRemaining")!.contentView.bounds
        tableView.addSubview(sectionMask)
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundView = backgroundView
        tableView.reloadData()
        
        liveLabelTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateLabel", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(liveLabelTimer, forMode: NSRunLoopCommonModes)
        
        updateMaps(true)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        sectionMask.frame.origin.y = scrollView.contentOffset.y
        sectionMask.frame.size.width = scrollView.frame.width
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        mapError = false
        
        if let
            errorCode = matchData?["errorCode"].int,
            errorMessage = matchData?["errorMessage"].string
        {
            mapError = true
            mapErrorCode = errorCode
            mapErrorMessage = errorMessage
            
            return 1
        }
        else if !matchData!["splatfest"].boolValue {
            var sessionCount = 0
            for match in matchData!["endTimes"].arrayObject as! [Double] {
                if match != 0 { sessionCount += 1 }
            }
            
            return sessionCount
        }
        else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mapError { return matchData!["errorCode"].intValue == 0 ? 0 : 1 }
        else if !matchData!["splatfest"].boolValue { return 6 }
        else { return 4 }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if mapError {
            cell = tableView.dequeueReusableCellWithIdentifier("cellErrorDetail", forIndexPath: indexPath)
            cell.backgroundColor = UIColor.clearColor()
            
            let lblCode = cell.viewWithTag(1) as! UILabel
            let lblMessage = cell.viewWithTag(2) as! UILabel
            lblCode.text = "Error Code \(mapErrorCode)"
            lblMessage.text = mapErrorMessage
        }
        else if matchData!["splatfest"].boolValue {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("cellGameMode", forIndexPath: indexPath)
                cell.backgroundColor = UIColor.clearColor()
                
                let lbl = cell.viewWithTag(1) as! UILabel
                lbl.text = "\(matchData!["teams"][0].stringValue) vs \(matchData!["teams"][1].stringValue)"
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("cellMap", forIndexPath: indexPath)
                cell.backgroundColor = UIColor.clearColor()
                
                let mapName = matchData!["turfMaps"][indexPath.row - 1].stringValue
                
                let imgMap = cell.viewWithTag(1) as! UIImageView
                imgMap.layer.cornerRadius = 5
                imgMap.image = UIImage(named: "Stage\(mapName.removeWhitespace()).jpg")
                
                let imgBadge = cell.viewWithTag(2) as! UIImageView
                imgBadge.image = UIImage(named: "turfWarBadge.png")
                
                let lblName = cell.viewWithTag(3) as! UILabel
                lblName.text = mapName
            }
        }
        else {
            if indexPath.row % 3 == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("cellGameMode", forIndexPath: indexPath)
                cell.backgroundColor = UIColor.clearColor()
                
                let lbl = cell.viewWithTag(1) as! UILabel
                lbl.text = indexPath.row == 0 ? matchData!["rankedModes"][indexPath.section].stringValue : "Turf Wars"
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("cellMap", forIndexPath: indexPath)
                cell.backgroundColor = UIColor.clearColor()
                
                let mapName = [1, 2].contains(indexPath.row) ?
                    matchData!["rankedMaps"][indexPath.row - 1 + indexPath.section * 2].stringValue :
                    matchData!["turfMaps"][indexPath.row - 4 + indexPath.section * 2].stringValue
                
                let imgMap = cell.viewWithTag(1) as! UIImageView
                imgMap.layer.cornerRadius = 5
                imgMap.image = UIImage(named: "Stage\(mapName.removeWhitespace()).jpg")
                
                let imgBadge = cell.viewWithTag(2) as! UIImageView
                imgBadge.image = [1, 2].contains(indexPath.row) ? UIImage(named: "rankedBadge.png") : UIImage(named: "turfWarBadge.png")
                
                let lblName = cell.viewWithTag(3) as! UILabel
                lblName.text = mapName
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard cell.reuseIdentifier == "cellMap" else { return }
        
        // Resize map label font to give it some padding
        let lblName = cell.viewWithTag(3) as! UILabel
        let insets = UIEdgeInsetsMake(2, 5, 2, 5)
        let desiredFrame = UIEdgeInsetsInsetRect(lblName.frame, insets)
        let constraintSize = CGSizeMake(desiredFrame.width, 100000)
        let minFontSize: CGFloat = 10
        var fontSize: CGFloat = 25
        
        repeat {
            lblName.font = UIFont(name: lblName.font.fontName, size: fontSize)
            
            let size = (lblName.text! as NSString).boundingRectWithSize(constraintSize,
                options: .UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: lblName.font],
                context: nil).size
            
            if size.height <= desiredFrame.height { break }
            
            fontSize -= 1
        } while (fontSize > minFontSize);
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellTimeRemaining")!
            cell.contentView.backgroundColor = UIColor.clearColor()
            
            let lblHeader = cell.viewWithTag(1) as! UILabel
            let lblFooter = cell.viewWithTag(2) as! UILabel
            
            for gestureRecognizer in cell.contentView.gestureRecognizers! {
                cell.contentView.removeGestureRecognizer(gestureRecognizer) }
            
            cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "topHeaderLongPress:"))
            
            if mapError && !mapsUpdating {
                lblHeader.text = "Error Loading Data"
                lblFooter.text = "Tap + Hold to Refresh"
            } else {
                if mapsUpdating {
                    lblHeader.text = "Retrieving Updates"
                    lblFooter.text = "· · ·"
                }
                else {
                    liveLabel = lblFooter
                    updateLabel()
                    lblHeader.text = matchData!["splatfest"].boolValue ? "Time Left in Splatfest" : "Time Until Next Rotation"
                }
            }
            
            return cell.contentView
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellFutureTimes")!
            cell.contentView.backgroundColor = UIColor.clearColor()
            
            let lblHeader = cell.viewWithTag(1) as! UILabel
            let lblFooter = cell.viewWithTag(2) as! UILabel
            
            let startTime = matchData!["startTimes"][section].doubleValue
            let endTime = matchData!["endTimes"][section].doubleValue
            lblHeader.text = epochDateString(startTime)
            lblFooter.text = "\(epochTimeString(startTime)) - \(epochTimeString(endTime))"
            
            return cell.contentView
        }
    }
    
    func topHeaderLongPress(sender: UITapGestureRecognizer) {
        guard sender.state == .Began && mapsUpdating == false else { return }
        updateMaps(mapsUpdateCooldown == -1 ? true : false)
    }
    
    // MARK: - Update functions
    
    func getTimeRemainingSeconds() -> Int {
        return Int(matchData!["endTimes"][0].doubleValue - NSDate().timeIntervalSince1970)
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
    
    func updateLabel() {
        guard liveLabel != nil && !mapError else { return }
        
        let timeRemainingSeconds = getTimeRemainingSeconds()
        
        if mapsUpdateCooldown >= 0 {
            liveLabel?.text = getTimeRemainingText(timeRemainingSeconds)
            mapsUpdateCooldown -= 1
            
            if mapsUpdateCooldown == -1 {
                tableView.reloadData()
            }
        } else {
            if (timeRemainingSeconds <= 0 || matchData!["startTimes"].arrayValue.last!.intValue == 0) && !mapError { updateMaps(false) }
            else { liveLabel?.text = getTimeRemainingText(timeRemainingSeconds) }
        }
    }
    
    func updateMaps(manually: Bool) {
        mapsUpdating = true
        tableView.reloadData()
        
        loadMaps({ data in
            // Artificial delay
            delay(1, closure: {
                self.mapsUpdating = false
                
                if self.matchData == data {
                    self.mapsUpdateCooldown = manually ? -1 : mapRefreshCooldown
                }
                else {
                    self.matchData = data
                }
                
                self.tableView.reloadData()
                self.scheduleNotifications()
            })
        })
    }
    
    func scheduleNotifications() {
        // Remove all scheduled notifications
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        // Don't do any scheduling if notifications are off
        if !NSUserDefaults.standardUserDefaults().boolForKey("mapNotificationsOn") { return }
        
        var matches = [Match]()
        let notificationSettings = loadNotifications()
        
        // Create Match items for each upcoming map
        for x in 2...5 {
            let startTime: NSTimeInterval = matchData!["startTimes"][x / 2].doubleValue
            let rankedMode = matchData!["rankedModes"][x / 2].stringValue
            let rankedMap = matchData!["rankedMaps"][x].stringValue
            let turfMap = matchData!["turfMaps"][x].stringValue
            
            matches.append(Match(map: turfMap, mode: "Turf War", time: startTime))
            matches.append(Match(map: rankedMap, mode: rankedMode, time: startTime))
        }
        
        // Schedule notifications as needed
        for notification in notificationSettings {
            for match in matches {
                if notification.containsMatch(match) {
                    let times = notification.getTimeNumbers()
                    let timeTexts = notification.getTimeTextMid()
                    
                    for (x, time) in times.enumerate() {
                        let localNotification = UILocalNotification()
                        let notificationText = "\(match.map) is up on \(match.mode) \(timeTexts[x])"
                        localNotification.alertTitle = notification.name
                        localNotification.alertBody = notificationText
                        localNotification.alertAction = "splat"
                        localNotification.fireDate = match.timeDate.dateByAddingTimeInterval(NSTimeInterval(time * -60))
                        localNotification.soundName = UILocalNotificationDefaultSoundName
                        localNotification.category = "RotationNotification"
                        
                        localNotification.userInfo = [NSObject : AnyObject]()
                        localNotification.userInfo!["alertName"] = notification.name
                        localNotification.userInfo!["map"] = match.map
                        localNotification.userInfo!["mode"] = match.mode
                        localNotification.userInfo!["timeText"] = timeTexts[x]
                        
                        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                        log.debug("Created Notification: \(notificationText)")
                    }
                }
            }
        }
        
        // Group notifications firing at the same time
        if let scheduledNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            var fireDates = [NSDate]()
            var names = [String]()
            var correspondingNotifications = [[UILocalNotification]]()
            
            // Organize identical notifications
            for scheduledNotification in scheduledNotifications {
                let curDate = scheduledNotification.fireDate!
                let curName = scheduledNotification.alertTitle!
                
                if !fireDates.contains(curDate) {
                    fireDates.append(curDate)
                    names.append(curName)
                    correspondingNotifications.append([scheduledNotification])
                }
                else {
                    correspondingNotifications[fireDates.indexOf(curDate)!].append(scheduledNotification)
                }
            }
            
            // Generate grouped notifications
            for notificationSet in correspondingNotifications {
                if notificationSet.count == 1 { continue }
                
                for notif in notificationSet {
                    UIApplication.sharedApplication().cancelLocalNotification(notif)
                    log.debug("Cancelled notification for grouping: \(notif.alertBody!)")
                }
                
                if notificationSet.count == 2 {
                    let map1 = notificationSet[0].userInfo!["map"] as! String
                    let map2 = notificationSet[1].userInfo!["map"] as! String
                    let mode1 = notificationSet[0].userInfo!["mode"] as! String
                    let mode2 = notificationSet[1].userInfo!["mode"] as! String
                    let timeText = notificationSet[0].userInfo!["timeText"] as! String
                    
                    let groupedNotification = UILocalNotification()
                    groupedNotification.alertTitle = notificationSet[0].alertTitle
                    groupedNotification.alertAction = "splat"
                    groupedNotification.fireDate = notificationSet[0].fireDate
                    groupedNotification.soundName = UILocalNotificationDefaultSoundName
                    groupedNotification.category = "RotationNotification"
                    
                    var text = "Notification error, please report"
                    
                    if map1 == map2 {
                        text = "\(map1) is up on \(mode1) + \(mode2) \(timeText)"
                    }
                    else if mode1 == mode2 {
                        text = "\(map1) + \(map2) are up on \(mode1) \(timeText)"
                    }
                    
                    groupedNotification.alertBody = text
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(groupedNotification)
                    log.debug("Created Grouped Notification: \(text)")
                }
                else if notificationSet.count == 3 {
                    let map1 = notificationSet[0].userInfo!["map"] as! String
                    let map2 = notificationSet[1].userInfo!["map"] as! String
                    let map3 = notificationSet[2].userInfo!["map"] as! String
                    let mode1 = notificationSet[0].userInfo!["mode"] as! String
                    let mode2 = notificationSet[1].userInfo!["mode"] as! String
                    let mode3 = notificationSet[2].userInfo!["mode"] as! String
                    let timeText = notificationSet[0].userInfo!["timeText"] as! String
                    
                    let groupedNotification = UILocalNotification()
                    groupedNotification.alertTitle = notificationSet[0].alertTitle
                    groupedNotification.alertAction = "splat"
                    groupedNotification.fireDate = notificationSet[0].fireDate
                    groupedNotification.soundName = UILocalNotificationDefaultSoundName
                    groupedNotification.category = "RotationNotification"
                    
                    var text = "Notification error, please report"
                    
                    if mode1 == mode2 {
                        text = "\(map1) + \(map2) are up on \(mode1) and \(map3) is up on \(mode3) \(timeText)"
                    }
                    else if mode1 == mode3 {
                        text = "\(map1) + \(map3) are up on \(mode1) and \(map2) is up on \(mode2) \(timeText)"
                    }
                    else if mode2 == mode3 {
                        text = "\(map2) + \(map3) are up on \(mode2) and \(map1) is up on \(mode1) \(timeText)"
                    }
                    
                    groupedNotification.alertBody = text
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(groupedNotification)
                    log.debug("Created Grouped Notification: \(text)")
                }
                else if notificationSet.count == 4 {
                    let map1 = notificationSet[0].userInfo!["map"] as! String
                    let map2 = notificationSet[1].userInfo!["map"] as! String
                    let map3 = notificationSet[2].userInfo!["map"] as! String
                    let map4 = notificationSet[3].userInfo!["map"] as! String
                    let mode1 = notificationSet[0].userInfo!["mode"] as! String
                    let mode2 = notificationSet[1].userInfo!["mode"] as! String
                    let mode3 = notificationSet[2].userInfo!["mode"] as! String
                    let mode4 = notificationSet[3].userInfo!["mode"] as! String
                    let timeText = notificationSet[0].userInfo!["timeText"] as! String
                    
                    let groupedNotification = UILocalNotification()
                    groupedNotification.alertTitle = notificationSet[0].alertTitle
                    groupedNotification.alertAction = "splat"
                    groupedNotification.fireDate = notificationSet[0].fireDate
                    groupedNotification.soundName = UILocalNotificationDefaultSoundName
                    groupedNotification.category = "RotationNotification"
                    
                    var text = "Notification error, please report"
                    
                    if mode1 == mode2 {
                        text = "\(map1) + \(map2) are up on \(mode1) and \(map3) + \(map4) are up on \(mode3) \(timeText)"
                    }
                    else if mode1 == mode3 {
                        text = "\(map1) + \(map3) are up on \(mode1) and \(map2) + \(map4) are up on \(mode2) \(timeText)"
                    }
                    else if mode1 == mode4 {
                        text = "\(map1) + \(map4) are up on \(mode1) and \(map2) + \(map3) are up on \(mode2) \(timeText)"
                    }
                    else if mode2 == mode3 {
                        text = "\(map2) + \(map3) are up on \(mode2) and \(map1) + \(map4) are up on \(mode1) \(timeText)"
                    }
                    else if mode2 == mode4 {
                        text = "\(map2) + \(map4) are up on \(mode2) and \(map1) + \(map3) are up on \(mode1) \(timeText)"
                    }
                    else if mode3 == mode4 {
                        text = "\(map3) + \(map4) are up on \(mode3) and \(map1) + \(map2) are up on \(mode1) \(timeText)"
                    }
                    
                    groupedNotification.alertBody = text
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(groupedNotification)
                    log.debug("Created Grouped Notification: \(text)")
                }
            }
        }
    }
}

class Match {
    var map: String!
    var mode: String!
    var time: NSTimeInterval!
    var timeDate: NSDate!
    
    init(map: String, mode: String, time: NSTimeInterval) {
        self.map = map
        self.mode = mode
        self.time = time
        self.timeDate = NSDate(timeIntervalSince1970: time)
    }
}
