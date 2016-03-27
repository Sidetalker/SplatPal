//
//  SplatKDRViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 3/27/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit

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

class SplatKDRViewController: SplatViewController, UITextFieldDelegate {
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.text = type.title()
        }
    }
    @IBOutlet weak var txtEntry: UITextField! {
        didSet {
            txtEntry.text = nil
            txtEntry.delegate = self
        }
    }
    
    var type: SplatKDRViewType!
    var match: Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        return false
    }
}
