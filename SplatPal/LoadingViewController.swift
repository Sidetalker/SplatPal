//
//  LoadingViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LoadingViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var squidOffset: NSLayoutConstraint!
    
    var nnid: NNID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultPrefsFile = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as? [String : AnyObject]
        
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultPrefs!)
        
        nnid = NNID.sharedInstance
        
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")) {
            squidOffset.constant = 10
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        spinner.startAnimating()
        
        loadJSONData()
        
        if !nnid.saveLogin {
            nnid.clearCookies()
        }
        else {
            if let cookie = nnid.cookieObj {
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookie(NSHTTPCookie(properties: cookie)!)
            } else { loginNNID { error in } }
        }
        
        self.performSegueWithIdentifier("segueLoading", sender: self)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func loadJSONData() {
        if let
            brandPath = NSBundle.mainBundle().pathForResource("data.min", ofType: "json"),
            jsonData = NSData(contentsOfFile: brandPath)
        {
            let jsonResult = JSON(data: jsonData)
            
            brandData = jsonResult["brands"].arrayValue
            gearData = jsonResult["gear"].arrayValue
            weaponData = jsonResult["weapons"].arrayValue
            mapData = jsonResult["maps"].arrayObject as! [String]
            modeData = jsonResult["modes"].arrayObject as! [String]
            abilityData = jsonResult["abilities"].dictionaryValue
            
            // Ugly hardcoded hack to fix Museum D'Alfonsino escape char
            mapData[12] = mapData[12].replace("\\", replacement: "")
        }
    }
}
