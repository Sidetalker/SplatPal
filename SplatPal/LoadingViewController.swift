//
//  LoadingViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

var brandData = [JSON]()
var gearData = [JSON]()
var mapData = [String]()
var modeData = [String]()
var abilityData = [String : JSON]()

class LoadingViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var squidOffset: NSLayoutConstraint!
    
    var nnid: NNID!
    var matchData: JSON?
    
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
        
        if nnid.saveLogin {
            loginNNID { error in
                loadMaps { data in
                    self.matchData = data
                    self.performSegueWithIdentifier("segueLoading", sender: self)
                }
            }
        } else {
            nnid.updateCookie("")
            loadMaps { data in
                self.matchData = data
                self.performSegueWithIdentifier("segueLoading", sender: self)
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabBarController = segue.destinationViewController as! UITabBarController
        let mapsTab = tabBarController.viewControllers![0] as! MapsTableViewController
        mapsTab.matchData = matchData
    }
    
    func loadJSONData() {
        if let
            brandPath = NSBundle.mainBundle().pathForResource("data.min", ofType: "json"),
            jsonData = NSData(contentsOfFile: brandPath)
        {
            let jsonResult = JSON(data: jsonData)
            
            brandData = jsonResult["brands"].arrayValue
            gearData = jsonResult["gear"].arrayValue
            mapData = jsonResult["maps"].arrayObject as! [String]
            modeData = jsonResult["modes"].arrayObject as! [String]
            abilityData = jsonResult["abilities"].dictionaryValue
            
            // Ugly hardcoded hack to fix Museum D'Alfonsino escape char
            mapData[12] = mapData[12].replace("\\", replacement: "")
        }
    }
}
