//
//  SplatKDRViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 3/27/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit
import LTMorphingLabel
import TCDInputView

enum SplatKDRViewType {
    case Kills
    case Deaths
    
    func title() -> String {
        switch self {
        case .Kills:
            return NSLocalizedString("How many kills?", comment: "")
        case .Deaths:
            return NSLocalizedString("How many deaths?", comment: "")
        }
    }
}

class SplatKDRViewController: SplatViewController, UITextFieldDelegate, LTMorphingLabelDelegate {
    @IBOutlet weak var lblTitle: LTMorphingLabel! {
        didSet {
            lblTitle.morphingEnabled = false
            lblTitle.text = type.title()
            lblTitle.delegate = self
        }
    }
    
//    @IBOutlet weak var txtInput: TextField!
    
    var type: SplatKDRViewType!
    var match: Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        txtInput.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if type == .Kills {
            type = .Deaths
//            txtEntry.text = nil
            lblTitle.morphingEnabled = true
            lblTitle.text = type.title()
        } else if type == .Deaths {
            
        }
        
        return false
    }
}
