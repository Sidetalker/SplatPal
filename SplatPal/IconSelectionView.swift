//
//  BrandSelectionView.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

let brands = ["amiibo", "Cuttlegear", "Famitsu", "Firefin", "Forge", "Inkline", "Krak-On", "Rockenberg", "Skalop", "Splash Mob", "SquidForce", "Takoroka", "Tentatek", "The SQUID GIRL", "Zekko", "Zink"]
let icons = ["Bomb Range Up", "Bomb Sniffer", "Cold Blooded", "Comeback", "Damage Up", "Defense Up", "Haunt", "InkRecoveryUp", "Ink Resistance Up", "Ink Saver (Main)", "Ink Saver (Sub)", "Last-Ditch Effort", "Ninja Squid", "Opening Gambit", "Quick Respawn", "Quick Super Jump", "Recon", "Run Speed Up", "Special Charge Up", "Special Duration Up", "Special Saver", "Stealth Jump", "Swim Speed Up", "Tenacity"]
let iconsRestricted = [icons[4], icons[5], icons[7], icons[9], icons[10], icons[14], icons[15], icons[17], icons[18], icons[19], icons[20], icons[22]]

protocol IconSelectionViewDelegate {
    func iconSelectionViewClear(view: IconSelectionView, sender: AnyObject)
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject)
}

@IBDesignable class IconSelectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    var delegate: IconSelectionViewDelegate?
    var view: UIView!
    var viewType = ""
    var brandsSelected = [Bool]()
    var abilitiesSelected = [Bool]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "IconSelectionView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func configure() {
        view = loadViewFromNib()
        view.frame = bounds
        self.addSubview(view)
        
        collectionView.registerClass(BrandCell.self, forCellWithReuseIdentifier: "brandCell")
        collectionView.registerClass(AbilityCell.self, forCellWithReuseIdentifier: "abilityCell")
        collectionView.backgroundColor = UIColor.clearColor()
        
        brandsSelected = Array(count: 16, repeatedValue: false)
        abilitiesSelected = Array(count: 12, repeatedValue: false)
    }
    
    func switchTypes(newType: String) {
        viewType = newType
        collectionView.reloadData()
        
        switch newType {
        case "brands":
            view.backgroundColor = UIColor.whiteColor()
            collectionView.backgroundColor = UIColor.whiteColor()
            btnClear.setTitleColor(UIColor.blackColor(), forState: .Normal)
            btnClose.setTitleColor(UIColor.blackColor(), forState: .Normal)
        case "abilities":
            view.backgroundColor = UIColor.blackColor()
            collectionView.backgroundColor = UIColor.blackColor()
            btnClear.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            btnClose.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        default: break
        }
    }
    
    @IBAction func clearTapped(sender: AnyObject) {
        delegate?.iconSelectionViewClear(self, sender: sender)
        brandsSelected = brandsSelected.map { _ in false }
        abilitiesSelected = abilitiesSelected.map { _ in false }
        collectionView.reloadData()
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        delegate?.iconSelectionViewClose(self, sender: sender)
    }
    
    // MARK: - UICollectionView functions
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewType == "" ? 0 : 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewType {
        case "brands":
            return 16
        case "abilities":
            return 10
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch viewType {
        case "brands":
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("brandCell", forIndexPath: indexPath) as! BrandCell
            cell.backgroundColor = UIColor.clearColor()
            cell.brandName = brands[indexPath.row]
            cell.pressed = brandsSelected[indexPath.row]
            cell.setNeedsDisplay()
            
            return cell
        case "abilities":
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("abilityCell", forIndexPath: indexPath) as! AbilityCell
            cell.pressed = abilitiesSelected[indexPath.row]
            cell.index = indexPath.row
            cell.update()
            
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch viewType {
        case "brands": brandsSelected[indexPath.row] = !brandsSelected[indexPath.row]
        case "abilities": abilitiesSelected[indexPath.row] = !abilitiesSelected[indexPath.row]
        default: break
        }
        
        collectionView.reloadData()
    }
}

class AbilityCell: UICollectionViewCell {
    var imageView: UIImageView!
    var pressed = false
    var index = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        imageView = UIImageView(frame: CGRectMake(5, 6, 54, 54))
        addSubview(imageView)
    }
    
    func update() {
        let image: UIImage = pressed ? SplatAppStyle.imageOfAbilityContainerSelected: SplatAppStyle.imageOfAbilityContainerUnselected
        backgroundColor = UIColor(patternImage: image)
        imageView.image = UIImage(named: "ability\(iconsRestricted[index].removeWhitespace()).png")
    }
}

class BrandCell: UICollectionViewCell {
    let shadowA = SplatAppStyle.shadowSelected
    let shadowB = SplatAppStyle.shadowUnselected
    let fillA = SplatAppStyle.brandPressedFill
    let fillB = UIColor.whiteColor()
    
    var index = -1
    var brandName = ""
    var pressed = false
    
    override func drawRect(rect: CGRect) {
        switch brandName {
        case "amiibo":
            SplatAppStyle.drawBrandAmiibo(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Cuttlegear":
            SplatAppStyle.drawBrandCuttlegear(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Famitsu":
            SplatAppStyle.drawBrandFamitsu(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Firefin":
            SplatAppStyle.drawBrandFirefin(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Forge":
            SplatAppStyle.drawBrandForge(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Inkline":
            SplatAppStyle.drawBrandInkline(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Krak-On":
            SplatAppStyle.drawBrandKrakOn(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Rockenberg":
            SplatAppStyle.drawBrandRockenberg(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Skalop":
            SplatAppStyle.drawBrandSkalop(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Splash Mob":
            SplatAppStyle.drawBrandSplashMob(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "SquidForce":
            SplatAppStyle.drawBrandSquidForce(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Takoroka":
            SplatAppStyle.drawBrandTakoroka(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Tentatek":
            SplatAppStyle.drawBrandTentatek(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "The SQUID GIRL":
            SplatAppStyle.drawBrandTheSQUIDGIRL(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Zekko":
            SplatAppStyle.drawBrandZekko(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        case "Zink":
            SplatAppStyle.drawBrandZink(frame: rect, brandFill: pressed ? fillA : fillB, shadow: pressed ? shadowA : shadowB)
        default:
            super.drawRect(rect)
        }
    }
}
