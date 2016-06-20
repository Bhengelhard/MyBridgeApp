import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit
import CoreData

//var user1 = PFUser()
//var currentUser = PFUser.currentUser()

class ViewController: UIViewController {
   

    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBAction func fbLogin(sender: AnyObject) {
        print("pressed")
        // Spinner sparts animating before the segue can be accesses
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        var global_name:String = ""
        
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
                    // Common to new and old user
                    
                    LocalStorageUtility().getUserFriends()
                    LocalStorageUtility().getMainProfilePicture()
                    
                    // Testing the localData
                   /* let localData = LocalData()
                    let pairings = localData.getPairings()
                    print("\(pairings![0].user1?.name) and \(pairings![0].user2?.name)")*/
                    if user.isNew {
                        
                        print("got to new user")
                        let localData = LocalData()
                        
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
                                    
                                    localData.setInterestedIN(interested_in as! String)
                                    PFUser.currentUser()?["interested_in"] = interested_in
                                }
                                
                                if let gender: String = result["gender"]! as? String {
                                    
                                    PFUser.currentUser()?["gender"] = gender
                                    PFUser.currentUser()?["fb_gender"] = gender
                                    //saves a guess at the gender the current user is interested in if it doesn't already exist
                                if result["interested_in"]! == nil {
                                    
                                    if gender == "male" {
                                        
                                        PFUser.currentUser()?["interested_in"] = "female"
                                        
                                    } else if gender == "female" {
                                            
                                        PFUser.currentUser()?["interested_in"] = "male"
                                    }
                                        
                                }
                                    
                                    
                                }
                                
                                //setting main name and names for Bridge Types to Facebook name
                                if let name = result["name"]! {
                                    // Store the name in core data 06/09
                                    
                                    global_name = name as! String
                                    localData.setUsername(global_name)
                                    PFUser.currentUser()?["fb_name"] = name
                                    PFUser.currentUser()?["name"] = name
                                    PFUser.currentUser()?["business_name"] = name
                                    PFUser.currentUser()?["love_name"] = name
                                    PFUser.currentUser()?["friendship_name"] = name
                                                                       
                                }
                                
                                if let email = result["email"]! {
                                    
                                    PFUser.currentUser()?["email"] = email
                                }
                                
                                if let id = result["id"]! {
                                    
                                    PFUser.currentUser()?["fb_id"] =  id
                                    
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
                                localData.setNewMessagesPushNotifications(true)
                                PFUser.currentUser()?["new_bridge_push_notifications"] = true
                                localData.setNewBridgesPushNotifications(true)
                                PFUser.currentUser()?["built_bridges"] = []
                                PFUser.currentUser()?["rejected_bridges"] = []
                               

                                PFUser.currentUser()?.saveInBackground()
                               
                                LocalStorageUtility().getBridgePairings()
                                localData.synchronize()
                                
                                
                                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) in
                                    
                                    if success == true {
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        self.performSegueWithIdentifier("showSignUp", sender: self)
                                        
                                    } else {
                                        
                                        print(error)
                                        
                                    }
                                    
                                })

                                
                                
                            }
                            
                            
                        }
                        
                        
                        
                        //self.updateUser()
                        
                        //print("new")
                        //self.getUserPhotos()
                        
                    } else {
                        //spinner
                        //update user and friends
                        
                        //use while access token is nil instead of delay
                         print("not new")
                        LocalStorageUtility().getBridgePairings()
                         //self.getUserPhotos()
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                            //stop the spinner animation and reactivate the interaction with user
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            
                            self.performSegueWithIdentifier("showBridgeViewController", sender: self)
                         })
                    }
                    
                    
                    
                }
            }
        }
        
    }
    
    func seedUsers(){
        print("seedUsers method called")
        let moc = DataController().managedObjectContext
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: moc) as! Users
        entity.setValue("Udta Punjab", forKey: "name")
        entity.setValue("/home/picture", forKey: "profilePicture")
        do{
            try moc.save()
        }
        catch {
            fatalError("failure to save context:\(error)")
            
        }
    }
    func fetchUsers(){
        print("fetchUsers method called")
        let moc = DataController().managedObjectContext
        let userFetch = NSFetchRequest(entityName: "Users")
        do {
            let fetchUser = try moc.executeFetchRequest(userFetch) as! [Users]
            print(fetchUser.first!.name)
            
        }
        catch{
            fatalError("failure to fetch user: \(error)")
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

