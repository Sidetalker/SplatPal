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
    @IBOutlet weak var swtHideStatusBar: UISwitch!
    @IBOutlet weak var swtMilitaryTime: UISwitch!
    @IBOutlet weak var lblNotificationConfig: UILabel!
    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var cellNotificationConfig: UITableViewCell!
    @IBOutlet weak var cellLoginStatus: UITableViewCell!
    @IBOutlet weak var enableNotificationsIndent: NSLayoutConstraint!
    @IBOutlet weak var hideStatusBarIndent: NSLayoutConstraint!
    @IBOutlet weak var militaryTimeIndent: NSLayoutConstraint!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    let nnid = NNID.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localNotificationsStateUpdated:", name: "localNotificationsStateUpdated", object: nil)
        
        swtHideStatusBar.on = prefs.boolForKey("hideStatusBar")
        swtMilitaryTime.on = prefs.boolForKey("militaryTime")
        swtMapNotifications.on = prefs.boolForKey("mapNotificationsOn")
        toggleMapNotificationUI(swtMapNotifications.on)
        
        // Real cute iPhone 6+, REAL CUTE
        if DeviceType.IS_IPHONE_6P {
            enableNotificationsIndent.constant = 12
            hideStatusBarIndent.constant = 12
            militaryTimeIndent.constant = 12
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        lblLoginStatus.text = nnid.cookie != "" ? "Logged In" : "Not Logged In"
        cellLoginStatus.backgroundColor = nnid.cookie != "" ? SplatAppStyle.loggedIn : SplatAppStyle.loggedOut
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueConfigureNotifications" {
            let destVC = segue.destinationViewController as! NotificationTableViewController
            destVC.settingsTableVC = self
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return prefs.boolForKey("hideStatusBar")
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
        scheduleNotifications()
        lblNotificationConfig.enabled = on
        cellNotificationConfig.userInteractionEnabled = on
    }
    
    func localNotificationsStateUpdated(notification: NSNotification) {
        prefs.setBool(true, forKey: "notificationsDetermined")
        
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()!
        if notificationSettings.types == .None {
            swtMapNotifications.setOn(false, animated: true)
            toggleMapNotificationUI(false)
        }
    }
    
    func scheduleNotifications() {
        for vc in self.tabBarController!.viewControllers! {
            if let mapView = vc as? MapsTableViewController {
                mapView.scheduleNotifications()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == "cellResetGear" {
            let confirmAlert = UIAlertController(title: "Confirm Reset", message: "Are you sure you want to reset all owned gear you have marked? This action is not reversable.", preferredStyle: UIAlertControllerStyle.Alert)
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            confirmAlert.addAction(UIAlertAction(title: "Reset", style: .Destructive, handler: { _ in
                let prefs = NSUserDefaults.standardUserDefaults()
                for item in gearData {
                    prefs.setInteger(0, forKey: "\(item.shortName)-owned")
                }
                
                for vc in self.tabBarController!.viewControllers! {
                    if let gearView = vc as? GearGuideViewController {
                        gearView.gearTable?.tableView.reloadData()
                    }
                }
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func mapNotificationsToggled(sender: AnyObject) {
        toggleMapNotificationUI((sender as! UISwitch).on)
    }
    
    @IBAction func hideStatusBarToggled(sender: AnyObject) {
        prefs.setBool((sender as! UISwitch).on, forKey: "hideStatusBar")
        
        UIView.animateWithDuration(0.33) { self.setNeedsStatusBarAppearanceUpdate() }
    }
    
    @IBAction func militaryTimeToggled(sender: AnyObject) {
        prefs.setBool((sender as! UISwitch).on, forKey: "militaryTime")
        
        for vc in self.tabBarController!.viewControllers! {
            if let mapView = vc as? MapsTableViewController {
                mapView.tableView.reloadData()
            }
        }
    }
}

class NNIDSettingsTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var cellLoginStatus: UITableViewCell!
    @IBOutlet weak var cellUsername: UITableViewCell!
    @IBOutlet weak var cellPassword: UITableViewCell!
    @IBOutlet weak var cellLogin: UITableViewCell!
    @IBOutlet weak var cellLoginAutomatically: UITableViewCell!
    @IBOutlet weak var cellEnableTouchID: UITableViewCell!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var swtLoginAutomatically: UISwitch!
    @IBOutlet weak var swtEnableTouchID: UISwitch!
    
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    @IBOutlet weak var lblLogIn: UILabel!
    @IBOutlet weak var lblLoginStatus: UILabel!
    
    let nnid = NNID.sharedInstance
    var loggedIn = false
    var loggingIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !nnid.saveLogin {
            nnid.updateCredentials("", password: "")
        }
        
        updateUI(nnid.cookie != "")
        loginSpinner.hidden = true
    }
    
    func logout() {
        nnid.updateCookie("")
        nnid.updateSaveLogin(false)
        nnid.updateCredentials("", password: "")
        
        updateUI(false)
    }
    
    func login() {
        nnid.updateCredentials(txtUsername.text!, password: txtPassword.text!)
        self.navigationController?.navigationBar.topItem?.hidesBackButton = true
        self.lblLogIn.hidden = true
        self.loginSpinner.hidden = false
        self.loginSpinner.startAnimating()
        
        loginNNID { error in
            self.navigationController?.navigationBar.topItem?.hidesBackButton = false
            self.lblLogIn.hidden = false
            self.loginSpinner.hidden = true
            self.loginSpinner.stopAnimating()
            
            if error == nil {
                log.debug("Login Success")
                self.nnid.updateSaveLogin(true)
                self.updateUI(true)
                
                for vc in self.tabBarController!.viewControllers! {
                    if let mapView = vc as? MapsTableViewController {
                        mapView.updateMaps(true)
                    }
                }
            } else {
                log.error("Login Error: \(error!.localizedDescription)")
                
                let alert = UIAlertController(title: "Login Error", message: error!.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func updateUI(loggedIn: Bool) {
        self.loggedIn = loggedIn
        
        cellLoginAutomatically.hidden = !loggedIn || !nnid.hasCredentials()
//        cellEnableTouchID.hidden = !loggedIn
        cellLoginStatus.backgroundColor = loggedIn ? SplatAppStyle.loggedIn : SplatAppStyle.loggedOut
        lblLoginStatus.text = loggedIn ? "Logged In" : "Not Logged In"
        lblLogIn.text = loggedIn ? "Log Out" : "Log In"
        swtLoginAutomatically.on = nnid.saveLogin
        swtEnableTouchID.on = nnid.touchID
        txtUsername.text = nnid.username
        txtPassword.text = nnid.password
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtUsername {
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword {
            textField.resignFirstResponder()
            login()
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath == NSIndexPath(forRow: 2, inSection: 1) {
            loggedIn ? logout() : login()
        }
    }
    
    @IBAction func saveLoginSwitched(sender: AnyObject) {
        nnid.updateSaveLogin((sender as! UISwitch).on)
    }
}