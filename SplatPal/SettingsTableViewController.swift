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
    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var cellGameType: UITableViewCell!
    @IBOutlet weak var cellMapSelection: UITableViewCell!
    @IBOutlet weak var cellLoginStatus: UITableViewCell!
    @IBOutlet weak var enableNotificationsIndent: NSLayoutConstraint!
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localNotificationsStateUpdated:", name: "localNotificationsStateUpdated", object: nil)
        
        swtMapNotifications.on = prefs.boolForKey("mapNotificationsOn")
        toggleMapNotificationUI(swtMapNotifications.on)
        
        // Real cute iPhone 6+, REAL CUTE
        if DeviceType.IS_IPHONE_6P {
            enableNotificationsIndent.constant = 12
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueMapNotificationSettings" {
            let destVC = segue.destinationViewController as! MapSettingsTableViewController
            destVC.settingsTableVC = self
        }
        else if segue.identifier == "segueModeNotificationSettings" {
            let destVC = segue.destinationViewController as! ModeSettingsTableViewController
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
    
    func scheduleNotifications() {
        for vc in self.tabBarController!.viewControllers! {
            if let mapView = vc as? MapsTableViewController {
                mapView.scheduleNotifications()
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    @IBAction func mapNotificationsToggled(sender: AnyObject) {
        toggleMapNotificationUI((sender as! UISwitch).on)
    }
}

class NNID {
    static let sharedInstance = NNID()
    
    private let prefs = NSUserDefaults.standardUserDefaults()
    internal var username = ""
    internal var password = ""
    internal var cookie = ""
    internal var saveLogin = false
    internal var touchID = false
    
    private init() {
        if let
            username = prefs.stringForKey("NNIDUsername"),
            password = prefs.stringForKey("NNIDPassword"),
            cookie = prefs.stringForKey("NNIDCookie")
        {
            self.username = username
            self.password = password
            self.cookie = cookie
            self.saveLogin = prefs.boolForKey("NNIDSaveLogin")
            self.touchID = prefs.boolForKey("NNIDTouchID")
        }
    }
    
    func updateCredentials(username: String, password: String) {
        self.username = username
        self.password = password
        prefs.setObject(username, forKey: "NNIDUsername")
        prefs.setObject(password, forKey: "NNIDPassword")
    }
    
    func updateCookie(cookie: String) {
        self.cookie = cookie
        prefs.setObject(cookie, forKey: "NNIDCookie")
    }
    
    func updateSaveLogin(saveLogin: Bool) {
        self.saveLogin = saveLogin
        prefs.setBool(saveLogin, forKey: "NNIDSaveLogin")
    }
    
    func updateTouchID(touchID: Bool) {
        self.touchID = touchID
        prefs.setBool(touchID, forKey: "NNIDTouchID")
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
            nnid.updateCookie("")
            nnid.updateCredentials("", password: "")
        }
        
        updateUI(nnid.cookie != "")
        loginSpinner.hidden = true
    }
    
    func logout() {
        nnid.updateCookie("")
        nnid.updateCredentials("", password: "")
        updateUI(false)
    }
    
    func login() {
        nnid.updateCredentials(txtUsername.text!, password: txtPassword.text!)
        self.lblLogIn.hidden = true
        self.loginSpinner.hidden = false
        self.loginSpinner.startAnimating()
        
        loginNNID { success in
            self.lblLogIn.hidden = false
            self.loginSpinner.hidden = true
            self.loginSpinner.stopAnimating()
            
            log.debug("Success: \(success)")
            self.updateUI(success)
        }
    }
    
    func updateUI(loggedIn: Bool) {
        self.loggedIn = loggedIn
        
        cellLoginAutomatically.hidden = !loggedIn
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
        
        settingsTableVC?.scheduleNotifications()
    }
}

class MapSettingsTableViewController: UITableViewController {
    var settingsTableVC: SettingsTableViewController?
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var showImages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
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
            
            settingsTableVC?.scheduleNotifications()
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
