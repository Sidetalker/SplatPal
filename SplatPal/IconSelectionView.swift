//
//  BrandSelectionView.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

let brands = ["amiibo", "Cuttlegear", "Famitsu", "Firefin", "Forge", "Inkline", "Krak-On", "Rockenberg", "Skalop", "Splash Mob", "SquidForce", "Takoroka", "Tentatek", "The SQUID GIRL", "Zekko", "Zink"]

class IconSelectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var view: UIView!
    var type = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        self.addSubview(view)
        collectionView.reloadData()
        
        collectionView.registerClass(IconCell.self, forCellWithReuseIdentifier: "brandCell")
        collectionView.backgroundColor = UIColor.clearColor()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "IconSelectionView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return type == "" ? 0 : 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case "brands":
            return 16
        default:
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("brandCell", forIndexPath: indexPath) as! IconCell
        cell.backgroundColor = UIColor.clearColor()
        cell.brandName = brands[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(65, 65)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 15, 5, 15)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
}

class IconCell: UICollectionViewCell {
    let fillA = UIColor.lightTextColor()
    let fillB = UIColor.whiteColor()
    let shadowA = SplatAppStyle.shadowSelected
    let shadowB = SplatAppStyle.shadowUnselected
    
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
