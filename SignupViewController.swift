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
    @IBOutlet weak var businessSwitch: UISwitch!
    
    @IBOutlet weak var friendshipLabel: UILabel!
    @IBOutlet weak var loveLable: UILabel!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var friendshipSwitch: UISwitch!
    @IBOutlet weak var loveSwitch: UISwitch!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    @IBAction func beginBridgingTouched(sender: AnyObject) {
        if let _ = PFUser.currentUser() {
         PFUser.currentUser()?["name"] = main_title.text
         PFUser.currentUser()?["interested_in_business"] = businessSwitch.on
         PFUser.currentUser()?["interested_in_love"] = loveSwitch.on
         PFUser.currentUser()?["interested_in_friendship"] = friendshipSwitch.on
        }
        
    }
    @IBAction func friendshipSwitchTapped(sender: AnyObject) {
        if friendshipSwitch.on{
            friendshipLabel.textColor = UIColor.blackColor()
        }
        else{
            friendshipLabel.textColor = UIColor.grayColor()
        }
    }
    @IBAction func loveSwitchTapped(sender: AnyObject) {
        if loveSwitch.on{
            loveLable.textColor = UIColor.blackColor()
        }
        else{
          
            loveLable.textColor = UIColor.grayColor()
        }
    }
    
    @IBAction func businessSwitchTapped(sender: AnyObject) {
        if businessSwitch.on{
            businessLabel.textColor = UIColor.blackColor()
        }
        else{
            businessLabel.textColor = UIColor.grayColor()
        }
    }

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
        let mainProfilePicture = LocalData().getMainProfilePicture()
        if let mainProfilePicture = mainProfilePicture {
            let image = UIImage(data:mainProfilePicture,scale:1.0)
            profilePicture.image = image
        }
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        
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
        let updatedText = nameTextField.text
        if let updatedText = updatedText {
            let localData = LocalData()
            localData.setUsername(updatedText)
            localData.synchronize()
        }
        return true
    }

     override func viewDidAppear(animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
