//
//  SignUpViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Blake Engelhard on 3/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
//import ParseFacebookUtilsV4
//import ParseUI


class SignUpViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //getting user information from Facebook and saving to Parse
        //Current Fields Saved: name, gender, fb_profile_picture
        //**Need to add check for if fields exist**
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender"])
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                
                print(error)
                
            } else if let result = result {
                
                PFUser.currentUser()?["gender"] = result["gender"]!
                PFUser.currentUser()?["name"] = result["name"]!
                
                PFUser.currentUser()?.saveInBackground()

                let userId = result["id"]! as! String

                let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"

                if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                    
                    if let data = NSData(contentsOfURL: fbpicUrl) {
                        
                        self.userImage.image = UIImage(data: data)
                        
                        let imageFile: PFFile = PFFile(data: data)!
                        
                        PFUser.currentUser()?["fb_profile_picture"] = imageFile
                        
                        PFUser.currentUser()?.saveInBackground()
                        
                    }
                    
                }
            }
        }


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
