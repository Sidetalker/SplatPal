//
//  ProfileViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/19/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class Profile {
    var mii: String?
    var username: String?
    var level: String?
    var rank: String?
    
    
}

class ProfileGearViewController: UIViewController {
    @IBOutlet weak var imgGear: UIImageView!
    @IBOutlet weak var imgAbilityMain: UIImageView!
    @IBOutlet weak var imgAbilitySub1: UIImageView!
    @IBOutlet weak var imgAbilitySub2: UIImageView!
    @IBOutlet weak var imgAbilitySub3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
    }
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    var headVC: ProfileGearViewController!
    var bodyVC: ProfileGearViewController!
    var footVC: ProfileGearViewController!
    var headView: UIView!
    var bodyView: UIView!
    var footView: UIView!

    
    let splatoonProfileURL = "https://splatoon.nintendo.net/profile"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headVC = storyboard?.instantiateViewControllerWithIdentifier("profileGear") as! ProfileGearViewController
        bodyVC = storyboard?.instantiateViewControllerWithIdentifier("profileGear") as! ProfileGearViewController
        footVC = storyboard?.instantiateViewControllerWithIdentifier("profileGear") as! ProfileGearViewController
        headView = headVC.view
        bodyView = bodyVC.view
        footView = footVC.view
        
        var baseFrame = CGRectMake(self.view.frame.width / 2 - 100, 0, 200, 200)
        headView.frame = baseFrame
        baseFrame.origin.y = self.view.frame.height / 2 - 100
        bodyView.frame = baseFrame
        baseFrame.origin.y = self.view.frame.height - 200
        footView.frame = baseFrame
        
        
        scrollView.addSubview(headView)
        scrollView.addSubview(bodyView)
        scrollView.addSubview(footView)
        
        
//        loadProfile()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func loadProfile() {
        request(.GET, splatoonProfileURL, encoding: .URL, headers: ["locale" : "en"])
            .responseString { response in
                if response.result.isFailure {
                    log.error("Error Loading Schedule: \(response.result.error)")
                }
                else if let doc = Kanna.HTML(html: response.result.value!, encoding: NSUTF8StringEncoding) {
                    log.debug("Loaded HTML: \(doc.title!)")
                    
                    let profile = Profile()
                    
                    profile.mii = doc.xpath("//div[@class=\"profile-mii icon-mii\"]/img/@src").text
                    profile.username = doc.xpath("//h2[@class=\"profile-username\"]").text
                    
                }
        }
    }
}
