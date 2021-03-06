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

// MARK: - BrandView

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

// MARK: - BrandTableViewController

class BrandTableViewController: UITableViewController {
    var brandDisplayData = [JSON]()
    var brandDetailDisplaying = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateDisplay(newData: [JSON]) {
        brandDisplayData = newData
        brandDetailDisplaying = Array(count: newData.count, repeatedValue: false)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brandDisplayData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return brandDetailDisplaying[indexPath.row] ? 215 : 90
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let data = brandDisplayData[indexPath.row]
        
        if brandDetailDisplaying[indexPath.row] {
            cell = tableView.dequeueReusableCellWithIdentifier("cellBrandDetail", forIndexPath: indexPath)
            let brandIcon = cell.viewWithTag(1) as! BrandView
            let abilityUpImage = cell.viewWithTag(2) as! UIImageView
            let abilityDownImage = cell.viewWithTag(3) as! UIImageView
            let lblBrandName = cell.viewWithTag(4) as! UILabel
            let lblAbilityUpDesc = cell.viewWithTag(5) as! UILabel
            let lblAbilityDownDesc = cell.viewWithTag(6) as! UILabel
            
            brandIcon.brandName = brandDisplayData[indexPath.row]["name"].stringValue
            brandIcon.setNeedsDisplay()
            abilityUpImage.image = UIImage(named: "ability\(data["abilityUp"]["name"].stringValue.removeWhitespace()).png")
            abilityDownImage.image = UIImage(named: "ability\(data["abilityDown"]["name"].stringValue.removeWhitespace()).png")
            lblBrandName.text = data["name"].stringValue
            lblAbilityUpDesc.text = data["abilityUp"]["description"].stringValue
            lblAbilityDownDesc.text = data["abilityDown"]["description"].stringValue
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("cellBrand", forIndexPath: indexPath)
            let brandIcon = cell.viewWithTag(1) as! BrandView
            let abilityUpImage = cell.viewWithTag(2) as! UIImageView
            let abilityDownImage = cell.viewWithTag(3) as! UIImageView
            
            brandIcon.brandName = brandDisplayData[indexPath.row]["name"].stringValue
            brandIcon.setNeedsDisplay()
            abilityUpImage.image = UIImage(named: "ability\(data["abilityUp"]["name"].stringValue.removeWhitespace()).png")
            abilityDownImage.image = UIImage(named: "ability\(data["abilityDown"]["name"].stringValue.removeWhitespace()).png")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        brandDetailDisplaying[indexPath.row] = !brandDetailDisplaying[indexPath.row]
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        tableView.endUpdates()
    }
}

// MARK: - BrandGuideViewController

class BrandGuideViewController: UIViewController, IconSelectionViewDelegate {
    @IBOutlet weak var iconView: IconSelectionView!
    @IBOutlet weak var iconViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconViewXLoc: NSLayoutConstraint!
    var iconViewFullHeight: CGFloat = 0
    
    var brandTable: BrandTableViewController?
    var filterType = "brands"

    override func viewDidLoad() {
        super.viewDidLoad()

        iconView.delegate = self
        iconView.clipsToBounds = false
        iconView.layer.shadowColor = UIColor.blackColor().CGColor
        iconView.layer.shadowOffset = CGSizeZero
        iconView.layer.shadowOpacity = 0.5
        iconView.switchTypes("brands")
        iconView.setAbilities(abilitiesBrands)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        iconView.updateDisplay(true, displayTitle: false)
        iconViewHeight.constant = iconView.getProperHeight()
        iconViewXLoc.constant = -iconViewHeight.constant - tabBarHeight
    }

    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueBrandTable" {
            brandTable = segue.destinationViewController as? BrandTableViewController
            brandTable?.updateDisplay(brandData)
        }
    }
    
    func toggleIconView(show: Bool) {
        iconViewXLoc.constant = show ? 0 : -iconViewHeight.constant - tabBarHeight
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func filterBrandsTapped(sender: AnyObject) {
        iconView.switchTypes("brands")
        iconViewHeight.constant = iconView.getProperHeight()
        self.view.layoutIfNeeded()
        toggleIconView(true)
    }
    
    @IBAction func filterAbilitiesTapped(sender: AnyObject) {
        iconView.switchTypes("abilities")
        iconViewHeight.constant = iconView.getProperHeight()
        self.view.layoutIfNeeded()
        toggleIconView(true)
    }
    
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject) {
        toggleIconView(false)
    }
    
    func iconSelectionViewBrandsUpdated(view: IconSelectionView, selectedBrands: [String]) {
        iconView.abilitiesSelected = iconView.abilitiesSelected.map() { _ in false }
        
        if selectedBrands.count == 0 {
            brandTable?.updateDisplay(brandData)
        } else {
            var updatedBrandData = [JSON]()
            for data in brandData {
                if selectedBrands.contains(data["name"].stringValue) { updatedBrandData.append(data) }}
            
            brandTable?.updateDisplay(updatedBrandData)
        }
    }
    
    func iconSelectionViewAbilitiesUpdated(view: IconSelectionView, selectedAbilities: [String]) {
        iconView.brandsSelected = iconView.brandsSelected.map() { _ in false }
        
        if selectedAbilities.count == 0 {
            brandTable?.updateDisplay(brandData)
        } else {
            var updatedAbilityData = [JSON]()
            for data in brandData {
                if selectedAbilities.contains(data["abilityUp"]["name"].stringValue) ||
                    selectedAbilities.contains(data["abilityDown"]["name"].stringValue)
                { updatedAbilityData.append(data) }}
            
            brandTable?.updateDisplay(updatedAbilityData)
        }
    }
}
