//
//  LoadoutViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/22/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoadoutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedLoadout" {
            let destVC = segue.destinationViewController as! LoadoutTableViewController
            destVC.loadoutVC = self
        }
    }
}

class LoadoutTableViewController: UITableViewController {
    var loadoutVC: LoadoutViewController?
    var loadouts = [Loadout]()
    var editNav: UINavigationController?
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        reloadLoadouts()
    }
    
    func reloadLoadouts() {
        loadouts = loadLoadouts()
        self.tableView.reloadData()
    }
    
    func addLoadout(loadout: Loadout) {
        tableView.beginUpdates()
        
        loadouts.append(loadout)
        
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: loadouts.count - 1, inSection: 1)], withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        saveLoadouts(loadouts)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 && loadouts.count == 0 { return "No loadouts added" }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else if section == 1 { return loadouts.count }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 && loadouts.count == 0 {
            if let headerView = view as? UITableViewHeaderFooterView {
                headerView.textLabel?.textAlignment = .Center
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("cellCreateNew", forIndexPath: indexPath)
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("cellLoadout", forIndexPath: indexPath)
            let loadout = loadouts[indexPath.row]
            let headgear = cell.viewWithTag(1) as! GearView
            let clothing = cell.viewWithTag(2) as! GearView
            let shoes = cell.viewWithTag(3) as! GearView
            let name = cell.viewWithTag(4) as! UILabel
            let weapon = cell.viewWithTag(5) as! UIImageView
            let sub = cell.viewWithTag(6) as! UIImageView
            let special = cell.viewWithTag(7) as! UIImageView
            let wepBGView = cell.viewWithTag(8)!
            
            wepBGView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
            name.text = loadout.name
            headgear.updateGear(loadout.headgear)
            clothing.updateGear(loadout.clothing)
            shoes.updateGear(loadout.shoes)
            weapon.image = UIImage(named: "weapon\(loadout.weapon.name.removeWhitespace())")
            sub.image = UIImage(named: "sub\(loadout.weapon.sub.removeWhitespace())")
            special.image = UIImage(named: "special\(loadout.weapon.special.removeWhitespace())")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 1 ? 255 : 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            performSegueWithIdentifier("segueAddLoadout", sender: self)
        }
        else if indexPath.section == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutReviewTVC") as! LoadoutReviewController
            vc.navigationItem.title = "Edit"
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "saveChanges")
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete", style: .Done, target: self, action: "delete")
            vc.navigationItem.leftBarButtonItem!.tintColor = UIColor.redColor()
            vc.loadout = loadouts[indexPath.row]
            selectedIndex = indexPath.row
            
            editNav = UINavigationController(rootViewController: vc)
            
            self.presentViewController(editNav!, animated: true, completion: nil)
        }
    }
    
    func saveChanges() {
        loadouts[selectedIndex] = (editNav!.viewControllers[0] as! LoadoutReviewController).loadout
        saveLoadouts(loadouts)
        tableView.reloadData()
        editNav?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func delete() {
        loadouts.removeAtIndex(selectedIndex)
        saveLoadouts(loadouts)
        tableView.reloadData()
        editNav?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueAddLoadout" {
            let destVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! LoadoutWeaponTableViewController
            destVC.loadoutTVC = self
        }
    }
}

class LoadoutWeaponTableViewController: UITableViewController {
    var loadoutTVC: LoadoutTableViewController?
    var loadout = Loadout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelTapped")
        navigationItem.title = "Weapon"
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    func cancelTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weaponData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWeapon", forIndexPath: indexPath)
        let index = indexPath.row
        let imgWeapon = cell.viewWithTag(1) as! UIImageView
        let imgSub = cell.viewWithTag(2) as! UIImageView
        let imgSpecial = cell.viewWithTag(3) as! UIImageView
        let lblName = cell.viewWithTag(4) as! UILabel
        
        imgWeapon.image = UIImage(named: "weapon\(weaponData[index]["name"].stringValue.removeWhitespace())")
        imgSub.image = UIImage(named: "sub\(weaponData[index]["sub"].stringValue.removeWhitespace())")
        
        if weaponData[index]["special"].stringValue == "Bomb Rush" {
            imgSpecial.image = UIImage(named: "specialBombRush\(weaponData[index]["sub"].stringValue.removeWhitespace())")
        } else {
            imgSpecial.image = UIImage(named: "special\(weaponData[index]["special"].stringValue.removeWhitespace())")
        }
        
        lblName.text = weaponData[index]["name"].stringValue
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a weapon"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        loadout.weapon = Weapon(data: weaponData[indexPath.row])
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutGearTVC") as! LoadoutGearViewController
        vc.filterGear("Headgear")
        vc.navigationItem.title = "Headgear"
        vc.loadout = loadout
        vc.loadoutTVC = loadoutTVC
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class LoadoutGearViewController: GearTableViewController {
    var gearType = ""
    var loadout = Loadout()
    var loadoutTVC: LoadoutTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    func filterGear(gearType: String) {
        self.gearType = gearType
        gearDisplayData.removeAll()
        
        for gear in gearData {
            if gear["category"].stringValue == gearType { gearDisplayData.append(gear) }
        }
        
        gearDetailDisplaying = Array(count: gearDisplayData.count, repeatedValue: false)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select \(gearType)"
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if gearType == "Headgear" {
            loadout.headgear = Gear(data: gearDisplayData[indexPath.row])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutGearTVC") as! LoadoutGearViewController
            vc.filterGear("Clothing")
            vc.navigationItem.title = "Clothing"
            vc.loadout = loadout
            vc.loadoutTVC = loadoutTVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gearType == "Clothing" {
            loadout.clothing = Gear(data: gearDisplayData[indexPath.row])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutGearTVC") as! LoadoutGearViewController
            vc.filterGear("Shoes")
            vc.navigationItem.title = "Shoes"
            vc.loadout = loadout
            vc.loadoutTVC = loadoutTVC
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gearType == "Shoes" {
            loadout.shoes = Gear(data: gearDisplayData[indexPath.row])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutReviewTVC") as! LoadoutReviewController
            vc.navigationItem.title = "Review"
            vc.loadout = loadout
            vc.loadoutTVC = loadoutTVC
            
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: vc, action: "save")
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            vc.getName()
        }
    }
}

class LoadoutEditGearViewController: LoadoutGearViewController {
    var reviewController: LoadoutReviewController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if gearType == "Headgear" {
            reviewController?.loadout.headgear = Gear(data: gearDisplayData[indexPath.row])
        }
        else if gearType == "Clothing" {
            reviewController?.loadout.clothing = Gear(data: gearDisplayData[indexPath.row])
        }
        else if gearType == "Shoes" {
            reviewController?.loadout.shoes = Gear(data: gearDisplayData[indexPath.row])
        }
        
        reviewController?.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class LoadoutReviewController: UITableViewController, IconSelectionViewDelegate {
    var loadoutTVC: LoadoutTableViewController?
    var iconView = IconSelectionView()
    var loadout = Loadout()
    var loadoutIndex = -1
    var abilityLoc = (-1, -1)
    
    func save() {
        loadoutTVC?.addLoadout(loadout)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        
        iconView.delegate = self
        iconView.clipsToBounds = false
        iconView.singleSelection = true
        iconView.layer.shadowColor = UIColor.blackColor().CGColor
        iconView.layer.shadowOffset = CGSizeZero
        iconView.layer.shadowOpacity = 0.5
    }
    
    override func viewDidAppear(animated: Bool) {
        iconView.switchTypes("abilities")
        iconView.updateDisplay(false, displayTitle: false)
        iconView.frame = CGRectMake(0, navigationController!.view.frame.height,  navigationController!.view.frame.width, iconView.getProperHeight())
        iconView.collectionView.reloadData()
        navigationController!.view.addSubview(iconView)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func toggleIconView(show: Bool) {
        iconView.frame.size.height = iconView.getProperHeight()
        
        UIView.animateWithDuration(0.3, animations: {
            self.iconView.frame.origin.y = show ? self.navigationController!.view.frame.height - self.iconView.getProperHeight() : self.navigationController!.view.frame.height
            }, completion: { _ in
                if !show { self.iconView.clearSelections() }
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = .Center
            footer.textLabel?.textColor = UIColor.whiteColor()
        }
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section != 0 {
            return "TAP ABILITY TO EDIT"
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("cellPrompt", forIndexPath: indexPath)
                let lbl = cell.viewWithTag(1) as! UILabel
                
                cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
                lbl.text = "Change Name"
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("cellLoadout", forIndexPath: indexPath)
                let headgear = cell.viewWithTag(1) as! GearView
                let clothing = cell.viewWithTag(2) as! GearView
                let shoes = cell.viewWithTag(3) as! GearView
                let name = cell.viewWithTag(4) as! UILabel
                let weapon = cell.viewWithTag(5) as! UIImageView
                let sub = cell.viewWithTag(6) as! UIImageView
                let special = cell.viewWithTag(7) as! UIImageView
                let wepBGView = cell.viewWithTag(8)!
                
                wepBGView.layer.cornerRadius = 10
                cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
                name.text = loadout.name
                headgear.updateGear(loadout.headgear)
                clothing.updateGear(loadout.clothing)
                shoes.updateGear(loadout.shoes)
                weapon.image = UIImage(named: "weapon\(loadout.weapon.name.removeWhitespace())")
                sub.image = UIImage(named: "sub\(loadout.weapon.sub.removeWhitespace())")
                special.image = UIImage(named: "special\(loadout.weapon.special.removeWhitespace())")
            }
        } else {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("cellPrompt", forIndexPath: indexPath)
                let lbl = cell.viewWithTag(1) as! UILabel
                
                cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
                
                if indexPath.section == 1 {
                    lbl.text = "Change Headgear"
                }
                else if indexPath.section == 2 {
                    lbl.text = "Change Clothing"
                }
                else if indexPath.section == 3 {
                    lbl.text = "Change Shoes"
                }
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("cellAbilities", forIndexPath: indexPath)
                let ability1 = cell.viewWithTag(1) as! UIImageView
                let ability2 = cell.viewWithTag(2) as! UIImageView
                let ability3 = cell.viewWithTag(3) as! UIImageView
                
                cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
                
                if ability1.gestureRecognizers == nil {
                    ability1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "abilityTapped:"))
                }
                if ability2.gestureRecognizers == nil {
                    ability2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "abilityTapped:"))
                }
                if ability3.gestureRecognizers == nil {
                    ability3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "abilityTapped:"))
                }
                
                if indexPath.section == 1 {
                    ability1.image = UIImage(named: "ability\(loadout.headgear.ability1.removeWhitespace())")
                    ability2.image = UIImage(named: "ability\(loadout.headgear.ability2.removeWhitespace())")
                    ability3.image = UIImage(named: "ability\(loadout.headgear.ability3.removeWhitespace())")
                }
                else if indexPath.section == 2 {
                    ability1.image = UIImage(named: "ability\(loadout.clothing.ability1.removeWhitespace())")
                    ability2.image = UIImage(named: "ability\(loadout.clothing.ability2.removeWhitespace())")
                    ability3.image = UIImage(named: "ability\(loadout.clothing.ability3.removeWhitespace())")
                }
                else if indexPath.section == 3 {
                    ability1.image = UIImage(named: "ability\(loadout.shoes.ability1.removeWhitespace())")
                    ability2.image = UIImage(named: "ability\(loadout.shoes.ability2.removeWhitespace())")
                    ability3.image = UIImage(named: "ability\(loadout.shoes.ability3.removeWhitespace())")
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 { return 44 }
        if indexPath.section == 0 { return 255 }
        
        return 80
    }
    
    func getName() {
        let getNameAlert = UIAlertController(title: "Name your loadout", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        getNameAlert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Loadout Name"
            textField.text = self.loadout.name
        }
        getNameAlert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { _ in
            if getNameAlert.textFields![0].text != "" {
                self.loadout.name = getNameAlert.textFields![0].text!
                self.tableView.reloadData()
            } else {
                let tryAgainAlert = UIAlertController(title: "I pity the fool", message: "Your loadout must have a name!", preferredStyle: .Alert)
                tryAgainAlert.addAction(UIAlertAction(title: "Oh, OK!", style: .Default, handler: { _ in
                    self.getName()
                }))
                
                self.presentViewController(tryAgainAlert, animated: true, completion: nil)
            }
        }))
        
        self.presentViewController(getNameAlert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            if indexPath.section == 0 {
                getName()
            }
            else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutEditGearTVC") as! LoadoutEditGearViewController
                vc.loadout = loadout
                vc.reviewController = self
                
                if indexPath.section == 1 {
                    vc.filterGear("Headgear")
                }
                else if indexPath.section == 2 {
                    vc.filterGear("Clothing")
                }
                else if indexPath.section == 3 {
                    vc.filterGear("Shoes")
                }
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    func abilityTapped(recognizer: UITapGestureRecognizer) {
        let tag = (recognizer.view as! UIImageView).tag - 1
        let section = tableView.indexPathForRowAtPoint(recognizer.locationInView(tableView))!.section - 1
        
        abilityLoc = (section, tag)
        
        toggleIconView(true)
        
        log.debug("Get it")
    }
    
    func iconSelectionViewAbilitiesUpdated(view: IconSelectionView, selectedAbilities: [String]) {
        let ability = selectedAbilities[0]
        
        if abilityLoc.0 == 0 {
            if abilityLoc.1 == 0 {
                loadout.headgear.ability1 = ability
            }
            else if abilityLoc.1 == 1 {
                loadout.headgear.ability2 = ability
            }
            else if abilityLoc.1 == 2 {
                loadout.headgear.ability3 = ability
            }
        }
        else if abilityLoc.0 == 1 {
            if abilityLoc.1 == 0 {
                loadout.clothing.ability1 = ability
            }
            else if abilityLoc.1 == 1 {
                loadout.clothing.ability2 = ability
            }
            else if abilityLoc.1 == 2 {
                loadout.clothing.ability3 = ability
            }
        }
        else if abilityLoc.0 == 2 {
            if abilityLoc.1 == 0 {
                loadout.shoes.ability1 = ability
            }
            else if abilityLoc.1 == 1 {
                loadout.shoes.ability2 = ability
            }
            else if abilityLoc.1 == 2 {
                loadout.shoes.ability3 = ability
            }
        }
        
        tableView.reloadData()
        
        toggleIconView(false)
    }
    
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject) {
        return
    }
    
    func iconSelectionViewBrandsUpdated(view: IconSelectionView, selectedBrands: [String]) {
        return
    }
}

class Loadout {
    var name = ""
    var weapon = Weapon()
    var headgear = Gear()
    var clothing = Gear()
    var shoes = Gear()
    
    init() { }
    
    init(data: JSON) {
        name = data["name"].stringValue
        weapon = Weapon(data: data["weapon"])
        headgear = Gear(data: data["headgear"])
        clothing = Gear(data: data["clothing"])
        shoes = Gear(data: data["shoes"])
    }
    
    func jsonRepresentation() -> JSON {
        var rep = JSON([:])
        
        rep["name"] = JSON(name)
        rep["weapon"] = weapon.jsonRepresentation()
        rep["headgear"] = headgear.jsonRepresentation()
        rep["clothing"] = clothing.jsonRepresentation()
        rep["shoes"] = shoes.jsonRepresentation()
        
        return rep
    }
}

class Gear {
    var name = ""
    var abilityPrimary = ""
    var ability1 = ""
    var ability2 = ""
    var ability3 = ""
    
    init() { }
    
    init(data: JSON) {
        name = data["name"].stringValue
        abilityPrimary = data["abilityPrimary"].stringValue
        ability1 = data["ability1"].stringValue
        ability2 = data["ability2"].stringValue
        ability3 = data["ability3"].stringValue
        
        let sub = defaultSub()
        
        if abilityPrimary == "" { abilityPrimary = defaultPrimary() }
        if ability1 == "" { ability1 = sub }
        if ability2 == "" { ability2 = sub }
        if ability3 == "" { ability3 = sub }
    }
    
    func jsonRepresentation() -> JSON {
        var rep = JSON([:])
        
        rep["name"] = JSON(name)
        rep["abilityPrimary"] = JSON(abilityPrimary)
        rep["ability1"] = JSON(ability1)
        rep["ability2"] = JSON(ability2)
        rep["ability3"] = JSON(ability3)
        
        return rep
    }
    
    func defaultPrimary() -> String {
        for gear in gearData {
            if gear["name"].stringValue == name {
                return gear["ability"].stringValue
            }
        }
        
        return ""
    }
    
    func defaultSub() -> String {
        for gear in gearData {
            if gear["name"].stringValue == name {
                return abilityUpForBrand(gear["brand"].stringValue)
            }
        }
        
        return ""
    }
}

class Weapon {
    var name = ""
    var sub = ""
    var special = ""
    
    init() { }
    
    init(data: JSON) {
        name = data["name"].stringValue
        sub = data["sub"].stringValue
        special = data["special"].stringValue
        
        if special == "Bomb Rush" {
            special = "\(special) \(sub)"
        }
    }
    
    func jsonRepresentation() -> JSON {
        var rep = JSON([:])
        
        rep["name"] = JSON(name)
        rep["sub"] = JSON(sub)
        rep["special"] = JSON(special)
        
        return rep
    }
}