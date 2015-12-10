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

func loadMaps(completion:(JSON?) -> ()) {
    request(.GET, APIString, encoding: .URL, headers: ["Cache-Control" : "max-age=0"])
        .responseJSON { response in
            // Handle request failure
            if response.result.isFailure {
                log.error("Error Loading Schedule: \(response.result.error)")
                
                completion(nil)
            } else {
                let json = JSON(response.result.value!)
                
                if json["splatfest"].boolValue { log.warning("Splatfest, IDK WHAT TO DO!!!") }
                
                var startTimes = [NSTimeInterval]()
                var endTimes = [NSTimeInterval]()
                var turfMaps = [String]()
                var rankedMaps = [String]()
                var rankedModes = [String]()
                
                for entry in json["schedule"].arrayValue {
                    startTimes.append(entry["startTime"].doubleValue / 1000)
                    endTimes.append(entry["endTime"].doubleValue / 1000)
                    turfMaps.append(entry["regular"]["maps"][0]["nameEN"].stringValue)
                    turfMaps.append(entry["regular"]["maps"][1]["nameEN"].stringValue)
                    rankedMaps.append(entry["ranked"]["maps"][0]["nameEN"].stringValue)
                    rankedMaps.append(entry["ranked"]["maps"][1]["nameEN"].stringValue)
                    rankedModes.append(entry["ranked"]["rulesEN"].stringValue)
                }
                
                let dataDict = ["startTimes" : startTimes, "endTimes" : endTimes, "turfMaps" : turfMaps, "rankedMaps" : rankedMaps, "rankedModes" : rankedModes]
                
                completion(JSON(dataDict))
            }
    }
}

class LoadingViewController: UIViewController {
    
    var mapData: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadMaps({ data in
            self.mapData = data
            self.performSegueWithIdentifier("segueLoading", sender: self)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tabBarController = segue.destinationViewController as! UITabBarController
        let mapsTab = tabBarController.viewControllers![0] as! MapsTableViewController
        mapsTab.mapData = mapData
    }
}
