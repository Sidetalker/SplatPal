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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : mapD
    }
}
