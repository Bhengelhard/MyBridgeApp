//
//  LoadPageViewController.swift
//  MyBridgeApp
//
//  Created by Blake Engelhard on 5/10/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit

class LoadPageViewController: UIViewController {
    
    //right now just updates users Friends
    func updateUser() {
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "friends"])
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                
                print(error)
                
            } else if let result = result {
                
                let friends = result["friends"]! as! NSDictionary
                
                let friendsData : NSArray = friends.objectForKey("data") as! NSArray
                
                var fbFriendIds = [String]()
                
                for friend in friendsData {
                    
                    let valueDict : NSDictionary = friend as! NSDictionary
                    fbFriendIds.append(valueDict.objectForKey("id") as! String)
                    
                }
                
                
                PFUser.currentUser()?["fb_friends"] = fbFriendIds
                
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) in
                    
                    if error != nil {
                        
                        print(error)
                        
                    } else {
                        
                        self.updateFriendList()
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    func updateFriendList() {
        
        //add graph request to update users fb_friends
        //query to find and save fb_friends
        
        let currentUserFbFriends = PFUser.currentUser()!["fb_friends"] as! NSArray
        
        let query: PFQuery = PFQuery(className: "_User")
        
        query.whereKey("fb_id", containedIn: currentUserFbFriends as [AnyObject])
        
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            
            if error != nil {
                
                print(error)
                
            } else if let objects = objects {
                
                PFUser.currentUser()?.fetchInBackgroundWithBlock({ (success, error) in
                    
                    for object in objects {
                        
                        var containedInFriendList = false
                        
                        if let friendList: NSArray = PFUser.currentUser()!["friend_list"] as? NSArray {
                            
                            containedInFriendList = friendList.contains {$0 as! String == object.objectId!}
                            
                        }
                        
                        if containedInFriendList == false {
                            
                            if PFUser.currentUser()!["friend_list"] != nil {
                                
                                let currentFriendList = PFUser.currentUser()!["friend_list"]
                                PFUser.currentUser()!["friend_list"] = currentFriendList as! Array + [object.objectId!]
                                
                            } else {
                                
                                PFUser.currentUser()!["friend_list"] = [object.objectId!]
                                
                            }
                            
                        }
                        
                        PFUser.currentUser()?.saveInBackground()
                        
                    }
                    
                })
                
            }
            
        })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        /*PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) in
            
            if user != nil {
                
                print("user exists")
                
            } else {
                
                print("user does not exist")
                
            }
        })*/
        
        
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) in
            
            if object != nil {
                
                print("user exists")
                //updateFriendList()
                self.updateUser()
                self.performSegueWithIdentifier("showBridgeFromLoadPage", sender: self)
                
            } else {
                
                print("user does not exist")
                PFUser.logOut()
                //not yet logged in
                self.performSegueWithIdentifier("showLoginFromLoadPage", sender: self)
                
            }
            //print(error)
            
            
        })
        
        /*PFUser.currentUser()?.fetchInBackgroundWithBlock({ (success, error) in
            currentUser = PFUser.currentUser()?.username
            print(currentUser)
            
            if let username = PFUser.currentUser()?.username {
                
                print("user exists")
                
            } else {
                
                print("user does not exist")
                
            }
            
        })*/
        
        
        //Check if User exists and if not then segue to login page
        
        /*let accessToken = PFUser.currentUser()!["authData/Facebook/accessToken"]
        
        PFFacebookUtils.logInInBackgroundWithAccessToken(accessToken, block: {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("User logged in through Facebook!")
            } else {
                print("Uh oh. There was an error logging in.")
            }
        })*/
        
        
       /* //PFUser.logOut()
        PFUser.logInWithUsernameInBackground((PFUser.currentUser()?.username)!, password: (PFUser.currentUser()?.password)!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                //updateFriendList()
                updateUser()
                performSegueWithIdentifier("showBridgeFromLoadPage", sender: self)

            } else {
                
                performSegueWithIdentifier("showLoginFromLoadPage", sender: self)
                
            }
        }*/

        
        
       /* if PFUser.currentUser()?.username != nil {
            print(PFUser.currentUser()?.username)
            //updateFriendList()
            updateUser()
            performSegueWithIdentifier("showBridgeFromLoadPage", sender: self)
            print("Went to bridge from Load Page")
            
        } else {
            
            //not yet logged in
            performSegueWithIdentifier("showLoginFromLoadPage", sender: self)
            
            
            
        }*/
        
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
