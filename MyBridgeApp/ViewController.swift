import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit

//var user1 = PFUser()
//var currentUser = PFUser.currentUser()

class ViewController: UIViewController {

    @IBAction func fbLogin(sender: AnyObject) {
        
        //Log user in with permissions public_profile, email and user_friends
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user, error) in
            if let error = error {
                print(error)
            } else {
                if let user = user {
                    //getting user information from Facebook and saving to Parse
                    //Current Fields Saved: name, gender, fb_profile_picture
                    //**Need to add check for if fields exist**
                    let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender, email, friends"])
                    graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
                        if error != nil {
                            
                            print(error)
                    
                        } else if let result = result {
                            // saves these to parse at every login
                            PFUser.currentUser()?["gender"] = result["gender"]!
                            PFUser.currentUser()?["name"] = result["name"]!
                            PFUser.currentUser()?["email"] = result["email"]!
                            PFUser.currentUser()?["fb_id"] = result["id"]!
                            
                            //adding facebook friend data to parse - returns name and id
                            var friends = result["friends"]! as! NSDictionary
                            
                            var friendsData : NSArray = friends.objectForKey("data") as! NSArray
                            
                            var fbFriendIds = [String]()
                            
                            for friend in friendsData {
                                
                                let valueDict : NSDictionary = friend as! NSDictionary
                                fbFriendIds.append(valueDict.objectForKey("id") as! String)
                                
                            }
                            
                            
                            PFUser.currentUser()?["fb_friends"] = fbFriendIds
                            
                            PFUser.currentUser()?.saveInBackground()
                        
                            //search through users for where fb id matches and then add object id to both users friend_list
                            //have to check if the user has friends or else will get an error
                            //print(result["friends"]!)
                            /*if let userFriends = result["friends"]! {
                                
                                PFUser.currentUser()?["fb_friends"] = userFriends
                                
                            }*/
                            
                            
                            let userId = result["id"]! as! String
                            
                            let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                            
                            if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                                
                                if let data = NSData(contentsOfURL: fbpicUrl) {
                                    
                                    let imageFile: PFFile = PFFile(data: data)!
                                    
                                    PFUser.currentUser()?["fb_profile_picture"] = imageFile
                                    
                                    PFUser.currentUser()?.saveInBackground()
                                    
                                }
                                
                            }
                        }
                    }
                    
                    self.updateFriendList()
                    self.performSegueWithIdentifier("showBridgeViewController", sender: self)

                }
            }
        }
        
    }

    //right now just updates users Friends
    func updateUser() {
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "friends"])
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
                
                print(error)
                
            } else if let result = result {
                
                var friends = result["friends"]! as! NSDictionary
                
                var friendsData : NSArray = friends.objectForKey("data") as! NSArray
                
                var fbFriendIds = [String]()
                
                for friend in friendsData {
                    
                    let valueDict : NSDictionary = friend as! NSDictionary
                    fbFriendIds.append(valueDict.objectForKey("id") as! String)
                    
                }
                
                
                PFUser.currentUser()?["fb_friends"] = fbFriendIds
                
                PFUser.currentUser()?.saveInBackground()
                
            }
        
        }
        
    }
    
    func updateFriendList() {
        
        //add graph request to update users fb_friends
        //query to find and save fb_friends
        
        var currentUserFbFriends = PFUser.currentUser()!["fb_friends"] as! NSArray
        
        var query: PFQuery = PFQuery(className: "_User")
        
        query.whereKey("fb_id", containedIn: currentUserFbFriends as [AnyObject])
        
        query.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) in
            
            if error != nil {
                
                print(error)
                
            } else if let objects = objects {
                
                print("objects")
                
                for object in objects {
                    
                    var containedInFriendList = false
                    
                    if let friendList: NSArray = PFUser.currentUser()!["friend_list"] as! NSArray {
                        
                        print(friendList)
                        
                        containedInFriendList = friendList.contains {$0 as! String == object.objectId!}
                        
                    }
                    print(object.objectId)
                    print(containedInFriendList)
                    
                    if containedInFriendList == false {
                        
                        if PFUser.currentUser()!["friend_list"] != nil {
                            
                            let currentFriendList = PFUser.currentUser()!["friend_list"]
                            PFUser.currentUser()!["friend_list"] = currentFriendList as! Array + [object.objectId!]

                        } else {
                            
                            PFUser.currentUser()!["friend_list"] = [object.objectId!]
                            
                        }
                        
                    }
                    
                }
                
                PFUser.currentUser()?.saveInBackground()
            }
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        //PFUser.logOut()
        
        if let username = PFUser.currentUser()?.username{
            
            updateFriendList()
            //updateUser()
            performSegueWithIdentifier("showBridgeViewController", sender: self)
            
        } else {
            
            //not yet logged in
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}



//Notes

//Parse
//Saving to the Database
/*let testObject = PFObject(className: "TestObject")
 testObject["foo"] = "bar"
 testObject.saveInBackgroundWithBlock { (success, error) -> Void in
 print("Object has been saved.")
 }
 */


//Facebook
//Facebook Login Button
/*var FBLoginButton = FBSDKLoginButton()
FBLoginButton.readPermissions = ["public_profile"]
FBLoginButton.center = self.view.center
//FBLoginButton.delegate = self
self.view.addSubview(FBLoginButton)
*/

/*func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
 
 if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString {
 //print(accessToken)
 } else {
 print("Logged in! ")
 let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender"])
 graphRequest.startWithCompletionHandler( { (connection, result, error) -> Void in
 if error != nil {
 print(error)
 } else if let result = result {
 if let userLocation = result["location"] as? String {
 //save location
 }
 } else {
 print("Canceled")
 }
 })
 }
 }*/


/*func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
 print("User logged out...")
 }*/

//checking if user is initially logged in
/*if (FBSDKAccessToken.currentAccessToken() == nil) {
 print("Not logged in")
 } else {
 print("logged in")
 //print(PFUser.currentUser())
 //performSegueWithIdentifier("showApp", sender: self)
 }*/

