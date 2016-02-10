//
//  LoadoutViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/22/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kanna

class LoadoutViewController: UIViewController {
    var importName: String?
    var importData: String?
    var loadoutTVC: LoadoutTableViewController?
    
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
            loadoutTVC = destVC
            destVC.loadoutVC = self
            
            if
                let name = importName,
                let data = importData
            {
                destVC.importName = name
                destVC.importData = data
            }
        }
    }
    
    func importLoadout(name: String, data: String) {
        importName = name
        importData = data
    }
}

class LoadoutTableViewController: UITableViewController {
    var loadoutVC: LoadoutViewController?
    var loadouts = [Loadout]()
    var editNav: UINavigationController?
    var selectedIndex = -1
    var importName: String?
    var importData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        reloadLoadouts()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if
            let name = importName,
            let data = importData
        {
            importLoadout(name, data: data)
            importName = nil
            importData = nil
        }
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
            
            if indexPath.row == 1 { (cell.viewWithTag(1) as! UILabel).text = "Import Current Loadout" }
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
//            let img = UIImage(named: "weaponCustomE-liter3KScope.png")
            
//            let colorSpace = CGColorSpaceCreateDeviceRGB()
//            var rgba: Array<char16_t> = Array(count: 4, repeatedValue: "x")
//            let context = CGBitmapContextCreateWithData(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big)
//            kcg
//            
        }
        else if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
            
            
                let splatoonProfileURL = "https://splatoon.nintendo.net/profile"
                
                request(.GET, splatoonProfileURL, encoding: .URL, headers: ["locale" : "en"])
                    .responseString { response in
                        if response.result.isFailure {
                            log.error("Error Loading Schedule: \(response.result.error)")
                        }
                        else if let doc = Kanna.HTML(html: response.result.value!, encoding: NSUTF8StringEncoding) {
                            log.debug("Loaded HTML: \(doc.title!)")
                            
                            if
                                let weaponStyle = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[1]/div[2]/div/@style").text,
                                let weaponMatch = weaponStyle.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                
                                let headStyle = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[1]/div[1]/@style").text,
                                let headMatch = headStyle.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let headAbility1Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[1]/ul/li[1]/div/@style").text,
                                let headAbility1Match = headAbility1Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let headAbility2Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[1]/ul/li[2]/div/@style").text,
                                let headAbility2Match = headAbility2Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let headAbility3Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[1]/ul/li[3]/div/@style").text,
                                let headAbility3Match = headAbility3Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                
                                let clothingStyle = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[2]/div[1]/@style").text,
                                let clothingMatch = headStyle.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let clothingAbility1Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[2]/ul/li[1]/div/@style").text,
                                let clothingAbility1Match = clothingAbility1Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let clothingAbility2Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[2]/ul/li[2]/div/@style").text,
                                let clothingAbility2Match = clothingAbility2Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let clothingAbility3Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[2]/ul/li[3]/div/@style").text,
                                let clothingAbility3Match = clothingAbility3Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                
                                let shoesStyle = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[3]/div[1]/@style").text,
                                let shoesMatch = headStyle.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let shoesAbility1Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[3]/ul/li[1]/div/@style").text,
                                let shoesAbility1Match = shoesAbility1Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let shoesAbility2Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[3]/ul/li[2]/div/@style").text,
                                let shoesAbility2Match = shoesAbility2Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch),
                                let shoesAbility3Style = doc.xpath("/html/body/div[2]/div[2]/div[2]/div[1]/div[2]/div[3]/ul/li[3]/div/@style").text,
                                let shoesAbility3Match = shoesAbility3Style.rangeOfString("(?<=')[^']+", options: .RegularExpressionSearch)
                            {
                                let prepend = "https://splatoon.nintendo.net"
                                
                                let weaponURL = "\(prepend)\(weaponStyle.substringWithRange(weaponMatch))"
                                
                                let headURL = "\(prepend)\(headStyle.substringWithRange(headMatch))"
                                let headAbility1URL = "\(prepend)\(headAbility1Style.substringWithRange(headAbility1Match))"
                                let headAbility2URL = "\(prepend)\(headAbility2Style.substringWithRange(headAbility2Match))"
                                let headAbility3URL = "\(prepend)\(headAbility3Style.substringWithRange(headAbility3Match))"
                                
                                let clothingURL = "\(prepend)\(clothingStyle.substringWithRange(clothingMatch))"
                                let clothingAbility1URL = "\(prepend)\(clothingAbility1Style.substringWithRange(clothingAbility1Match))"
                                let clothingAbility2URL = "\(prepend)\(clothingAbility2Style.substringWithRange(clothingAbility2Match))"
                                let clothingAbility3URL = "\(prepend)\(clothingAbility3Style.substringWithRange(clothingAbility3Match))"
                                
                                let shoesURL = "\(prepend)\(shoesStyle.substringWithRange(shoesMatch))"
                                let shoesAbility1URL = "\(prepend)\(shoesAbility1Style.substringWithRange(shoesAbility1Match))"
                                let shoesAbility2URL = "\(prepend)\(shoesAbility2Style.substringWithRange(shoesAbility2Match))"
                                let shoesAbility3URL = "\(prepend)\(shoesAbility3Style.substringWithRange(shoesAbility3Match))"
                                
                                log.debug("weaponURL: \(weaponURL)")
                                
                                log.debug("headURL: \(headURL)")
                                log.debug("headAbility1URL: \(headAbility1URL)")
                                log.debug("headAbility2URL: \(headAbility2URL)")
                                log.debug("headAbility3URL: \(headAbility3URL)")
                                
                                log.debug("clothingURL: \(clothingURL)")
                                log.debug("clothingAbility1URL: \(clothingAbility1URL)")
                                log.debug("clothingAbility2URL: \(clothingAbility2URL)")
                                log.debug("clothingAbility3URL: \(clothingAbility3URL)")
                                
                                log.debug("shoesURL: \(shoesURL)")
                                log.debug("shoesAbility1URL: \(shoesAbility1URL)")
                                log.debug("shoesAbility2URL: \(shoesAbility2URL)")
                                log.debug("shoesAbility3URL: \(shoesAbility3URL)")
                            }
                            
//                            profile.username = doc.xpath("//h2[@class=\"profile-username\"]").text
                            
                        }
                }
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
    
    func importLoadout(name: String, data: String) {
        editNav?.dismissViewControllerAnimated(true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutReviewTVC") as! LoadoutReviewController
        vc.navigationItem.title = "Import"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "saveImport")
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelImport")
        vc.loadout = Loadout(name: name, encoding: data)
        
        editNav = UINavigationController(rootViewController: vc)
        
        self.presentViewController(editNav!, animated: true, completion: nil)
    }
    
    func saveImport() {
        loadouts.append((editNav!.viewControllers[0] as! LoadoutReviewController).loadout)
        saveLoadouts(loadouts)
        tableView.reloadData()
        editNav?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelImport() {
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

class LoadoutEditWeaponViewController: LoadoutWeaponTableViewController {
    var reviewController: LoadoutReviewController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        loadout.weapon = Weapon(data: weaponData[indexPath.row])
        
        reviewController?.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tap any item to edit"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textAlignment = .Center
            header.textLabel?.textColor = UIColor.whiteColor()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("cellLoadout", forIndexPath: indexPath)
            let name = cell.viewWithTag(4) as! UILabel
            let weapon = cell.viewWithTag(5) as! UIImageView
            let sub = cell.viewWithTag(6) as! UIImageView
            let special = cell.viewWithTag(7) as! UIImageView
            let wepBGView = cell.viewWithTag(8)!
            
            wepBGView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
            name.text = loadout.name
            weapon.image = UIImage(named: "weapon\(loadout.weapon.name.removeWhitespace())")
            sub.image = UIImage(named: "sub\(loadout.weapon.sub.removeWhitespace())")
            special.image = UIImage(named: "special\(loadout.weapon.special.removeWhitespace())")
            
            if name.gestureRecognizers == nil {
                name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "getName"))
            }
            if weapon.gestureRecognizers == nil {
                weapon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "weaponTapped:"))
            }
        }
        else if indexPath.row == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier("cellPrompt", forIndexPath: indexPath)
            let lbl = cell.viewWithTag(1) as! UILabel
            
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
            lbl.text = "Share Loadout"
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("cellAbilities", forIndexPath: indexPath)
            let ability1 = cell.viewWithTag(1) as! UIImageView
            let ability2 = cell.viewWithTag(2) as! UIImageView
            let ability3 = cell.viewWithTag(3) as! UIImageView
            let clothing = cell.viewWithTag(4) as! UIImageView
            let clothingBGView = cell.viewWithTag(5)!
            
            clothingBGView.layer.cornerRadius = 10
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
            if clothing.gestureRecognizers == nil {
                clothing.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clothingTapped:"))
            }
            
            if indexPath.row == 1 {
                ability1.image = UIImage(named: "ability\(loadout.headgear.ability1.removeWhitespace())")
                ability2.image = UIImage(named: "ability\(loadout.headgear.ability2.removeWhitespace())")
                ability3.image = UIImage(named: "ability\(loadout.headgear.ability3.removeWhitespace())")
                clothing.image = UIImage(named: "gear\(loadout.headgear.name.removeWhitespace())")
            }
            else if indexPath.row == 2 {
                ability1.image = UIImage(named: "ability\(loadout.clothing.ability1.removeWhitespace())")
                ability2.image = UIImage(named: "ability\(loadout.clothing.ability2.removeWhitespace())")
                ability3.image = UIImage(named: "ability\(loadout.clothing.ability3.removeWhitespace())")
                clothing.image = UIImage(named: "gear\(loadout.clothing.name.removeWhitespace())")
            }
            else if indexPath.row == 3 {
                ability1.image = UIImage(named: "ability\(loadout.shoes.ability1.removeWhitespace())")
                ability2.image = UIImage(named: "ability\(loadout.shoes.ability2.removeWhitespace())")
                ability3.image = UIImage(named: "ability\(loadout.shoes.ability3.removeWhitespace())")
                clothing.image = UIImage(named: "gear\(loadout.shoes.name.removeWhitespace())")
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let loadoutURL = loadout.encoded()
        
        log.debug("URL: \(loadoutURL)")
        
        let shareSheet = UIActivityViewController(activityItems: [loadoutURL], applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = tableView.cellForRowAtIndexPath(indexPath)
        shareSheet.popoverPresentationController?.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
        
        self.presentViewController(shareSheet, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 { return 96 }
        
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
    
    func abilityTapped(recognizer: UITapGestureRecognizer) {
        let tag = (recognizer.view as! UIImageView).tag - 1
        let row = tableView.indexPathForRowAtPoint(recognizer.locationInView(tableView))!.row - 1
        
        abilityLoc = (row, tag)
        
        toggleIconView(true)
    }
    
    func weaponTapped(recognizer: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutEditWeaponTVC") as! LoadoutEditWeaponViewController
        vc.loadout = loadout
        vc.reviewController = self
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func clothingTapped(recognizer: UITapGestureRecognizer) {
        let row = tableView.indexPathForRowAtPoint(recognizer.locationInView(tableView))!.row
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("loadoutEditGearTVC") as! LoadoutEditGearViewController
        vc.loadout = loadout
        vc.reviewController = self
        
        if row == 1 {
            vc.filterGear("Headgear")
        }
        else if row == 2 {
            vc.filterGear("Clothing")
        }
        else if row == 3 {
            vc.filterGear("Shoes")
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
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

func isValidLoadout(data: String) -> Bool {
    let base62String = "dQruMA8nHkLVNa3ioEOsRtC6J9TfSlYXZzbm4cyUpg7jFhGD2PIv5WqB1Kwxe0"
    
    var base62Encoding = data
    var base10Encoding = ""
    
    while base62Encoding.length > 0 {
        base10Encoding.appendContentsOf("\(base62String.indexOf(base62Encoding[0...1]))")
        base62Encoding.removeAtIndex(base62Encoding.startIndex)
    }
    
    if base10Encoding.length != 29 { return false }
    if Int(base10Encoding[0...2])! >= weaponData.count { return false }
    
    for var x = 2; x <= 20; x += 9 {
        if Int(base10Encoding[x...x + 3])! >= gearData.count { return false }
        
        for var y = x + 3; y < x + 9; y += 2 {
            if Int(base10Encoding[y...y + 2])! >= abilityDataEnum.count { return false }
        }
    }
    
    return true
}

class Loadout {
    var name = ""
    var weapon = Weapon()
    var headgear = Gear()
    var clothing = Gear()
    var shoes = Gear()
    
    // Randomized base62 string cause I'm a jerk
    let base62String = "dQruMA8nHkLVNa3ioEOsRtC6J9TfSlYXZzbm4cyUpg7jFhGD2PIv5WqB1Kwxe0"
    
    init() { }
    
    init(data: JSON) {
        name = data["name"].stringValue
        weapon = Weapon(data: data["weapon"])
        headgear = Gear(data: data["headgear"])
        clothing = Gear(data: data["clothing"])
        shoes = Gear(data: data["shoes"])
    }
    
    init(name: String, encoding: String) {
        var base62Encoding = encoding
        var base10Encoding = ""
        
        while base62Encoding.length > 0 {
            base10Encoding.appendContentsOf("\(base62String.indexOf(base62Encoding[0...1]))")
            base62Encoding.removeAtIndex(base62Encoding.startIndex)
        }
        
        self.name = name
        weapon = Weapon(encoding: base10Encoding[0...2])
        headgear = Gear(encoding: base10Encoding[2...11])
        clothing = Gear(encoding: base10Encoding[11...20])
        shoes = Gear(encoding: base10Encoding[20...29])
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
    
    func encoded() -> String {
        var base10Encoding = "\(weapon.index())\(headgear.index())\(clothing.index())\(shoes.index())"
        var base62Encoding = ""
        
        while base10Encoding.length > 0 {
            if base10Encoding.length > 1 && Int(base10Encoding[0...2])! < 62 && Int(base10Encoding[0...2])! > 9 {
                base62Encoding.append(base62String[Int(base10Encoding[0...2])!])
                base10Encoding.removeRange(Range<String.Index>(start: base10Encoding.startIndex, end: base10Encoding.startIndex.advancedBy(2)))
            } else {
                base62Encoding.append(base62String[Int("\(base10Encoding[0])")!])
                base10Encoding.removeAtIndex(base10Encoding.startIndex)
            }
        }
        
        return "SplatPal://?name=\(name.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)&data=\(base62Encoding)"
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
    
    init(encoding: String) {
        let gear = gearData[Int(encoding[0...3])!]
        
        name = gear["name"].stringValue
        abilityPrimary = gear["ability"].stringValue
        ability1 = abilityDataEnum[Int(encoding[3...5])!]
        ability2 = abilityDataEnum[Int(encoding[5...7])!]
        ability3 = abilityDataEnum[Int(encoding[7...9])!]
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
    
    func nameIndex() -> String {
        for (x, item) in gearData.enumerate() {
            if item["name"].stringValue == name { return String(format: "%03d", x) }
        }
        
        return "???"
    }
    
    func abilityIndex(abilityNum: Int) -> String {
        var abilityName = ""
        
        if abilityNum == 1 { abilityName = ability1 }
        else if abilityNum == 2 { abilityName = ability2 }
        else if abilityNum == 3 { abilityName = ability3 }
        
        for (x, item) in abilityDataEnum.enumerate() {
            if item == abilityName { return String(format: "%02d", x) }
        }
        
        return "??"
    }
    
    func index() -> String {
        return "\(nameIndex())\(abilityIndex(1))\(abilityIndex(2))\(abilityIndex(3))"
    }
}

class Weapon {
    var name = ""
    var sub = ""
    var special = ""
    
    init() { }
    
    init(data: JSON) {
        loadData(data)
    }
    
    init(encoding: String) {
        loadData(weaponData[Int(encoding)!])
    }
    
    func loadData(data: JSON) {
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
    
    func index() -> String {
        for (x, item) in weaponData.enumerate() {
            if item["name"].stringValue == name { return String(format: "%02d", x) }
        }
        
        return "???"
    }
}