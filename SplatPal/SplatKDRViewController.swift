//
//  SplatKDRViewController.swift
//  SplatPal
//
//  Created by Kevin Sullivan on 3/27/16.
//  Copyright © 2016 Kevin Sullivan. All rights reserved.
//

import UIKit
import LTMorphingLabel

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
    
    @IBOutlet weak var txtInput: UITextField! {
        didSet {
            txtInput.keyboardType = .NumberPad
        }
    }
    
    lazy var nextAccessoryView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        view.backgroundColor = .greenColor()
        
        let label = UILabel(frame: view.frame)
        label.text = "test"
        
        
        view.addSubview(label)
        
        return view
        
        
        
//        
//        let button = UIButton(type: .Custom)
//        button.setTitle("Done", forState: .Normal)
//        button.addTarget(self, action: "buttonAction:", forControlEvents: .TouchUpInside)
//        button.frame = CGRect(x: 5, y: 5, width: 300, height: 30)
//        
//        let view = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 40))
//        view.addSubview(button)
//        
//        textField.inputAccessoryView = view
//        
//        
//        if (!inputAccessoryView) {
//            CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 77.0);
//            inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
//            inputAccessoryView.backgroundColor = [UIColor blueColor];
//            UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0);
//            [compButton setTitle: @"Word Completions" forState:UIControlStateNormal];
//            [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [compButton addTarget:self action:@selector(completeCurrentWord:)
//            forControlEvents:UIControlEventTouchUpInside];
//            [inputAccessoryView addSubview:compButton];
        
        
    }()
    
    var type: SplatKDRViewType!
    var match: Match!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        txtInput.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        txtInput.inputAccessoryView = nextAccessoryView
        txtInput.becomeFirstResponder()
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
