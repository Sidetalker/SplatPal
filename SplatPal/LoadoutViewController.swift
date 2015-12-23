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
        reloadLoadouts()
    }
    
    func reloadLoadouts() {
        loadouts = loadLoadouts()
//        let myLoad = Loadout()
//        let wep = Weapon()
//        let headgear = Gear()
//        let clothing = Gear()
//        let shoes = Gear()
//        
//        wep.name = "Tri-Slosher"
//        wep.sub = "Disruptor"
//        wep.special = "Bubbler"
//        headgear.name = "Sun Visor"
//        headgear.abilityPrimary = "Bomb Range Up"
//        headgear.ability1 = "Ink Saver (Main)"
//        headgear.ability2 = "Swim Speed Up"
//        headgear.ability3 = "Swim Speed Up"
//        clothing.name = "Slipstream United"
//        clothing.abilityPrimary = "Defence Up"
//        clothing.ability1 = "Quick Super Jump"
//        clothing.ability2 = "Swim Speed Up"
//        clothing.ability3 = "Swim Speed Up"
//        shoes.name = "Roasted Brogues"
//        shoes.abilityPrimary = "Defence Up"
//        shoes.ability1 = "Defence Up"
//        shoes.ability2 = "Defence Up"
//        shoes.ability3 = "Defence Up"
//        
//        myLoad.name = "Mah Loadout"
//        myLoad.weapon = wep
//        myLoad.headgear = headgear
//        myLoad.clothing = clothing
//        myLoad.shoes = shoes
//        
//        loadouts.append(myLoad)
        
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
        if indexPath.section == 0 {
            return tableView.dequeueReusableCellWithIdentifier("cellCreateNew", forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellLoadout", forIndexPath: indexPath)
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
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 1 ? 255 : 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "segueNewNotification" {
//            let destVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! ModeSettingsTableViewController
//            destVC.notificationTableVC = self
//        }
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
    }
    
    func jsonRepresentation() -> JSON {
        var rep = JSON([:])
        
        rep["name"] = JSON(name)
        rep["sub"] = JSON(sub)
        rep["special"] = JSON(special)
        
        return rep
    }
}