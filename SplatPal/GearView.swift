//
//  GearView.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 12/22/15.
//  Copyright © 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class GearView: UIView {
    @IBOutlet weak var imgGear: UIImageView!
    @IBOutlet weak var imgAbilityMain: UIImageView!
    @IBOutlet weak var imgAbility1: UIImageView!
    @IBOutlet weak var imgAbility2: UIImageView!
    @IBOutlet weak var imgAbility3: UIImageView!
    @IBOutlet weak var bgView: UIView!
    
    var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "GearView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func configure() {
        view = loadViewFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTile.jpg")!)
        bgView.layer.cornerRadius = 10
        bgView.alpha = 0.3
        self.addSubview(view)
    }
    
    override func layoutSubviews() {
        view.frame = bounds
    }
    
    func updateGear(gear: LoadoutGear) {
        imgGear.image = UIImage(named: "gear\(gear.name.removeWhitespace()).png")
        imgAbilityMain.image = UIImage(named: "ability\(gear.abilityPrimary.removeWhitespace()).png")
        imgAbility1.image = UIImage(named: "ability\(gear.ability1.removeWhitespace()).png")
        imgAbility2.image = UIImage(named: "ability\(gear.ability2.removeWhitespace()).png")
        imgAbility3.image = UIImage(named: "ability\(gear.ability3.removeWhitespace()).png")
    }
}