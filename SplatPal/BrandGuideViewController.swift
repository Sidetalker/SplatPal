//
//  BrandGuideViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import SwiftyJSON

let tabBarHeight: CGFloat = 49

//let brandData = JSON([
//    "amiibo" : ["name" : "amiibo", "abilityUp" : "None", "abilityDown" : "None"],
//    "Cuttlegear" : ["name" : "Cuttlegear", "abilityUp" : "None", "abilityDown" : "None"],
//    "Famitsu" : ["name" : "Famitsu", "abilityUp" : "None", "abilityDown" : "None"],
//    "Firefin" : ["name" : "Firefin", "abilityUp" : "Ink Saver (Sub)", "abilityDown" : "Ink Recovery Up"],
//    "Forge" : ["name" : "Forge", "abilityUp" : "Special Duration Up", "abilityDown" : "Ink Saver (Sub)"],
//    "Inkline" : ["name" : "Inkline", "abilityUp" : "Defence Up", "abilityDown" : "Damage Up"],
//    "KOG" : ["name" : "KOG", "abilityUp" : "None", "abilityDown" : "None"],
//    "Krak-On" : ["name" : "Krak-On", "abilityUp" : "Swim Speed Up", "abilityDown" : "Defence Up"],
//    "Rockenberg" : ["name" : "Rockenberg", "abilityUp" : "Run Speed Up", "abilityDown" : "Swim Speed Up"],
//    "Skalop" : ["name" : "Skalop", "abilityUp" : "Quick Respawn", "abilityDown" : "Special Saver"],
//    "Splash Mob" : ["name" : "Splash Mob", "abilityUp" : "Ink Saver (Main)", "abilityDown" : "Run Speed Up"],
//    "SquidForce" : ["name" : "SquidForce", "abilityUp" : "Damage Up", "abilityDown" : "Ink Saver (Main)"],
//    "Takoroka" : ["name" : "Takoroka", "abilityUp" : "Special Charge Up", "abilityDown" : "Special Duration Up"],
//    "Tentatek" : ["name" : "Tentatek", "abilityUp" : "Ink Recovery Up", "abilityDown" : "Quick Super Jump"],
//    "The SQUID GIRL" : ["name" : "The SQUID GIRL", "abilityUp" : "None", "abilityDown" : "None"],
//    "Zekko" : ["name" : "Zekko", "abilityUp" : "Special Saver", "abilityDown" : "Special Charge Up"],
//    "Zink" : ["name" : "Zink", "abilityUp" : "Quick Super Jump", "abilityDown" : "Quick Respawn"]
//])

let brandData = JSON([
    ["brand" : "amiibo", "abilityUp" : "None", "abilityDown" : "None"],
    ["brand" : "Cuttlegear", "abilityUp" : "None", "abilityDown" : "None"],
    ["brand" : "Famitsu", "abilityUp" : "None", "abilityDown" : "None"],
    ["brand" : "Firefin", "abilityUp" : "Ink Saver (Sub)", "abilityDown" : "Ink Recovery Up"],
    ["brand" : "Forge", "abilityUp" : "Special Duration Up", "abilityDown" : "Ink Saver (Sub)"],
    ["brand" : "Inkline", "abilityUp" : "Defence Up", "abilityDown" : "Damage Up"],
    ["brand" : "KOG", "abilityUp" : "None", "abilityDown" : "None"],
    ["brand" : "Krak-On", "abilityUp" : "Swim Speed Up", "abilityDown" : "Defence Up"],
    ["brand" : "Rockenberg", "abilityUp" : "Run Speed Up", "abilityDown" : "Swim Speed Up"],
    ["brand" : "Skalop", "abilityUp" : "Quick Respawn", "abilityDown" : "Special Saver"],
    ["brand" : "Splash Mob", "abilityUp" : "Ink Saver (Main)", "abilityDown" : "Run Speed Up"],
    ["brand" : "SquidForce", "abilityUp" : "Damage Up", "abilityDown" : "Ink Saver (Main)"],
    ["brand" : "Takoroka", "abilityUp" : "Special Charge Up", "abilityDown" : "Special Duration Up"],
    ["brand" : "Tentatek", "abilityUp" : "Ink Recovery Up", "abilityDown" : "Quick Super Jump"],
    ["brand" : "The SQUID GIRL", "abilityUp" : "None", "abilityDown" : "None"],
    ["brand" : "Zekko", "abilityUp" : "Special Saver", "abilityDown" : "Special Charge Up"],
    ["brand" : "Zink", "abilityUp" : "Quick Super Jump", "abilityDown" : "Quick Respawn"],
])

class BrandView: UIView {
    var brandName = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        switch brandName {
        case "amiibo":
            SplatAppStyle.drawBrandAmiibo(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Cuttlegear":
            SplatAppStyle.drawBrandCuttlegear(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Famitsu":
            SplatAppStyle.drawBrandFamitsu(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Firefin":
            SplatAppStyle.drawBrandFirefin(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Forge":
            SplatAppStyle.drawBrandForge(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Inkline":
            SplatAppStyle.drawBrandInkline(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "KOG":
            SplatAppStyle.drawBrandKOG(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Krak-On":
            SplatAppStyle.drawBrandKrakOn(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Rockenberg":
            SplatAppStyle.drawBrandRockenberg(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Skalop":
            SplatAppStyle.drawBrandSkalop(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Splash Mob":
            SplatAppStyle.drawBrandSplashMob(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "SquidForce":
            SplatAppStyle.drawBrandSquidForce(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Takoroka":
            SplatAppStyle.drawBrandTakoroka(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Tentatek":
            SplatAppStyle.drawBrandTentatek(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "The SQUID GIRL":
            SplatAppStyle.drawBrandTheSQUIDGIRL(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Zekko":
            SplatAppStyle.drawBrandZekko(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        case "Zink":
            SplatAppStyle.drawBrandZink(frame: rect, brandFill: UIColor.clearColor(), shadow: SplatAppStyle.shadowSelected)
        default:
            super.drawRect(rect)
        }
    }
}

class BrandTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 17
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellBrand", forIndexPath: indexPath)
        let brandIcon = cell.viewWithTag(1) as! BrandView
        let abilityUpImage = cell.viewWithTag(2) as! UIImageView
        let abilityDownImage = cell.viewWithTag(3) as! UIImageView
        
        brandIcon.brandName = brandData[indexPath.row]["brand"].stringValue
        brandIcon.setNeedsDisplay()
        abilityUpImage.image = UIImage(named: "ability\(brandData[indexPath.row]["abilityUp"].stringValue.removeWhitespace()).png")
        abilityDownImage.image = UIImage(named: "ability\(brandData[indexPath.row]["abilityDown"].stringValue.removeWhitespace()).png")
        
        return cell
    }
}

class BrandGuideViewController: UIViewController, IconSelectionViewDelegate {
    @IBOutlet weak var iconView: IconSelectionView!
    @IBOutlet weak var iconViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconViewXLoc: NSLayoutConstraint!
    
    var iconViewFullHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        iconView.viewType = "brands"
        iconView.delegate = self
        iconView.clipsToBounds = false
        iconView.layer.shadowColor = UIColor.blackColor().CGColor
        iconView.layer.shadowOffset = CGSizeZero
        iconView.layer.shadowOpacity = 0.5
        iconView.collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        iconViewHeight.constant = getIconViewHeight()
        iconViewXLoc.constant = -iconViewHeight.constant - tabBarHeight
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func getIconViewHeight() -> CGFloat {
        return iconView.collectionView.collectionViewLayout.collectionViewContentSize().height + 50
    }
    
    func toggleIconView(show: Bool) {
        iconViewXLoc.constant = show ? 0 : -iconViewHeight.constant - tabBarHeight
        
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func filterBrandsTapped(sender: AnyObject) {
        iconView.switchTypes("brands")
        iconViewHeight.constant = getIconViewHeight()
        self.view.layoutIfNeeded()
        toggleIconView(true)
    }
    
    @IBAction func filterAbilitiesTapped(sender: AnyObject) {
        iconView.switchTypes("abilities")
        iconViewHeight.constant = getIconViewHeight()
        self.view.layoutIfNeeded()
        toggleIconView(true)
    }
    
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject) {
        toggleIconView(false)
    }
    
    func iconSelectionViewBrandsUpdated(view: IconSelectionView, brands: [String]) {
        
    }
    
    func iconSelectionViewAbilitiesUpdated(view: IconSelectionView, abilities: [String]) {
        
    }
}
