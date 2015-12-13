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
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        gearDetailDisplaying[indexPath.row] = !gearDetailDisplaying[indexPath.row]
//        
//        tableView.beginUpdates()
//        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        tableView.endUpdates()
    }
}

class GearGuideViewController: UIViewController, IconSelectionViewDelegate {
    @IBOutlet weak var iconView: IconSelectionView!
    @IBOutlet weak var iconViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconViewXLoc: NSLayoutConstraint!
    
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var imgSub: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    
    var gearTable: GearTableViewController?
    
    // 0 for main, 1 for sub
    var selectionFlag = -1
    var mainAbility = "None"
    var subAbility = "None"
    var category = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconView.delegate = self
        iconView.clipsToBounds = false
        iconView.singleSelection = true
        iconView.layer.shadowColor = UIColor.blackColor().CGColor
        iconView.layer.shadowOffset = CGSizeZero
        iconView.layer.shadowOpacity = 0.5
        iconView.switchTypes("abilities")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        iconView.updateDisplay(false, displayTitle: true)
        iconViewHeight.constant = iconView.getProperHeight()
        iconViewXLoc.constant = -iconViewHeight.constant - tabBarHeight
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
    
    func toggleIconView(show: Bool) {
        iconViewXLoc.constant = show ? 0 : -iconViewHeight.constant - tabBarHeight
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func iconSelectionViewAbilitiesUpdated(view: IconSelectionView, selectedAbilities: [String]) {
        let abilityImage = UIImage(named: "ability\(selectedAbilities[0].removeWhitespace()).png")
        
        if selectionFlag == 0 {
            mainAbility = selectedAbilities[0]
            imgMain.image = abilityImage
        }
        else if selectionFlag == 1 {
            subAbility = selectedAbilities[0]
            imgSub.image = abilityImage
        }
        
        var newGear = [JSON]()
        for gear in gearData {
            var valid = true
            
            if gear["ability"].stringValue != mainAbility && mainAbility != "None" { valid = false }
            if abilityUpForBrand(gear["brand"].stringValue) != subAbility && subAbility != "None" { valid = false }
            if gear["category"].stringValue != category && category != "All" { valid = false }
            
            if valid { newGear.append(gear) }
            
//            Clothing - Hat
//            Headgear - Shirt
//            Shoes
        }
        
        gearTable?.gearDisplayData = newGear
        gearTable?.tableView.reloadData()
        toggleIconView(false)
    }
    
    @IBAction func mainButtonTapped(sender: AnyObject) {
        selectionFlag = 0
        iconView.toggleLimitedAbilities(false)
        iconView.currentSelection = -1
        iconView.lblTitle.text = "Select Main Ability"
        iconViewHeight.constant = iconView.getProperHeight() > view.frame.height * 3 / 4 ? view.frame.height * 3 / 4 : iconView.getProperHeight()
        toggleIconView(true)
    }
    
    @IBAction func subButtonTapped(sender: AnyObject) {
        selectionFlag = 1
        iconView.toggleLimitedAbilities(true)
        iconView.currentSelection = -1
        iconView.lblTitle.text = "Select Sub Ability"
        iconViewHeight.constant = iconView.getProperHeight()
        toggleIconView(true)
    }
    
    @IBAction func typeButtonTapped(sender: AnyObject) {
        
    }
    
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject) {
        return
    }
    
    func iconSelectionViewBrandsUpdated(view: IconSelectionView, selectedBrands: [String]) {
        return
    }
}
