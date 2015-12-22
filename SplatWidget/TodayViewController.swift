//
//  TodayViewController.swift
//  SplatWidget
//
//  Created by Kevin Sullivan on 12/21/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        NNID.sharedInstance.cookie = ""
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if NNID.sharedInstance.saveLogin && NNID.sharedInstance.cookie == "" {
            loginNNID { error in
                loadMaps { data in
                    if data["errorCode"].int != nil {
                        completionHandler(NCUpdateResult.Failed)
                    }
                    else {
                        completionHandler(NCUpdateResult.NewData)
                    }
                }
            }
        }
        else {
            loadMaps { data in
                if data["errorCode"].int != nil {
                    completionHandler(NCUpdateResult.Failed)
                }
                else {
                    completionHandler(NCUpdateResult.NewData)
                }
            }
        }
        
        

        
    }
    
}
