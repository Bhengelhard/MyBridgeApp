import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit
import CoreData

//var user1 = PFUser()
//var currentUser = PFUser.currentUser()

class ViewController: UIViewController {

    @IBAction func fbLogin(sender: AnyObject) {
        print("pressed")
        
        /*let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context)
        */
        
        
        //Log user in with permissions public_profile, email and user_friends
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) { (user, error) in
            
            print("got past permissions")
            if let error = error {
                print(error)
                print("got to error")
            } else {
                if let user = user {
                    print("got user") 
                    //getting user information from Facebook and saving to Parse
                    //Current Fields Saved: name, gender, fb_profile_picture
                    //**Need to add check for if fields exist**
                    
                    if user.isNew {
                        print("got to new user")
                        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, interested_in, name, gender, email, friends, birthday, location"])
                        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
                            print("got into graph request")
                            if error != nil {
                                
                                print(error)
                                print("got error")
                                
                            } else if let result = result {
                                // saves these to parse at every login
                                print("got result")
                                if let interested_in = result["interested_in"]! {
                                    
                                    PFUser.currentUser()?["interested_in"] = interested_in
                                    //newUser.setValue(interested_in, forKey: "interested_in")
                                    print("interested_in")
                                    
                                }
                                
                                if let gender: String = result["gender"]! as? String {
                                    
                                    PFUser.currentUser()?["gender"] = gender
                                    //newUser.setValue(gender, forKey: "gender")
                                    
                                    //saves a guess at the gender the current user is interested in if it doesn't already exist
                                    if result["interested_in"]! == nil {
                                        
                                        if gender == "male" {
                                            
                                            PFUser.currentUser()?["interested_in"] = "female"
                                            //newUser.setValue("female", forKey: "interested_in")
                                            
                                        } else if gender == "female" {
                                            
                                            PFUser.currentUser()?["interested_in"] = "male"
                                            //newUser.setValue("Male", forKey: "interested_in")
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                //setting main name and names for Bridge Types to Facebook name
                                if let name = result["name"]! {
                                    
                                    PFUser.currentUser()?["fb_name"] = name
                                    PFUser.currentUser()?["business_name"] = name
                                    PFUser.currentUser()?["love_name"] = name
                                    PFUser.currentUser()?["friendship_name"] = name
                                    /*newUser.setValue(name, forKey: "fb_name")
                                    newUser.setValue(name, forKey: "business_name")
                                    newUser.setValue(name, forKey: "love_name")
                                    newUser.setValue(name, forKey: "friendship_name")*/
                                    
                                }
                                
                                if let email = result["email"]! {
                                    
                                    PFUser.currentUser()?["email"] = email
                                    //newUser.setValue(email, forKey: "email")
                                    
                                }
                                
                                if let id = result["id"]! {
                                    
                                    PFUser.currentUser()?["fb_id"] =  id
                                    //newUser.setValue(id, forKey: "fb_id")
                                    
                                }
                                
                                if let birthday = result["birthday"]! {
                                    
                                    print(result["birthday"]!)
                                    print("birthday")
                                    //getting birthday from Facebook and calculating age
                                    PFUser.currentUser()?["fb_birthday"] = birthday
                                    //newUser.setValue(birthday, forKey: "fb_birthday")
                                    let NSbirthday: NSDate = birthday as! NSDate
                                    let calendar: NSCalendar = NSCalendar.currentCalendar()
                                    let now = NSDate()
                                    let age = calendar.components(.Year, fromDate: NSbirthday, toDate: now, options: [])
                                    
                                    print(age)
                                    
                                    PFUser.currentUser()?["age"] = age
                                    //newUser.setValue(age, forKey: "age")
                                    
                                }
                                
                                if let location = result["location"]! {
                                    print("location")
                                    PFUser.currentUser()?["fb_location"] = location
                                    //newUser.setValue(location[0], forKey: "longitude")
                                    //newUser.setValue(location[1], forKey: "latitude")
                                    
                                }
                                
                                PFUser.currentUser()?["distance_interest"] = 100
                                PFUser.currentUser()?["new_message_push_notifications"] = true
                                PFUser.currentUser()?["new_bridge_push_notifications"] = true
                                /*newUser.setValue(100, forKey: "distance_interest")
                                newUser.setValue(true, forKey: "new_message_push_notifications")
                                newUser.setValue(true, forKey: "new_message_push_notifications")*/
                                
                                //initializing built_bridges and rejected_bridges
                                PFUser.currentUser()?["built_bridges"] = []
                                PFUser.currentUser()?["rejected_bridges"] = []
                                /*newUser.setValue([], forKey: "built_bridges")
                                newUser.setValue([], forKey: "rejected_bridges")*/
                                
                                //adding facebook friend data to parse - returns name and id
                                /*var friends = result["friends"]! as! NSDictionary
                                 
                                 var friendsData : NSArray = friends.objectForKey("data") as! NSArray
                                 
                                 var fbFriendIds = [String]()
                                 
                                 for friend in friendsData {
                                 
                                 let valueDict : NSDictionary = friend as! NSDictionary
                                 fbFriendIds.append(valueDict.objectForKey("id") as! String)
                                 
                                 }
                                 
                                 
                                 PFUser.currentUser()?["fb_friends"] = fbFriendIds
                                 */
                                
                                //saving PFUser details
                                /*newUser.setValue(PFUser.currentUser()?.objectId, forKey: "objectId")
                                newUser.setValue(PFUser.currentUser()?.username, forKey: "username")
                                newUser.setValue(PFUser.currentUser()?.password, forKey: "password")*/
                               
                                //saves Core Data
                                /*do {
                                    
                                    try context.save()
                                    
                                } catch {
                                    
                                    print("There was a problem saving the Core Data")
                                    
                                }*/

                                
                                PFUser.currentUser()?.saveInBackground()
                                
                                //get facebook profile picture
                                let userId = result["id"]! as! String
                                
                                let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                                print(facebookProfilePictureUrl)
                                if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                                    print("go into URL")
                                    
                                    if let data = NSData(contentsOfURL: fbpicUrl) {
                                        
                                        print("got into Data")
                                        let imageFile: PFFile = PFFile(data: data)!
                                        print(imageFile)
                                        //setting main profile pictures
                                        PFUser.currentUser()?["fb_profile_picture"] = imageFile
                                        PFUser.currentUser()?["main_business_profile_picture"] = imageFile
                                        PFUser.currentUser()?["main_love_profile_picture"] = imageFile
                                        PFUser.currentUser()?["main_friendship_profile_picture"] = imageFile
                                        
                                        //setting profile pictures as facebook pictures to true
                                        PFUser.currentUser()?["fb_profile_picture_for_business"] = true
                                        PFUser.currentUser()?["fb_profile_picture_for_love"] = true
                                        PFUser.currentUser()?["fb_profile_picture_for_friendship"] = true
 
                                        
                                        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) in
                                            
                                            if success == true {
                                                
                                                self.performSegueWithIdentifier("showSignUp", sender: self)
                                                
                                            } else {
                                                
                                                print(error)
                                                
                                            }
                                            
                                        })
                                        
                                    }
                                    print("past bracket 1")
                                }
                                print("past bracket 2")
                                
                                
                            }
                            
                            
                        }
                        
                        
                        
                        //self.updateUser()
                        
                        print("new")
                        
                    } else {
                        
                        print("not new")
                        self.performSegueWithIdentifier("showBridgeViewController", sender: self)
                        
                    }
                    
                    
                    
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
                
                if let friends = result["friends"]! as? NSDictionary {
                    
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
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        //PFUser.logOut()
        
        /*PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object, error) in
            
            if object != nil {
                
                //updateFriendList()
                //self.updateUser()
                performSegueWithIdentifier("showBridgeViewController", sender: self)
                
            } else {
                
                //not yet logged in
                
            }
            
        })*/
        
        /*if let username = PFUser.currentUser()?.username{
            
            //updateFriendList()
            updateUser()
            //performSegueWithIdentifier("showBridgeViewController", sender: self)
            
        } else {
            
            //not yet logged in
            
        }*/
        
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

