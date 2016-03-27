//
//  NotificationsTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/20/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON
import MGSwipeTableCell

class NotificationTableViewController: UITableViewController {
    var settingsTableVC: SettingsTableViewController?
    var notifications: [Notification]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadNotifications()
    }
    
    func reloadNotifications() {
        notifications = loadNotifications()
        self.tableView.reloadData()
    }
    
    func addNotification(notification: Notification) {
        tableView.beginUpdates()
        
        notifications.append(notification)
        
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: notifications.count - 1, inSection: 1)], withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        saveNotifications(notifications)
        settingsTableVC?.scheduleNotifications()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return notifications.count == 0 ? "No notifications added" : "Tap to toggle - Swipe to view detail"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else if section == 1 { return notifications.count }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 && notifications.count == 0 {
            if let headerView = view as? UITableViewHeaderFooterView {
                headerView.textLabel?.textAlignment = .Center
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCellWithIdentifier("cellCreateNew", forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellNotification", forIndexPath: indexPath) as! MGSwipeTableCell
            cell.textLabel!.text = notifications[indexPath.row].name
            cell.accessoryType = notifications[indexPath.row].enabled ? .Checkmark : .None
            
            let expansionSettings = MGSwipeExpansionSettings()
            let editSwipe = MGSwipeButton(title: "Details", backgroundColor: UIColor.brownColor()) { _ in
                let reviewTVC = self.storyboard?.instantiateViewControllerWithIdentifier("reviewNotification") as! ReviewNotificationTableViewController
                reviewTVC.notification = self.notifications[indexPath.row]
                reviewTVC.navigationItem.rightBarButtonItem = nil
                reviewTVC.navigationItem.title = self.notifications[indexPath.row].name
                self.navigationController?.pushViewController(reviewTVC, animated: true)
                
                return true
            }
            let deleteSwipe = MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor()) { _ in
                tableView.beginUpdates()
                
                self.notifications.removeAtIndex(indexPath.row)
                saveNotifications(self.notifications)
                
                var reloads = [NSIndexPath]()
                
                for x in 0...self.notifications.count {
                    let curPath = NSIndexPath(forRow: x, inSection: 1)
                    if curPath != indexPath { reloads.append(curPath) }
                }
                
                tableView.reloadRowsAtIndexPaths(reloads, withRowAnimation: .None)
                tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                tableView.endUpdates()
                
                return true
            }
            
            expansionSettings.buttonIndex = 0
            expansionSettings.fillOnTrigger = true
            expansionSettings.threshold = 1.2
            cell.rightButtons = [editSwipe, deleteSwipe]
            cell.rightExpansion = expansionSettings
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            self.performSegueWithIdentifier("segueNewNotification", sender: self)
        } else {
            tableView.beginUpdates()
            
            notifications[indexPath.row].toggleEnabled()
            saveNotifications(notifications)
            settingsTableVC?.scheduleNotifications()
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueNewNotification" {
            let destVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! ModeSettingsTableViewController
            destVC.notificationTableVC = self
        }
    }
}

class Notification {
    let timeVals = [0, 5, 10, 15, 30, 60, 120, 180]
    
    var modes = [Bool](count: modeData.count, repeatedValue: false)
    var maps = [Bool](count: mapData.count, repeatedValue: false)
    var times = [Bool](count: 8, repeatedValue: false)
    
    var enabled = true
    var name = ""
    
    init() { }
    
    init(data: JSON) {
        for (x, mode) in data["modes"].arrayValue.enumerate() { modes[x] = mode.boolValue }
        for (x, map) in data["maps"].arrayValue.enumerate() { maps[x] = map.boolValue }
        for (x, time) in data["times"].arrayValue.enumerate() { times[x] = time.boolValue }
        enabled = data["enabled"].boolValue
        name = data["name"].stringValue
    }
    
    func jsonRepresentation() -> JSON {
        var rep = JSON([:])
        
        rep["modes"] = JSON(modes)
        rep["maps"] = JSON(maps)
        rep["times"] = JSON(times)
        rep["enabled"] = JSON(enabled)
        rep["name"] = JSON(name)
        
        return rep
    }
    
    func containsMatch(match: Stage) -> Bool {
        if !enabled { return false }
        
        var modeMatch = false
        var mapMatch = false
        
        for (x, mode) in modes.enumerate() {
            if mode && modeData[x] == match.mode {
                modeMatch = true
                break
            }
        }
        
        for (x, map) in maps.enumerate() {
            if map && mapData[x] == match.map {
                mapMatch = true
                break
            }
        }
        
        return modeMatch && mapMatch
    }
    
    func toggleEnabled() {
        enabled = !enabled
    }
    
    func hasMode(modeIndex: Int) -> Bool {
        return modes[modeIndex]
    }
    
    func toggleMode(modeIndex: Int) {
        modes[modeIndex] = !modes[modeIndex]
    }
    
    func anyModeSelected() -> Bool {
        return modes.contains(true)
    }
    
    func getModes() -> [String] {
        var selectedModes = [String]()
        
        for (x, mode) in modes.enumerate() {
            if mode { selectedModes.append(modeData[x]) }
        }
        
        return selectedModes
    }
    
    func hasMap(mapIndex: Int) -> Bool {
        return maps[mapIndex]
    }
    
    func toggleMap(mapIndex: Int) {
        maps[mapIndex] = !maps[mapIndex]
    }
    
    func anyMapSelected() -> Bool {
        return maps.contains(true)
    }
    
    func getMaps() -> [String] {
        var selectedMaps = [String]()
        
        for (x, map) in maps.enumerate() {
            if map { selectedMaps.append(mapData[x]) }
        }
        
        return selectedMaps
    }
    
    func hasTime(timeIndex: Int) -> Bool {
        return times[timeIndex]
    }
    
    func toggleTime(timeIndex: Int) {
        times[timeIndex] = !times[timeIndex]
    }
    
    func anyTimeSelected() -> Bool {
        return times.contains(true)
    }
    
    func getTimes() -> [String] {
        var selectedTimes = [String]()
        
        for (x, time) in times.enumerate() {
            if time { selectedTimes.append(timeText(x)) }
        }
        
        return selectedTimes
    }
    
    func getTimeNumbers() -> [Int] {
        var selectedTimes = [Int]()
        
        for (x, time) in times.enumerate() {
            if time { selectedTimes.append(timeVals[x]) }
        }
        
        return selectedTimes
    }
    
    func getTimeTextMid() -> [String] {
        var selectedTimes = [String]()
        
        for (x, time) in times.enumerate() {
            if time { selectedTimes.append(timeTextMid(x)) }
        }
        
        return selectedTimes
    }
    
    func timeText(timeIndex: Int) -> String {
        let time = timeVals[timeIndex]
        
        if time == 0 { return "When it happens" }
        else if time < 60 { return "\(time) minutes before" }
        else if time >= 60 { return "\(time / 60) hour\(time / 60 > 1 ? "s" : "") before" }
        
        return "???"
    }
    
    func timeTextMid(timeIndex: Int) -> String {
        let time = timeVals[timeIndex]
        
        if time == 0 { return "right now" }
        else if time < 60 { return "in \(time) minutes" }
        else if time >= 60 { return "in \(time / 60) hour\(time / 60 > 1 ? "s" : "")" }
        
        return "???"
    }
}

class ModeSettingsTableViewController: UITableViewController {
    var notificationTableVC: NotificationTableViewController?
    var notification: Notification!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notification == nil { notification = Notification() }
        self.navigationItem.rightBarButtonItem?.enabled = notification.anyModeSelected()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueSelectMaps" {
            let destVC = segue.destinationViewController as! MapSettingsTableViewController
            destVC.notification = notification
            destVC.notificationTableVC = notificationTableVC
            destVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: destVC, action: #selector(MapSettingsTableViewController.nextTapped))
            destVC.navigationItem.title = "Maps"
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modeData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellMode", forIndexPath: indexPath)
        let mode = modeData[indexPath.row]
        
        cell.textLabel?.text = mode
        cell.accessoryType = notification.hasMode(indexPath.row) ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.beginUpdates()
        
        notification.toggleMode(indexPath.row)
        self.navigationItem.rightBarButtonItem?.enabled = notification.anyModeSelected()
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select one or more modes"
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class MapSettingsTableViewController: UITableViewController {
    var notificationTableVC: NotificationTableViewController?
    var notification: Notification!
    var showImages = false
    var selectAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notification == nil { notification = Notification() }
        self.navigationItem.rightBarButtonItem?.enabled = notification.anyMapSelected()
        tableView.estimatedRowHeight = 44
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : mapData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 || !showImages { return 44 }
        else { return UITableViewAutomaticDimension }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Select one or more maps"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("cellShowHide", forIndexPath: indexPath)
            let lbl = cell.viewWithTag(1) as! UILabel
            
            if indexPath.row == 0 {
                lbl.text = showImages ? "Hide Map Images" : "Show Map Images"
            }
            else if indexPath.row == 1 {
                lbl.text = selectAll ? "Deselect All Maps" : "Select All Maps"
            }
        } else {
            let mapName = mapData[indexPath.row]
            if showImages {
                cell = tableView.dequeueReusableCellWithIdentifier("cellMapImage", forIndexPath: indexPath)
                let imgMap = cell.viewWithTag(1) as! UIImageView
                let lblMapName = cell.viewWithTag(2) as! UILabel
                
                imgMap.image = UIImage(named: "Stage\(mapName.removeWhitespace()).jpg")
                imgMap.layer.cornerRadius = 5
                lblMapName.text = mapName
                cell.accessoryType = notification.hasMap(indexPath.row) ? .Checkmark : .None
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("cellMapText", forIndexPath: indexPath)
                cell.textLabel?.text = mapName
                cell.accessoryType = notification.hasMap(indexPath.row) ? .Checkmark : .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            tableView.beginUpdates()
            
            var indices = [NSIndexPath]()
            
            if indexPath.row == 0 {
                showImages = !showImages
                
                indices.append(NSIndexPath(forRow: 0, inSection: 0))
                for x in 0...mapData.count - 1 {
                    indices.append(NSIndexPath(forRow: x, inSection: 1))
                }
            }
            else if indexPath.row == 1 {
                selectAll = !selectAll
                
                self.navigationItem.rightBarButtonItem?.enabled = selectAll
                
                indices.append(NSIndexPath(forRow: 1, inSection: 0))
                for x in 0...notification.maps.count - 1 {
                    if selectAll ? !notification.hasMap(x) : notification.hasMap(x) {
                        indices.append(NSIndexPath(forRow: x, inSection: 1))
                        notification.toggleMap(x)
                    }
                }
            }
            
            tableView.reloadRowsAtIndexPaths(indices, withRowAnimation: .Automatic)
            tableView.endUpdates()
        } else {
            tableView.beginUpdates()
            
            notification.toggleMap(indexPath.row)
            self.navigationItem.rightBarButtonItem?.enabled = notification.anyMapSelected()
            
            if !notification.anyMapSelected() && selectAll {
                selectAll = !selectAll
                tableView.reloadRowsAtIndexPaths([indexPath, NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Automatic)
            } else {
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
            
            tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard cell.reuseIdentifier == "cellMapImage" else { return }
        
        // Resize map label font to give it some padding
        let lblName = cell.viewWithTag(2) as! UILabel
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
    
    func nextTapped() {
        self.performSegueWithIdentifier("segueSelectTimes", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueSelectTimes" {
            let destVC = segue.destinationViewController as! NotificationTimeTableViewController
            destVC.notification = notification
            destVC.notificationTableVC = notificationTableVC
            destVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Review", style: .Done, target: destVC, action: #selector(NotificationTimeTableViewController.reviewTapped))
            destVC.navigationItem.title = "Times"
        }
    }
}

class NotificationTimeTableViewController: UITableViewController {
    var notificationTableVC: NotificationTableViewController?
    var notification: Notification!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notification == nil { notification = Notification() }
        self.navigationItem.rightBarButtonItem?.enabled = notification.anyTimeSelected()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueReviewNotification" {
            let destVC = segue.destinationViewController as! ReviewNotificationTableViewController
            destVC.notification = notification
            destVC.notificationTableVC = notificationTableVC
            destVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .Done, target: destVC, action: #selector(ReviewNotificationTableViewController.createTapped))
            destVC.navigationItem.title = "Review"
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification.timeVals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellTime", forIndexPath: indexPath)
        
        cell.textLabel?.text = notification.timeText(indexPath.row)
        cell.accessoryType = notification.hasTime(indexPath.row) ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.beginUpdates()
        
        notification.toggleTime(indexPath.row)
        self.navigationItem.rightBarButtonItem?.enabled = notification.anyModeSelected()
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select one or more times"
    }
    
    func reviewTapped() {
        self.performSegueWithIdentifier("segueReviewNotification", sender: self)
    }
}

class ReviewNotificationTableViewController: UITableViewController {
    var notificationTableVC: NotificationTableViewController?
    var notification: Notification!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notification == nil { notification = Notification() }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return notification.getModes().count }
        else if section == 1 { return notification.getMaps().count }
        else if section == 2 { return notification.getTimes().count }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellReview", forIndexPath: indexPath)
        
        if indexPath.section == 0 { cell.textLabel?.text = notification.getModes()[indexPath.row] }
        else if indexPath.section == 1 { cell.textLabel?.text = notification.getMaps()[indexPath.row] }
        else if indexPath.section == 2 { cell.textLabel?.text = notification.getTimes()[indexPath.row] }
        
        cell.userInteractionEnabled = false
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.beginUpdates()
        
        notification.toggleTime(indexPath.row)
        self.navigationItem.rightBarButtonItem?.enabled = notification.anyModeSelected()
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Modes" }
        else if section == 1 { return "Maps" }
        else if section == 2 { return "Times" }
        
        return nil
    }
    
    func createTapped() {
        let getNameAlert = UIAlertController(title: "Name your notification", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        getNameAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Notification Name"
        }
        getNameAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        getNameAlert.addAction(UIAlertAction(title: "Create", style: .Default, handler: { _ in
            if getNameAlert.textFields![0].text != "" {
                self.notification.name = getNameAlert.textFields![0].text!
                self.notificationTableVC?.addNotification(self.notification)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let tryAgainAlert = UIAlertController(title: "Error creating notification", message: "Your notification must have a name!", preferredStyle: .Alert)
                tryAgainAlert.addAction(UIAlertAction(title: "Oh, OK!", style: .Default, handler: { _ in
                    self.createTapped()
                }))
                
                self.presentViewController(tryAgainAlert, animated: true, completion: nil)
            }
        }))
        
        self.presentViewController(getNameAlert, animated: true, completion: nil)
    }
}
