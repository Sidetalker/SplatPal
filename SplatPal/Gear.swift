//
//  Gear.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 2/18/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import SwiftyJSON

class Gear {
    var name = ""
    var shortName = ""
    var category = ""
    var ability = ""
    var abilityShortName = ""
    var abilitySub = ""
    var abilitySubShortName = ""
    var brand = ""
    var cost = ""
    var rarity = 0
    var initialized = false
    
    init() { }
    
    init(data: JSON) {
        if let
            name = data["name"].string,
            category = data["category"].string,
            ability = data["ability"].string,
            brand = data["brand"].string,
            cost = data["cost"].string,
            rarityString = data["rarity"].string,
            rarity = Int(rarityString)
        {
            self.name = name
            self.shortName = name.removeWhitespace()
            self.category = category
            self.ability = ability
            self.abilityShortName = ability.removeWhitespace()
            self.abilitySub = abilityUpForBrand(brand)
            self.abilitySubShortName = abilitySub.removeWhitespace()
            self.brand = brand
            self.cost = cost
            self.rarity = rarity
            self.initialized = true
        } else {
            log.error("Could not initialize gear (\(name))")
        }
    }
    
    func getImage() -> UIImage? {
        if let image = UIImage(named: "gear\(shortName).png") {
            return image
        } else {
            log.error("Could not load image for gear (\(name))")
            return nil
        }
    }
    
    func getAbilityImage() -> UIImage? {
        if let image = UIImage(named: "ability\(abilityShortName).png") {
            return image
        } else {
            log.error("Could not load image for gear ability (\(name) - \(ability))")
            return nil
        }
    }
    
    func getAbilitySubImage() -> UIImage? {
        if let image = UIImage(named: "ability\(abilitySubShortName).png") {
            return image
        } else {
            log.error("Could not load image for gear sub ability (\(name) - \(abilityShortName))")
            return nil
        }
    }
    
    func isStarred() -> Bool {
        if NSUserDefaults.standardUserDefaults().integerForKey("\(shortName)-starred") == 1 { return true }
        else { return false }
    }
    
    func isOwned() -> Bool {
        if NSUserDefaults.standardUserDefaults().integerForKey("\(shortName)-owned") == 1 { return true }
        else { return false }
    }
    
    func toggleStarred() {
        let starred = NSUserDefaults.standardUserDefaults().integerForKey("\(shortName)-starred")
        
        if starred == 1 { NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "\(shortName)-starred") }
        else { NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "\(shortName)-starred") }
    }
    
    func setOwned(owned: Bool) {
        if owned { NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "\(shortName)-owned") }
        else { NSUserDefaults.standardUserDefaults().setInteger(-1, forKey: "\(shortName)-owned") }
    }
}