//
//  SettingTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/16/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var swtMapNotifications: UISwitch!
    @IBOutlet weak var segMapNotificationType: UISegmentedControl!
    @IBOutlet weak var lblGameType: UILabel!
    @IBOutlet weak var lblMapSelection: UILabel!
    @IBOutlet weak var cellGameType: UITableViewCell!
    @IBOutlet weak var cellMapSelection: UITableViewCell!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swtMapNotifications.on = prefs.boolForKey("mapNotificationsOn")
        segMapNotificationType.selectedSegmentIndex = prefs.integerForKey("mapNotificationType")
        toggleMapNotificationUI(swtMapNotifications.on)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueMapNotificationSettings" {
            let destVC = segue.destinationViewController as! MapSettingsTableViewController
            destVC.settingsTableVC = self
        }
    }
    
    func toggleMapNotificationUI(on: Bool) {
        prefs.setBool(on, forKey: "mapNotificationsOn")
        segMapNotificationType.enabled = on
        lblGameType.enabled = on
        lblMapSelection.enabled = on
        cellGameType.userInteractionEnabled = on
        cellMapSelection.userInteractionEnabled = on
    }
    
    @IBAction func mapNotificationsToggled(sender: AnyObject) {
        toggleMapNotificationUI((sender as! UISwitch).on)
    }
    
    @IBAction func mapNotificationTypeToggled(sender: AnyObject) {
        prefs.setInteger((sender as! UISegmentedControl).selectedSegmentIndex, forKey: "mapNotificationType")
    }
}

class MapSettingsTableViewController: UITableViewController {
    var settingsTableVC: SettingsTableViewController?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var showImages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200
//        tableView.rowHeight = UITableViewAutomaticDimension
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

class KeepsBackgroundLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    setse
//    override func setHighlighted(highlighted: Bool) {
//        let color = self.myLabel.backgroundColor
//        super.setHighlighted(highlighted, animated: animated)
//        self.myLabel.backgroundColor = color
//    }
}
