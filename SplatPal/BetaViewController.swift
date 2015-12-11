//
//  BetaViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/11/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class BetaViewController: UIViewController {
    @IBOutlet weak var txtChangeLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("changelog", ofType: "txt")
        do {
            let log = try String(contentsOfFile:path!, encoding: NSUTF8StringEncoding)
            let logLines = log.characters.split{$0 == "\n"}.map(String.init)
            let logDisplay = NSMutableAttributedString()
            
            for line in logLines {
                let attrLine = line.rangeOfString("Version") != nil ?
                    NSAttributedString(string: "\n\(line)\n", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(17.0)]) :
                    NSAttributedString(string: "\(line)\n", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17.0)])
                logDisplay.appendAttributedString(attrLine)
            }
            
            txtChangeLog.attributedText = logDisplay
            
        } catch _ as NSError { log.error("Couldn't read changelog") }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func btnFeedbackTapped(sender: AnyObject) {
        
    }
}
