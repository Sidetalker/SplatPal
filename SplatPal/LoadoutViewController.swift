//
//  LoadoutViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/22/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class LoadoutViewController: UIViewController {
    
}

class LoadoutTableViewController: UITableViewController {
    
}

class Loadout {
    var name = ""
    var headgear = Gear()
    var clothing = Gear()
    var shoes = Gear()
}

class Gear {
    var name = ""
    var abilityPrimary = ""
    var ability1 = ""
    var ability2 = ""
    var ability3 = ""
}