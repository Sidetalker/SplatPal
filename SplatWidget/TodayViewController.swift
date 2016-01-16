//
//  TodayViewController.swift
//  SplatWidget
//
//  Created by Kevin Sullivan on 12/21/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire

class TodayViewController: UIViewController, NCWidgetProviding {
    let prefs = NSUserDefaults.init(suiteName: "group.com.sideapps.SplatPal")!
    
    @IBOutlet weak var lblRanked1: UILabel!
    @IBOutlet weak var lblTime1: UILabel!
    @IBOutlet weak var lblRanked2: UILabel!
    @IBOutlet weak var lblTime2: UILabel!
    @IBOutlet weak var lblRanked3: UILabel!
    @IBOutlet weak var lblTime3: UILabel!
    
    @IBOutlet weak var lblMap1a: UILabel!
    @IBOutlet weak var lblMap1b: UILabel!
    @IBOutlet weak var lblMap1c: UILabel!
    @IBOutlet weak var lblMap1d: UILabel!
    
    @IBOutlet weak var lblMap2a: UILabel!
    @IBOutlet weak var lblMap2b: UILabel!
    @IBOutlet weak var lblMap2c: UILabel!
    @IBOutlet weak var lblMap2d: UILabel!
    
    @IBOutlet weak var lblMap3a: UILabel!
    @IBOutlet weak var lblMap3b: UILabel!
    @IBOutlet weak var lblMap3c: UILabel!
    @IBOutlet weak var lblMap3d: UILabel!
    
    @IBOutlet weak var dividerCenter: UIView!
    @IBOutlet weak var divider1and2: UIView!
    @IBOutlet weak var divider2and3: UIView!
    
    @IBOutlet weak var splatfestView: UIView!
    @IBOutlet weak var splatfestTeamA: UILabel!
    @IBOutlet weak var splatfestTeamB: UILabel!
    @IBOutlet weak var splatfestMap1: UILabel!
    @IBOutlet weak var splatfestMap2: UILabel!
    @IBOutlet weak var splatfestMap3: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 1)
        
        // Hide all views before initial load
        for view in self.view.subviews {
            view.alpha = 0.0
        }
        
        splatfestView.backgroundColor = UIColor.clearColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(4, 6, 8, 6)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
        
        // Configure NNID cookies
        let nnid = NNID.sharedInstance
        
        if !nnid.saveLogin {
            nnid.clearCookies()
        }
        else {
            if let cookie = nnid.cookieObj {
                Alamofire.Manager.sharedInstance.session.configuration.HTTPCookieStorage?.setCookie(NSHTTPCookie(properties: cookie)!)
            } else { loginNNID { error in } }
        }
        
        loadMaps { data in
            if data["errorCode"].int != nil {
                completionHandler(NCUpdateResult.Failed)
            }
            else {
                if data["splatfest"].boolValue {
                    NSLog("Splatfest found")
                    
                    self.splatfestTeamA.text = data["teams"][0].stringValue
                    self.splatfestTeamB.text = data["teams"][1].stringValue
                    self.splatfestMap1.text = data["turfMaps"][0].stringValue
                    self.splatfestMap2.text = data["turfMaps"][1].stringValue
                    self.splatfestMap3.text = data["turfMaps"][2].stringValue
                    
                    if self.splatfestView.alpha == 0.0 {
                        self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 80)
                        self.splatfestView.alpha = 1.0
                    }
                } else {
                    
                    // Unhide all views if they're hidden
                    if self.dividerCenter.alpha == 0.0 {
                        self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, 190)
                        
                        for view in self.view.subviews {
                            if view != self.splatfestView { view.alpha = 1.0 }
                        }
                    }
                    
                }
                
            }
        }
    }
}
