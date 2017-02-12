//
//  TabBarController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 2/9/17.
//  Copyright © 2017 Kevin Sullivan. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    static let startingTabIndexKey = "TabBarController-StartingTabIndexKey"
    
    // Load the current tab from `NSUserDefaults`.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let startingIndex = userDefaults.objectForKey(TabBarController.startingTabIndexKey) as? Int ?? 0
        
        selectedIndex = startingIndex
    }
    
    // MARK: Tab Bar Methods
    
    /// Save the current selected tab into defaults.
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if let tabBarItems = tabBar.items, index = tabBarItems.indexOf(item) {
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            userDefaults.setObject(index, forKey: TabBarController.startingTabIndexKey)
        }
    }
    
    override func tabBar(tabBar: UITabBar, didEndCustomizingItems items: [UITabBarItem], changed: Bool) {
        var tabOrder = [Int]()
        
        for item in tabBar.items! {
            tabOrder.append(item.tag)
        }
        
        log.debug("Tab order changed to \(tabOrder)")
        
        NSUserDefaults.standardUserDefaults().setObject(tabOrder, forKey: "tabOrder")
    }
}