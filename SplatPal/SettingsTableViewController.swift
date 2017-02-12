//
//  SettingTableViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/16/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import Crashlytics
import SwiftyJSON

// MARK: - SettingsTableViewController

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
    
    // MARK: Initializations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.localNotificationsStateUpdated(_:)), name: "localNotificationsStateUpdated", object: nil)
        
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
    
    // MARK: Logic manipulation
    
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
    
    // MARK: TableView BS
    
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
    
    // MARK: IBActions
    
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

// MARK: - NNIDSettingsTableViewController

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
    
    // MARK: Initializations
    
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
    
    // MARK: Core Logic
    
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
    
    // MARK: UI manipulation
    
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
    
    // MARK: TableView Shenanigans
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath == NSIndexPath(forRow: 2, inSection: 1) {
            loggedIn ? logout() : login()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func saveLoginSwitched(sender: AnyObject) {
        nnid.updateSaveLogin((sender as! UISwitch).on)
    }
}

// MARK: - SettingsTableViewController

class LocaleTableViewController: UITableViewController {
    let prefs = NSUserDefaults.standardUserDefaults()
    let deviceLocale = NSLocale(localeIdentifier: NSLocale.preferredLanguages()[0])
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let index = availableLanguages.indexOf(gearData[0].locale) else {
            log.error("Locale is somehow not in availableLanguages (dis impossible yo)")
            CLSLogv("Locale mismatch in Settings", getVaList([]))
            return
        }
        
        selectedIndex = index
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return prefs.boolForKey("hideStatusBar")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : availableLanguages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Sorry about the mediocre readability here, friend
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            let deviceLocaleString = deviceLocale.displayNameForKey(NSLocaleIdentifier, value: NSLocale.preferredLanguages()[0]) ?? "Unknown"
            let selectedLocaleString = deviceLocale.displayNameForKey(NSLocaleIdentifier, value: gearData[0].locale) ?? "Unknown"
            
            let localeString = NSMutableAttributedString(
                string: indexPath.row == 0 ? "Device Locale: \(deviceLocaleString)" : "Selected Locale: \(selectedLocaleString)")
            
            localeString.beginEditing()
            localeString.addAttribute(NSFontAttributeName,
                                      value: UIFont.boldSystemFontOfSize(UIFont.labelFontSize()),
                                      range: NSMakeRange(0, indexPath.row == 0 ? 14 : 16))
            localeString.endEditing()
            
            cell.textLabel?.attributedText = localeString
            
            return cell
        case 1:
            let cellId = "localeCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellId) ?? UITableViewCell(style: .Default, reuseIdentifier: cellId)
            cell.textLabel?.text = deviceLocale.displayNameForKey(NSLocaleIdentifier, value: availableLanguages[indexPath.row])
            cell.accessoryType = indexPath.row == selectedIndex ? .Checkmark : .None
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let
            dataPath = NSBundle.mainBundle().pathForResource("data.min", ofType: "json"),
            jsonData = NSData(contentsOfFile: dataPath)
        {
            let jsonResult = JSON(data: jsonData)
            let localeMod = availableLanguages[indexPath.row]
            
            NSUserDefaults.standardUserDefaults().setObject(localeMod, forKey: "localeMod")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            brandData = jsonResult["brands"].arrayValue
            gearData = jsonResult["gear"].arrayValue.map { Gear(data: $0, locale: localeMod) }
            gearData.sortInPlace { $0.localizedName < $1.localizedName }
            
            for vc in tabBarController!.viewControllers! {
                if
                    let gearVC = vc as? GearGuideViewController,
                    let gearTable = gearVC.gearTable
                {
                    gearTable.updateDisplay(gearData)
                    gearTable.tableView.reloadData()
                }
            }
            
            tableView.beginUpdates()
            
            let indexPaths = [indexPath, NSIndexPath(forRow: selectedIndex, inSection: 1), NSIndexPath(forRow: 1, inSection: 0)]
            selectedIndex = indexPath.row
            
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            
            tableView.endUpdates()
        } else {
            log.error("Couldn't change locale to setting selection (dis impossible yo)")
            CLSLogv("Weirddd locale mismatch in Settings", getVaList([]))
        }
    }
}