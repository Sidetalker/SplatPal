//
//  SettingTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/16/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIApplicationDelegate {
    @IBOutlet weak var swtMapNotifications: UISwitch!
    @IBOutlet weak var lblMapSelection: UILabel!
    @IBOutlet weak var lblModeSelection: UILabel!
    @IBOutlet weak var cellGameType: UITableViewCell!
    @IBOutlet weak var cellMapSelection: UITableViewCell!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localNotificationsStateUpdated:", name: "localNotificationsStateUpdated", object: nil)
        
        swtMapNotifications.on = prefs.boolForKey("mapNotificationsOn")
        toggleMapNotificationUI(swtMapNotifications.on)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueMapNotificationSettings" {
            let destVC = segue.destinationViewController as! MapSettingsTableViewController
            destVC.settingsTableVC = self
        }
    }
    
    func toggleMapNotificationUI(on: Bool) {
        if on {
            let notificationsStateSet = prefs.boolForKey("notificationsDetermined")
            let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
            
            if notificationsStateSet && notificationSettings.types == .None {
                let alert = UIAlertController(title: "Notifications are not allowed", message: "SplatPal has been denied permission to send notifications - you can change this in Settings.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Open Settings", style: .Default) { action in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                    })
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                swtMapNotifications.setOn(false, animated: true)
                
                return
            }
            else if notificationSettings.types == .None {
                UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil))
            }
        }
        
        prefs.setBool(on, forKey: "mapNotificationsOn")
        lblMapSelection.enabled = on
        lblModeSelection.enabled = on
        cellGameType.userInteractionEnabled = on
        cellMapSelection.userInteractionEnabled = on
    }
    
    func localNotificationsStateUpdated(notification: NSNotification) {
        prefs.setBool(true, forKey: "notificationsDetermined")
        
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        if notificationSettings.types == .None {
            swtMapNotifications.setOn(false, animated: true)
            toggleMapNotificationUI(false)
        }
    }
    
    @IBAction func mapNotificationsToggled(sender: AnyObject) {
        toggleMapNotificationUI((sender as! UISwitch).on)
    }
}

class ModeSettingsTableViewController: UITableViewController {
    var settingsTableVC: SettingsTableViewController?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modeData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let mode = modeData[indexPath.row]
        
        cell.textLabel?.text = mode
        cell.accessoryType = prefs.boolForKey("notify\(mode.removeWhitespace())") ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.beginUpdates()
        
        let prefName = "notify\(modeData[indexPath.row].removeWhitespace())"
        prefs.setBool(!prefs.boolForKey(prefName), forKey: prefName)
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
}

class MapSettingsTableViewController: UITableViewController {
    var settingsTableVC: SettingsTableViewController?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var showImages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : mapData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 || !showImages { return 44 }
        else { return UITableViewAutomaticDimension }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("cellShowHide", forIndexPath: indexPath)
            let lblShowHide = cell.viewWithTag(1) as! UILabel
            lblShowHide.text = showImages ? "Hide Map Images" : "Show Map Images"
        } else {
            let mapName = mapData[indexPath.row]
            if showImages {
                cell = tableView.dequeueReusableCellWithIdentifier("cellMapImage", forIndexPath: indexPath)
                let imgMap = cell.viewWithTag(1) as! UIImageView
                let lblMapName = cell.viewWithTag(2) as! UILabel
                
                imgMap.image = UIImage(named: "Stage\(mapName.removeWhitespace()).jpg")
                imgMap.layer.cornerRadius = 5
                lblMapName.text = mapName
                cell.accessoryType = prefs.boolForKey("notify\(mapName.removeWhitespace())") ? .Checkmark : .None
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("cellMapText", forIndexPath: indexPath)
                cell.textLabel?.text = mapName
                cell.accessoryType = prefs.boolForKey("notify\(mapName.removeWhitespace())") ? .Checkmark : .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            tableView.beginUpdates()
            
            showImages = !showImages
            
            var indices = [NSIndexPath]()
            indices.append(NSIndexPath(forRow: 0, inSection: 0))
            for x in 0...mapData.count - 1 {
                indices.append(NSIndexPath(forRow: x, inSection: 1))
            }
            
            tableView.reloadRowsAtIndexPaths(indices, withRowAnimation: .Automatic)
            tableView.endUpdates()
        } else {
            tableView.beginUpdates()
            
            let prefName = "notify\(mapData[indexPath.row].removeWhitespace())"
            prefs.setBool(!prefs.boolForKey(prefName), forKey: prefName)
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
}
