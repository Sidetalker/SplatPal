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

let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

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
    var gearDisplayData = [[Gear]]()
    var gearDetailDisplaying = [[Bool]]()
    var alphaSectionHeaders = [String]()

    let prefs = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if gearDisplayData.count == 0 { updateDisplay(gearData) }
    }
    
    func updateDisplay(newData: [Gear]) {
        gearDisplayData.removeAll()
        gearDetailDisplaying.removeAll()
        alphaSectionHeaders.removeAll()
        
        var currentLetter: Character = "?"
        
        for gear in newData {
            if gear.name[0] == currentLetter {
                gearDisplayData[gearDisplayData.count - 1].append(gear)
                gearDetailDisplaying[gearDetailDisplaying.count - 1].append(false)
            } else {
                currentLetter = gear.name[0]
                gearDisplayData.append([gear])
                gearDetailDisplaying.append([false])
                alphaSectionHeaders.append(String(currentLetter))
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return gearDisplayData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gearDisplayData[section].count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return gearDetailDisplaying[indexPath.section][indexPath.row] ? 195 : 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let gear = gearDisplayData[indexPath.section][indexPath.row]
        
        if gearDetailDisplaying[indexPath.section][indexPath.row] {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellGearDetail", forIndexPath: indexPath) as! GearDetailCell
            cell.configureForGear(gear)
            cell.addSwipeButtonsForGear(gear, gearDisplayData: gearDisplayData, tableView: tableView, indexPath: indexPath)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellGear", forIndexPath: indexPath) as! GearCell
            cell.configureForGear(gear)
            cell.addSwipeButtonsForGear(gear, gearDisplayData: gearDisplayData, tableView: tableView, indexPath: indexPath)
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return alphaSectionHeaders[section]
    }
    
    func cellLongPress(recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .Began else { return }
        
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        let gear = gearDisplayData[indexPath!.section][indexPath!.row]
        
        tableView.beginUpdates()
        self.prefs.setInteger(0, forKey: "\(gear.shortName)-owned")
        tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return alphaSectionHeaders
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        gearDetailDisplaying[indexPath.section][indexPath.row] = !gearDetailDisplaying[indexPath.section][indexPath.row]
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if prefs.boolForKey("gearInstructionsRead") || section != 0 { return nil }
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cellInstructions") else { return nil }
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
        guard let _ = tableView.dequeueReusableCellWithIdentifier("cellInstructions") else { return 22 }
        if section == 0 && !prefs.boolForKey("gearInstructionsRead") { return 74 }
        
        return 22
    }
}

class GearGuideViewController: UIViewController, UIGestureRecognizerDelegate, IconSelectionViewDelegate {
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
    var typeViewDisplaying = false
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
            let tapGesture = UITapGestureRecognizer(target: self, action: "dismissTypeView")
            tapGesture.delegate = self
            
            gearTable = segue.destinationViewController as? GearTableViewController
            gearTable?.tableView.addGestureRecognizer(tapGesture)
            gearTable?.updateDisplay(gearData)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return typeViewDisplaying
    }
    
    func dismissTypeView() {
        if typeViewDisplaying { toggleTypeView(false) }
    }
    
    func toggleIconView(show: Bool) {
        iconViewXLoc.constant = show ? 0 : -iconViewHeight.constant - tabBarHeight
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func toggleTypeView(show: Bool) {
        typeViewX.constant = show ? 0 : -typeViewHeight - tabBarHeight
        typeViewDisplaying = show
        
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
        var newGear = [Gear]()
        for gear in gearData {
            var valid = true
            
            if gear.ability != mainAbility && mainAbility != "None" { valid = false }
            if gear.abilitySub != subAbility && subAbility != "None" { valid = false }
            if gear.category != category && category != "All" { valid = false }
            if !gear.isStarred() && category == "Starred" { valid = false }
            else if gear.isStarred() && category == "Starred" { valid = true }
            
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
    
    @IBAction func starredTapped(sender: AnyObject) {
        lblType.text = "Starred"
        category = "Starred"
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
