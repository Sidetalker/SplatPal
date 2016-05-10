//
//  SplatTrackMainViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 3/27/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit
import ElasticTransition

class SplatTrackMainViewController: SplatViewController {
    let itsNotReadyYetBro = true
    
    var currentMatch: Match?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if itsNotReadyYetBro {
            let overlay = UIView(frame: view.frame)
            overlay.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
            
            let lblInfo = UILabel(frame: view.frame)
            lblInfo.text = "Not ready quite yet, coming soon!"
            lblInfo.textColor = .whiteColor()
            lblInfo.textAlignment = .Center
            
            view.addSubview(overlay)
            view.addSubview(lblInfo)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    @IBAction func winTapped(sender: AnyObject) {
        recordMatch(true)
    }
    
    @IBAction func lossTapped(sender: AnyObject) {
        recordMatch(false)
    }
    
    func recordMatch(win: Bool) {
        currentMatch = Match(win: win)
        
        let transition = ElasticTransition()
        transition.edge = .Bottom
        transition.sticky = false
        transition.panThreshold = 0.3
        transition.transformType = .TranslatePull
        
        let kdrView = StoryboardScene.Matches.instantiateKdr()
        kdrView.transitioningDelegate = transition
        kdrView.modalPresentationStyle = .Custom
        kdrView.match = currentMatch!
        kdrView.type = .Kills
        
        self.presentViewController(kdrView, animated: true, completion: nil)
    }
}
