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
var abilityData = [String : JSON]()

class LoadingViewController: UIViewController {
    
    var mapData: JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().tintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        loadJSONData()
        
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
    
    func loadJSONData() {
        if let
            brandPath = NSBundle.mainBundle().pathForResource("data.min", ofType: "json"),
            jsonData = NSData(contentsOfFile: brandPath)
        {
            let jsonResult = JSON(data: jsonData)
            
            brandData = jsonResult["brands"].arrayValue
            gearData = jsonResult["gear"].arrayValue
            abilityData = jsonResult["abilities"].dictionaryValue
        }
    }
}
