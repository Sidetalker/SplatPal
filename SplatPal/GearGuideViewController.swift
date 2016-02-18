//
//  GearGuideViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/13/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON
import MGSwipeTableCell

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
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
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
        return gearDetailDisplaying[indexPath.row] ? 195 : 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = MGSwipeTableCell()
        let data = gearDisplayData[indexPath.row]
        
        if gearDetailDisplaying[indexPath.row] {
            cell = tableView.dequeueReusableCellWithIdentifier("cellGearDetail", forIndexPath: indexPath) as! MGSwipeTableCell
            let lblName = cell.viewWithTag(1) as! UILabel
            let imgGear = cell.viewWithTag(2) as! UIImageView
            let imgAbilityMain = cell.viewWithTag(3) as! UIImageView
            let imgAbilityBrand = cell.viewWithTag(4) as! UIImageView
            let lblAbilityMain = cell.viewWithTag(5) as! UILabel
            let lblAbilityBrand = cell.viewWithTag(6) as! UILabel
            let lblCost = cell.viewWithTag(7) as! UILabel
            let lblBrand = cell.viewWithTag(8) as! UILabel
            let imgStar2 = cell.viewWithTag(10) as! UIImageView
            let imgStar3 = cell.viewWithTag(11) as! UIImageView
            
            let abilityUp = data["ability"].stringValue
            let abilityBrand = abilityUpForBrand(data["brand"].stringValue)
            
            lblName.text = data["name"].stringValue
            imgGear.image = UIImage(named: "gear\(data["name"].stringValue.removeWhitespace()).png")
            imgAbilityMain.image = UIImage(named: "ability\(abilityUp.removeWhitespace()).png")
            imgAbilityBrand.image = UIImage(named: "ability\(abilityBrand.removeWhitespace()).png")
            lblAbilityMain.text = abilityData[abilityUp]?.stringValue
            lblAbilityBrand.text = abilityData[abilityBrand]?.stringValue
            lblCost.text = "Cost: \(data["cost"].stringValue)"
            lblBrand.text = "Brand: \(data["brand"].stringValue)"
            
            if data["rarity"].intValue == 1 {
                imgStar2.image = nil
                imgStar3.image = nil
            }
            if data["rarity"].intValue == 2 {
                imgStar2.image = UIImage(named: "star.png")
                imgStar3.image = nil
            }
            if data["rarity"].intValue == 3 {
                imgStar2.image = UIImage(named: "star.png")
                imgStar3.image = UIImage(named: "star.png")
            }
            
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("cellGear", forIndexPath: indexPath) as! MGSwipeTableCell
            let lblName = cell.viewWithTag(1) as! UILabel
            let imgGear = cell.viewWithTag(2) as! UIImageView
            let imgAbilityMain = cell.viewWithTag(3) as! UIImageView
            let imgAbilityBrand = cell.viewWithTag(4) as! UIImageView
            
            lblName.text = data["name"].stringValue
            imgGear.image = UIImage(named: "gear\(data["name"].stringValue.removeWhitespace()).png")
            imgAbilityMain.image = UIImage(named: "ability\(data["ability"].stringValue.removeWhitespace()).png")
            imgAbilityBrand.image = UIImage(named: "ability\(abilityUpForBrand(data["brand"].stringValue).removeWhitespace()).png")
        }
        
        let owned = prefs.integerForKey("\(data["name"].stringValue.removeWhitespace())-owned")
        if owned != 0 {
            cell.contentView.backgroundColor = owned > 0 ? SplatAppStyle.loggedIn : SplatAppStyle.loggedOut
        } else {
            cell.contentView.backgroundColor = UIColor.clearColor()
        }
        
        let expansionSettings = MGSwipeExpansionSettings()
        let ownedSwipe = MGSwipeButton(title: "Owned", backgroundColor: SplatAppStyle.loggedIn) { _ in
            tableView.beginUpdates()
            self.prefs.setInteger(1, forKey: "\(data["name"].stringValue.removeWhitespace())-owned")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            return true
        }
        let notOwnedSwipe = MGSwipeButton(title: "Not Owned", backgroundColor: SplatAppStyle.loggedOut) { _ in
            tableView.beginUpdates()
            self.prefs.setInteger(-1, forKey: "\(data["name"].stringValue.removeWhitespace())-owned")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            return true
        }
        expansionSettings.buttonIndex = 0
        expansionSettings.fillOnTrigger = false
        expansionSettings.threshold = 1.2
        cell.leftButtons = [ownedSwipe]
        cell.leftExpansion = expansionSettings
        cell.rightButtons = [notOwnedSwipe]
        cell.rightExpansion = expansionSettings
        
        for gestureRecognizer in cell.contentView.gestureRecognizers! {
            cell.contentView.removeGestureRecognizer(gestureRecognizer) }
        
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "cellLongPress:"))

        return cell
    }
    
    func cellLongPress(recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .Began else { return }
        
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        let data = gearDisplayData[indexPath!.row]
        
        tableView.beginUpdates()
        self.prefs.setInteger(0, forKey: "\(data["name"].stringValue.removeWhitespace())-owned")
        tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        gearDetailDisplaying[indexPath.row] = !gearDetailDisplaying[indexPath.row]
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if prefs.boolForKey("gearInstructionsRead") { return nil }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellInstructions")!
        cell.contentView.backgroundColor = UIColor.whiteColor()
        
        for gestureRecognizer in cell.contentView.gestureRecognizers! {
            cell.contentView.removeGestureRecognizer(gestureRecognizer) }
        
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "headerTap:"))
        
        return cell.contentView
    }
    
    func headerTap(recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .Ended else { return }
        
        tableView.beginUpdates()
        prefs.setBool(true, forKey: "gearInstructionsRead")
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if prefs.boolForKey("gearInstructionsRead") { return 0 }
        
        return 74
    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Swipe a cell left or right to mark as owned / not owned. Tap and hold to clear selection. Reset all selections from settings. Tap this message to hide it."
//    }
}

class GearGuideViewController: UIViewController, IconSelectionViewDelegate {
    @IBOutlet weak var iconView: IconSelectionView!
    @IBOutlet weak var iconViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconViewXLoc: NSLayoutConstraint!
    @IBOutlet weak var typeViewX: NSLayoutConstraint!
    
    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var imgSub: UIImageView!
    @IBOutlet weak var lblType: UILabel!
    
    var gearTable: GearTableViewController?
    
    let typeViewHeight: CGFloat = 240
    
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
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
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
    
    func toggleTypeView(show: Bool) {
        typeViewX.constant = show ? 0 : -typeViewHeight - tabBarHeight
        
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
        
        updateTable()
        toggleIconView(false)
    }
    
    func updateTable() {
        var newGear = [JSON]()
        for gear in gearData {
            var valid = true
            
            if gear["ability"].stringValue != mainAbility && mainAbility != "None" { valid = false }
            if abilityUpForBrand(gear["brand"].stringValue) != subAbility && subAbility != "None" { valid = false }
            if gear["category"].stringValue != category && category != "All" { valid = false }
            
            if valid { newGear.append(gear) }
        }
        
        gearTable?.updateDisplay(newGear)
    }
    
    @IBAction func mainButtonTapped(sender: AnyObject) {
        selectionFlag = 0
        iconView.setAbilities(abilities)
        iconView.currentSelection = -1
        iconView.lblTitle.text = "Select Main Ability"
        iconViewHeight.constant = iconView.getProperHeight() > view.frame.height * 3 / 4 ? view.frame.height * 3 / 4 : iconView.getProperHeight()
        toggleIconView(true)
    }
    
    @IBAction func subButtonTapped(sender: AnyObject) {
        selectionFlag = 1
        iconView.setAbilities(abilitiesBrands)
        iconView.currentSelection = -1
        iconView.lblTitle.text = "Select Sub Ability"
        iconViewHeight.constant = iconView.getProperHeight()
        toggleIconView(true)
    }
    
    @IBAction func typeButtonTapped(sender: AnyObject) {
        toggleTypeView(true)
    }
    
    @IBAction func shoesTapped(sender: AnyObject) {
        lblType.text = "Shoes"
        category = "Shoes"
        updateTable()
        toggleTypeView(false)
    }
    
    @IBAction func shirtTapped(sender: AnyObject) {
        lblType.text = "Shirt"
        category = "Clothing"
        updateTable()
        toggleTypeView(false)
    }
    
    @IBAction func hatTapped(sender: AnyObject) {
        lblType.text = "Hat"
        category = "Headgear"
        updateTable()
        toggleTypeView(false)
    }
    
    @IBAction func anyTapped(sender: AnyObject) {
        lblType.text = "All"
        category = "All"
        updateTable()
        toggleTypeView(false)
    }
    
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject) {
        return
    }
    
    func iconSelectionViewBrandsUpdated(view: IconSelectionView, selectedBrands: [String]) {
        return
    }
}
