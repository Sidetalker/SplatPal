//
//  LoadingViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/9/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class LoadingViewController: UIViewController {
    
    var rankedModes = [Int]()
    var rankedMaps = [String]()
    var rankedTimes = [String]()
    var turfMaps = [String]()
    var turfTimes = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        delay(1.0, closure: {
            self.performSegueWithIdentifier("segueInitial", sender: self)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        return
    }
}
