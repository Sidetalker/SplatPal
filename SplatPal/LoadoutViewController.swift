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
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

class LoadoutGearViewController: GearTableViewController {
    var gearType = ""
    var loadout = Loadout()
    
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
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gearType == "Clothing" {
            loadout.clothing = Gear(data: gearDisplayData[indexPath.row])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutGearTVC") as! LoadoutGearViewController
            vc.filterGear("Shoes")
            vc.navigationItem.title = "Shoes"
            vc.loadout = loadout
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gearType == "Shoes" {
            loadout.shoes = Gear(data: gearDisplayData[indexPath.row])
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutReviewTVC") as! LoadoutReviewController
            vc.navigationItem.title = "Review"
            vc.loadout = loadout
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class LoadoutReviewController: UITableViewController {
    var loadout = Loadout()
    
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
//    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if section == 1 && loadouts.count == 0 {
//            if let headerView = view as? UITableViewHeaderFooterView {
//                headerView.textLabel?.textAlignment = .Center
//            }
//        }
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("cellPrompt", forIndexPath: indexPath)
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
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 { return 44 }
        if indexPath.section == 0 { return 255 }
        
        return 100
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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