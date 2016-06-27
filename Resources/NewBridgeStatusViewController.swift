//
//  NewBridgeStatusViewController.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
class NewBridgeStatusViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate, UITextFieldDelegate {
    var pickerSelected = false
    let pickerData = ["Friendship", "Love","Business"]
    var pickerRowSelected = 0
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var bridgeStatus: UITextField!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var bridgeTypePicker: UIPickerView!
    @IBAction func postButtonTapped(sender: AnyObject) {
        let query: PFQuery = PFQuery(className: "BridgeStatus")
        query.whereKey("userId", containsString: PFUser.currentUser()?.objectId)
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if let error = error {
                
                print(error)
                
            } else if let results = results {
                var noResultReturned = true
                for result in results{
                    noResultReturned = false
                    result["bridge_status"] = self.bridgeStatus.text!
                    result["bridge_type"] = self.pickerData[self.pickerRowSelected]
                    result.saveInBackground()
                }
                if noResultReturned {
                    let bridgeStatusObject = PFObject(className: "BridgeStatus")
                    bridgeStatusObject["bridge_status"] = self.bridgeStatus.text!
                    bridgeStatusObject["bridge_type"] = self.pickerData[self.pickerRowSelected]
                    bridgeStatusObject["userId"] = PFUser.currentUser()?.objectId
                    bridgeStatusObject.saveInBackground()
                    
                }
            }
            
        })
        self.dismissViewControllerAnimated(true, completion: nil)

        
    }
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        //navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelected = true
        pickerRowSelected = row
        if bridgeStatus.text! != "" {
            postButton.enabled = true
        }
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 140 
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if bridgeStatus.text! != "" && pickerSelected{
            postButton.enabled = true
        }
        return true
    }
    /*func textFieldDidEndEditing(textField: UITextField) {
        if bridgeStatus.text! != "" && pickerSelected{
            postButton.enabled = true
        }
    }*/
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        var myTitle = NSAttributedString()
        if row == 0{
            
         myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.backgroundColor = UIColor.init(red: 139.0/255, green: 217.0/255, blue: 176.0/255, alpha: 1.0)
        }
        else if row == 1{
            
             myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.backgroundColor = UIColor.init(red: 255.0/255, green: 129.0/255, blue: 125.0/255, alpha: 1.0)
        }
        else if row == 2{
            
            myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
            pickerLabel.backgroundColor = UIColor.init(red: 144.0/255, green: 207.0/255, blue: 214.0/255, alpha: 1.0)
        }
        else {
            myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        }



        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    /*func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }*/
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        bridgeTypePicker.delegate = self
        bridgeTypePicker.dataSource = self
        bridgeStatus.delegate = self
        let localData = LocalData()
        let mainProfilePicture = localData.getMainProfilePicture()
        if let mainProfilePicture = mainProfilePicture {
            let image = UIImage(data:mainProfilePicture,scale:1.0)
            profilePicture.image = image
        }
        if let name = localData.getUsername() {
            username.text = name
        }
        else {
            username.text = "A man continues to have no name"
        }
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        bridgeTypePicker.selectRow(2, inComponent: 0, animated: true)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
