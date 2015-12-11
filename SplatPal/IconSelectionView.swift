//
//  BrandSelectionView.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

let brands = ["amiibo", "Cuttlegear", "Famitsu", "Firefin", "Forge", "Inkline", "Krak-On", "Rockenberg", "Skalop", "Splash Mob", "SquidForce", "Takoroka", "Tentatek", "The SQUID GIRL", "Zekko", "Zink"]

protocol IconSelectionViewDelegate {
    func iconSelectionViewClear(view: IconSelectionView, sender: AnyObject)
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject)
}

@IBDesignable class IconSelectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var delegate: IconSelectionViewDelegate?
    var view: UIView!
    var viewType = ""
    var brandsSelected = [Bool]()
    
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
        
        collectionView.registerClass(IconCell.self, forCellWithReuseIdentifier: "brandCell")
        collectionView.backgroundColor = UIColor.clearColor()
        
        brandsSelected = Array(count: 16, repeatedValue: false)
    }
    
    @IBAction func clearTapped(sender: AnyObject) {
        delegate?.iconSelectionViewClear(self, sender: sender)
        brandsSelected = brandsSelected.map { _ in false }
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
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("brandCell", forIndexPath: indexPath) as! IconCell
        cell.clipsToBounds = false
        cell.backgroundColor = UIColor.clearColor()
        cell.brandName = brands[indexPath.row]
        cell.pressed = brandsSelected[indexPath.row]
        cell.setNeedsDisplay()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        brandsSelected[indexPath.row] = !brandsSelected[indexPath.row]
        collectionView.reloadData()
    }
}

class IconCell: UICollectionViewCell {
    let shadowA = SplatAppStyle.shadowSelected
    let shadowB = SplatAppStyle.shadowUnselected
    let fillA = SplatAppStyle.brandPressedFill
    let fillB = UIColor.whiteColor()
    
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
