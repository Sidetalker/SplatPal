//
//  GearCell.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 2/18/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class LongPressCellGestureRecognizer: UILongPressGestureRecognizer {
    var tableView = UITableView()
    var gearDisplayData = [[Gear]]()
}

extension MGSwipeTableCell {
    func addSwipeButtonsForGear(gear: Gear, gearDisplayData: [[Gear]], tableView: UITableView, indexPath: NSIndexPath) {
        let prefs = NSUserDefaults.standardUserDefaults()
        let owned = prefs.integerForKey("\(gear.shortName)-owned")
        if owned != 0 {
            self.contentView.backgroundColor = owned > 0 ? SplatAppStyle.loggedIn : SplatAppStyle.loggedOut
        } else {
            self.contentView.backgroundColor = UIColor.clearColor()
        }
        
        let expansionSettings = MGSwipeExpansionSettings()
        let ownedSwipe = MGSwipeButton(title: "Owned", backgroundColor: SplatAppStyle.loggedIn) { _ in
            tableView.beginUpdates()
            prefs.setInteger(1, forKey: "\(gear.shortName)-owned")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            return true
        }
        let notOwnedSwipe = MGSwipeButton(title: "Not Owned", backgroundColor: SplatAppStyle.loggedOut) { _ in
            tableView.beginUpdates()
            prefs.setInteger(-1, forKey: "\(gear.shortName)-owned")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            return true
        }
        
        expansionSettings.buttonIndex = 0
        expansionSettings.fillOnTrigger = false
        expansionSettings.threshold = 1.2
        self.leftButtons = [ownedSwipe]
        self.leftExpansion = expansionSettings
        self.rightButtons = [notOwnedSwipe]
        self.rightExpansion = expansionSettings
        
        for gestureRecognizer in self.contentView.gestureRecognizers! {
            self.contentView.removeGestureRecognizer(gestureRecognizer) }
        
        let gesture = LongPressCellGestureRecognizer(target: self, action: "cellLongPress:")
        gesture.tableView = tableView
        gesture.gearDisplayData = gearDisplayData
        
        self.contentView.addGestureRecognizer(gesture)
    }
    
    func cellLongPress(recognizer: LongPressCellGestureRecognizer) {
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
    
    func configureWithGear(gear: Gear) {
        lblName.text = gear.name
        imgGear.image = gear.getImage()
        imgAbilityMain.image = gear.getAbilityImage()
        imgAbilitySub.image = gear.getAbilitySubImage()
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
    
    func configureWithGear(gear: Gear) {
        lblName.text = gear.name
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
    }
}
