//
//  StoryboardSplitter.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 3/27/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit

class SplatWinTrackerTab: UIViewController {
    override func viewDidLoad() {
        let destination = StoryboardScene.Matches.initialViewController()
        addChildViewController(destination)
        view.addSubview(destination.view)
        destination.didMoveToParentViewController(self)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
}
