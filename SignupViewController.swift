//
//  SignupViewController.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit
import CoreData

class SignupViewController:UIViewController, UITextFieldDelegate{

       @IBOutlet weak var main_title: UILabel!
    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let username = LocalData().getUsername()
        if let username = username {
                main_title.text = username
        }
        else{
            main_title.text = "A man has no name!"
        }
        nameTextField.delegate = self
        nameTextField.hidden = true
        main_title.userInteractionEnabled = true
        let aSelector : Selector = #selector(SignupViewController.lblTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        main_title.addGestureRecognizer(tapGesture)

    }
    func lblTapped(){
        main_title.hidden = true
        nameTextField.hidden = false
        nameTextField.text = main_title.text
    }
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        nameTextField.hidden = true
        main_title.hidden = false
        main_title.text = nameTextField.text
        return true
    }

     override func viewDidAppear(animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
