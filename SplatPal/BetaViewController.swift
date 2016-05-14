//
//  BetaViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/11/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import Crashlytics

class BetaViewController: UIViewController {
    @IBOutlet weak var txtChangeLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let changeLogPath = NSBundle.mainBundle().pathForResource("changelog", ofType: "txt")
        do {
            let logString = try String(contentsOfFile:changeLogPath!, encoding: NSUTF8StringEncoding)
            let logLines = logString.characters.split{$0 == "\n"}.map(String.init)
            let logDisplay = NSMutableAttributedString()
            var firstLine = true
            
            // Bold and add newlines between version lines
            for line in logLines {
                let attrLine = line.rangeOfString("Version") != nil ?
                    NSAttributedString(string: "\(firstLine ? "" : "\n")\(line)\n", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15.0)]) :
                    NSAttributedString(string: "\(line)\n", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15.0)])
                logDisplay.appendAttributedString(attrLine)
                if firstLine { firstLine = false }
            }
            
            txtChangeLog.attributedText = logDisplay
            
        } catch _ as NSError { log.error("Couldn't read changelog") }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        txtChangeLog.scrollRangeToVisible(NSMakeRange(0,0))
    }
    override func prefersStatusBarHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("hideStatusBar")
    }
    
    @IBAction func btnFeedbackTapped(sender: AnyObject) {
        feedback.showFeedbackDialogInViewController(self, completion: { error, isCanceled in
            Crashlytics.sharedInstance().setUserEmail(feedback.email)
            if error != nil { log.error("Feedback error: \(error)") }
        })
    }
}
