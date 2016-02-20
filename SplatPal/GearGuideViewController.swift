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
        
        updateDisplay(gearData)
    }
    
    func updateDisplay(newData: [Gear]) {
        gearDisplayData.removeAll()
        gearDetailDisplaying.removeAll()
        alphaSectionHeaders.removeAll()
        
        var currentLetter = 0
        var firstOfLetter = true
        var searchingNumbers = true
        
        for gear in newData {
            if currentLetter == alphabet.characters.count { break }
            
            if searchingNumbers {
                if Int(String(gear.name[0])) != nil {
                    if firstOfLetter {
                        firstOfLetter = false
                        alphaSectionHeaders.append("#")
                        gearDisplayData.append([gear])
                        gearDetailDisplaying.append([false])
                    } else {
                        gearDisplayData[gearDisplayData.count - 1].append(gear)
                        gearDetailDisplaying[gearDetailDisplaying.count - 1].append(false)
                    }
                } else {
                    firstOfLetter = false
                    searchingNumbers = false
                    alphaSectionHeaders.append(String(alphabet[currentLetter]))
                    gearDisplayData.append([gear])
                    gearDetailDisplaying.append([false])
                }
            } else {
                if gear.name[0] == alphabet[currentLetter] {
                    if firstOfLetter {
                        firstOfLetter = false
                        alphaSectionHeaders.append(String(alphabet[currentLetter]))
                        gearDisplayData.append([gear])
                        gearDetailDisplaying.append([false])
                    } else {
                        gearDisplayData[gearDisplayData.count - 1].append(gear)
                        gearDetailDisplaying[gearDetailDisplaying.count - 1].append(false)
                    }
                } else {
                    firstOfLetter = false
                    currentLetter += 1
                    alphaSectionHeaders.append(String(alphabet[currentLetter]))
                    gearDisplayData.append([gear])
                    gearDetailDisplaying.append([false])
                }
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
            cell.configureWithGear(gear)
            cell.addSwipeButtonsForGear(gear, gearDisplayData: gearDisplayData, tableView: tableView, indexPath: indexPath)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellGear", forIndexPath: indexPath) as! GearCell
            cell.configureWithGear(gear)
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
        if section != 0 { return nil }
        
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
        if section == 0 && !prefs.boolForKey("gearInstructionsRead") { return 74 }
        
        return 22
    }
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
        var newGear = [Gear]()
        for gear in gearData {
            var valid = true
            
            if gear.ability != mainAbility && mainAbility != "None" { valid = false }
            if gear.abilitySub != subAbility && subAbility != "None" { valid = false }
            if gear.category != category && category != "All" { valid = false }
            
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
