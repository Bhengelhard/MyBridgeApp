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

class SignupViewController:UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var main_title: UILabel!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var friendshipLabel: UILabel!
    @IBOutlet weak var loveLable: UILabel!
    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var businessSwitch: UISwitch!
    @IBOutlet weak var friendshipSwitch: UISwitch!
    @IBOutlet weak var loveSwitch: UISwitch!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    // globally required as we do not want to re-create them everytime and for persistence
    let imagePicker = UIImagePickerController()
    var editableName:String = ""
    
    
    @IBAction func editImageTapped(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    //update the UIImageView once an image has been picked
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = pickedImage
            profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
            profilePicture.clipsToBounds = true
            if let imageData = UIImagePNGRepresentation(pickedImage){
            let localData = LocalData()
            localData.setMainProfilePicture(imageData)
            localData.synchronize()
            }

        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // Begin Bridging Button Clicked
    @IBAction func beginBridgingTouched(sender: AnyObject) {
        if let _ = PFUser.currentUser() {
         PFUser.currentUser()?["name"] = editableName
         PFUser.currentUser()?["interested_in_business"] = businessSwitch.on
         PFUser.currentUser()?["interested_in_love"] = loveSwitch.on
         PFUser.currentUser()?["interested_in_friendship"] = friendshipSwitch.on
        }
        
    }
    // Switches tapped
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
        imagePicker.delegate = self
        nameTextField.delegate = self
        
        let username = LocalData().getUsername()
        
        if let username = username {
                editableName = username
                nameTextField.text = username
        }
        else{
            editableName = "A man has no name!"
            nameTextField.text = "A man has no name!"
        }
        main_title.attributedText = twoColoredString(editableName+"'s interests")
        nameTextField.hidden = true
        interestLabel.hidden = true
        main_title.userInteractionEnabled = true
        
        
        let aSelector : Selector = #selector(SignupViewController.lblTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        main_title.addGestureRecognizer(tapGesture)
        
        let outSelector : Selector = #selector(SignupViewController.tappedOutside)
        let outsideTapGesture = UITapGestureRecognizer(target: self, action: outSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(outsideTapGesture)
        
        let mainProfilePicture = LocalData().getMainProfilePicture()
        if let mainProfilePicture = mainProfilePicture {
            let image = UIImage(data:mainProfilePicture,scale:1.0)
            profilePicture.image = image
        }
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        
    }
    // Utility functions
    // generate a 2-colored string. Used for the title
    func twoColoredString(s:String)->NSMutableAttributedString{
        let mutableString = NSMutableAttributedString(string: s)
        mutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location:s.characters.count-12, length:12))
        return mutableString
        
    }
    // Username label is tapped. Textfield should appear and replace the label
    func lblTapped(){
        main_title.hidden = true
        nameTextField.hidden = false
        interestLabel.hidden = false
        nameTextField.text = editableName
    }
    // Tapped anywhere else on the main view. Textfield should be replaced by label
    func tappedOutside(){
        main_title.hidden = false
        nameTextField.hidden = true
        interestLabel.hidden = true
        if let editableNameTemp = nameTextField.text{
            main_title.attributedText = twoColoredString(editableNameTemp+"'s interests")
            editableName = editableNameTemp
        }
        let updatedText = nameTextField.text
        if let updatedText = updatedText {
            let localData = LocalData()
            localData.setUsername(updatedText)
            localData.synchronize()
        }

    }
    // User returns after editing
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        nameTextField.hidden = true
        interestLabel.hidden = true
        main_title.hidden = false
        if let editableNameTemp = nameTextField.text{
        main_title.attributedText = twoColoredString(editableNameTemp+"'s interests")
        editableName = editableNameTemp
        }
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
