//
//  GearGuideViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/13/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

func abilityUpForBrand(brandName: String) -> String {
    return abilityForBrand(brandName, up: true)
}

func abilityDownForBrand(brandName: String) -> String {
    return abilityForBrand(brandName, up: false)
}

func abilityForBrand(brandName: String, up: Bool) -> String {
    for brand in brandData {
        if brand["name"].stringValue == brandName {
            return up ? brand["abilityUp"]["name"].stringValue : brand["abilityDown"]["name"].stringValue
        }
    }
    
    return "Unknown"
}

class GearTableViewController: UITableViewController {
    var gearDisplayData = [JSON]()
    var gearDetailDisplaying = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateDisplay(newData: [JSON]) {
        gearDisplayData = newData
        gearDetailDisplaying = Array(count: newData.count, repeatedValue: false)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gearDisplayData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return gearDetailDisplaying[indexPath.row] ? 0 : 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let data = gearDisplayData[indexPath.row]
        
        if gearDetailDisplaying[indexPath.row] {
            cell = tableView.dequeueReusableCellWithIdentifier("cellGearDetail", forIndexPath: indexPath)
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("cellGear", forIndexPath: indexPath)
            let lblName = cell.viewWithTag(1) as! UILabel
            let imgGear = cell.viewWithTag(2) as! UIImageView
            let imgAbilityMain = cell.viewWithTag(3) as! UIImageView
            let imgAbilityBrand = cell.viewWithTag(4) as! UIImageView
            
            lblName.text = data["name"].stringValue
            imgGear.image = UIImage(named: "gear\(data["name"].stringValue.removeWhitespace()).png")
            imgAbilityMain.image = UIImage(named: "ability\(data["ability"].stringValue.removeWhitespace()).png")
            imgAbilityBrand.image = UIImage(named: "ability\(abilityUpForBrand(data["brand"].stringValue).removeWhitespace()).png")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        gearDetailDisplaying[indexPath.row] = !gearDetailDisplaying[indexPath.row]
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
}

class GearGuideViewController: UIViewController {
    var gearTable: GearTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueGearTable" {
            gearTable = segue.destinationViewController as? GearTableViewController
            gearTable?.updateDisplay(gearData)
        }
    }
}
