//
//  GearCell.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 2/18/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class LongPressGearCellRecognizer: UILongPressGestureRecognizer {
    var tableView = UITableView()
    var gearDisplayData = [[Gear]]()
}

extension MGSwipeTableCell {
    func addSwipeButtonsForGear(gear: Gear, gearDisplayData: [[Gear]], tableView: UITableView, indexPath: NSIndexPath) {
        let expansionSettings = MGSwipeExpansionSettings()
        let setOwned: (owned: Bool) -> Bool = { owned in
            tableView.beginUpdates()
            gear.setOwned(owned)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            return true
        }
        let toggleStarred: () -> Bool = {
            tableView.beginUpdates()
            gear.toggleStarred()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            return true
        }
        
        let ownedSwipe = MGSwipeButton(title: "Owned", backgroundColor: SplatAppStyle.loggedIn) { _ in
            setOwned(owned: true)
        }
        let notOwnedSwipe = MGSwipeButton(title: "Not Owned", backgroundColor: SplatAppStyle.loggedOut) { _ in
            setOwned(owned: false)
        }
        let starSwipe = MGSwipeButton(title: "", icon: UIImage(named: "bookmarkStar"), backgroundColor: SplatAppStyle.loggedIn) { _ in
            toggleStarred()
        }
        
        expansionSettings.buttonIndex = 0
        expansionSettings.fillOnTrigger = false
        expansionSettings.threshold = 1.2
        self.leftButtons = [ownedSwipe, starSwipe]
        self.leftExpansion = expansionSettings
        let offsetSwipe = MGSwipeSettings()
        offsetSwipe.offset = 15 // Offset for section index titles
        self.rightButtons = [notOwnedSwipe]
        self.rightExpansion = expansionSettings
        self.rightSwipeSettings = offsetSwipe
        
        for gestureRecognizer in self.contentView.gestureRecognizers! {
            self.contentView.removeGestureRecognizer(gestureRecognizer) }
        
        let gesture = LongPressGearCellRecognizer(target: self, action: "cellLongPress:")
        gesture.tableView = tableView
        gesture.gearDisplayData = gearDisplayData
        
        self.contentView.addGestureRecognizer(gesture)
    }
    
    func cellLongPress(recognizer: LongPressGearCellRecognizer) {
        guard recognizer.state == .Began else { return }
        
        let point = recognizer.locationInView(recognizer.tableView)
        let indexPath = recognizer.tableView.indexPathForRowAtPoint(point)
        let gear = recognizer.gearDisplayData[indexPath!.section][indexPath!.row]
        let prefs = NSUserDefaults.standardUserDefaults()
        
        recognizer.tableView.beginUpdates()
        prefs.setInteger(0, forKey: "\(gear.shortName)-owned")
        recognizer.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        recognizer.tableView.endUpdates()
    }
}

class GearCell: MGSwipeTableCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgGear: UIImageView!
    @IBOutlet weak var imgAbilityMain: UIImageView!
    @IBOutlet weak var imgAbilitySub: UIImageView!
    @IBOutlet weak var imgBookmark: UIImageView!
    
    func configureForGear(gear: Gear) {
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        lblName.text = gear.localizedName
        imgGear.image = gear.getImage()
        imgAbilityMain.image = gear.getAbilityImage()
        imgAbilitySub.image = gear.getAbilitySubImage()
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let owned = prefs.integerForKey("\(gear.shortName)-owned")
        let starred = prefs.integerForKey("\(gear.shortName)-starred")
        
        if owned != 0 {
            self.contentView.backgroundColor = owned > 0 ? SplatAppStyle.loggedIn : SplatAppStyle.loggedOut
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
        }
        
        if starred == 1 {
            var bookmarkColor = UIColor.whiteColor()
            
            switch owned {
            case -1:
                bookmarkColor = SplatAppStyle.loggedOut
            case 1:
                bookmarkColor = SplatAppStyle.loggedIn
            default:
                bookmarkColor = SplatAppStyle.brandPressedFill
            }
            
            let bookmark = SplatAppStyle.imageOfBookmark(frame: CGRectMake(0, 0, imgBookmark.frame.width, imgBookmark.frame.height), bookmarkColor: bookmarkColor)
            imgBookmark.image = bookmark
        } else { imgBookmark.image = nil }
    }
}

class GearDetailCell: MGSwipeTableCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAbilityMain: UILabel!
    @IBOutlet weak var lblAbilitySub: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var imgGear: UIImageView!
    @IBOutlet weak var imgAbilityMain: UIImageView!
    @IBOutlet weak var imgAbilitySub: UIImageView!
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    @IBOutlet weak var imgBookmark: UIImageView!
    
    func configureForGear(gear: Gear) {
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        
        lblName.text = gear.localizedName
        lblAbilityMain.text = abilityData[gear.ability]?.stringValue
        lblAbilitySub.text = abilityData[gear.abilitySub]?.stringValue
        lblCost.text = gear.cost
        lblBrand.text = gear.brand
        imgGear.image = gear.getImage()
        imgAbilityMain.image = gear.getAbilityImage()
        imgAbilitySub.image = gear.getAbilitySubImage()
        
        switch gear.rarity {
        case 2:
            imgStar2.image = imgStar1.image
            imgStar3.image = nil
        case 3:
            imgStar2.image = imgStar1.image
            imgStar3.image = imgStar1.image
        default:
            imgStar2.image = nil
            imgStar3.image = nil
        }
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let owned = prefs.integerForKey("\(gear.shortName)-owned")
        let starred = prefs.integerForKey("\(gear.shortName)-starred")
        
        if owned != 0 {
            self.contentView.backgroundColor = owned > 0 ? SplatAppStyle.loggedIn : SplatAppStyle.loggedOut
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
        }
        
        if starred == 1 {
            var bookmarkColor = UIColor.whiteColor()
            
            switch owned {
            case -1:
                bookmarkColor = SplatAppStyle.loggedOut
            case 1:
                bookmarkColor = SplatAppStyle.loggedIn
            default:
                bookmarkColor = SplatAppStyle.brandPressedFill
            }
            
            let bookmark = SplatAppStyle.imageOfBookmark(frame: CGRectMake(0, 0, imgBookmark.frame.width, imgBookmark.frame.height), bookmarkColor: bookmarkColor)
            imgBookmark.image = bookmark
        } else { imgBookmark.image = nil }
    }
}
