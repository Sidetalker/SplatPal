//
//  LoadingViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let APIString = "https://splatoon.ink/schedule.json"

class LoadingViewController: UIViewController {
    
    var startTimes = [NSTimeInterval]()
    var endTimes = [NSTimeInterval]()
    var turfMaps = [String]()
    var rankedMaps = [String]()
    var rankedModes = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        request(.GET, APIString, encoding: .URL, parameters: nil)
            .responseJSON { response in
                // Handle request failure
                if response.result.isFailure {
                    log.error("Error Loading Schedule: \(response.result.error)")
                    debugPrint(response)
                } else {
                    let json = JSON(response.result.value!)
                    
                    if json["splatfest"].boolValue { log.warning("Splatfest, IDK WHAT TO DO!!!") }
                    
                    for entry in json["schedule"].arrayValue {
                        self.startTimes.append(entry["startTime"].doubleValue / 1000)
                        self.endTimes.append(entry["endTime"].doubleValue / 1000)
                        self.turfMaps.append(entry["regular"]["maps"][0]["nameEN"].stringValue)
                        self.turfMaps.append(entry["regular"]["maps"][1]["nameEN"].stringValue)
                        self.rankedMaps.append(entry["ranked"]["maps"][0]["nameEN"].stringValue)
                        self.rankedMaps.append(entry["ranked"]["maps"][1]["nameEN"].stringValue)
                        self.rankedModes.append(entry["ranked"]["rulesEN"].stringValue)
                    }
                }
                
                self.performSegueWithIdentifier("segueInitial", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabBarController = segue.destinationViewController as! UITabBarController
        let mapsTab = tabBarController.viewControllers![0] as! MapsTableViewController
        mapsTab.startTimes = startTimes
        mapsTab.endTimes = endTimes
        mapsTab.turfMaps = turfMaps
        mapsTab.rankedMaps = rankedMaps
        mapsTab.rankedModes = rankedModes
    }
}
