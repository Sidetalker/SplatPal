//
//  BrandGuideViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/10/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

let tabBarHeight: CGFloat = 49

class BrandGuideViewController: UIViewController, IconSelectionViewDelegate {
    @IBOutlet weak var iconView: IconSelectionView!
    @IBOutlet weak var iconViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconViewXLoc: NSLayoutConstraint!
    
    var iconViewFullHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        iconView.viewType = "brands"
        iconView.delegate = self
        iconView.clipsToBounds = false
        iconView.layer.shadowColor = UIColor.blackColor().CGColor
        iconView.layer.shadowOffset = CGSizeZero
        iconView.layer.shadowOpacity = 0.5
        iconView.collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        iconViewHeight.constant = getIconViewHeight()
        iconViewXLoc.constant = -iconViewHeight.constant - tabBarHeight
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func getIconViewHeight() -> CGFloat {
        return iconView.collectionView.collectionViewLayout.collectionViewContentSize().height + 50
    }
    
    func toggleIconView(show: Bool) {
        iconViewXLoc.constant = show ? 0 : -iconViewHeight.constant - tabBarHeight
        
        UIView.animateWithDuration(0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func filterBrandsTapped(sender: AnyObject) {
        iconView.switchTypes("brands")
        iconViewHeight.constant = getIconViewHeight()
        self.view.layoutIfNeeded()
        toggleIconView(true)
    }
    
    @IBAction func filterAbilitiesTapped(sender: AnyObject) {
        iconView.switchTypes("abilities")
        iconViewHeight.constant = getIconViewHeight()
        self.view.layoutIfNeeded()
        toggleIconView(true)
    }
    
    func iconSelectionViewClear(view: IconSelectionView, sender: AnyObject) {
//        toggleIconView(true)
    }
    
    func iconSelectionViewClose(view: IconSelectionView, sender: AnyObject) {
        toggleIconView(false)
    }
}
