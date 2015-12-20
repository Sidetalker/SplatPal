//
//  NotificationsTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/20/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationTableViewController: UITableViewController {
    var settingsTableVC: SettingsTableViewController?
    var notifications: [JSON]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotifications()
    }
    
    
}
