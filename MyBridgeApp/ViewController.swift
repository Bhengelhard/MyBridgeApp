import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit
import CoreData

//var user1 = PFUser()
//var currentUser = PFUser.currentUser()

class ViewController: UIViewController {
   
    
    func getUserPhotos(){
        // Need to be worked upon after we get permission 
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        graphRequest.startWithCompletionHandler{ (connection, result, error) -> Void in
            print(" graph request")
            if error != nil {
                
                print(error)
                print("got error")
                
            } else if let result = result {
                print("got result")
                let userId = result["id"]! as! String
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                let facebookProfilePictureUrl = "https://graph.facebook.com/\(userId)/albums?access_token=\(accessToken)"
                if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                    print(fbpicUrl)
                    if let data = NSData(contentsOfURL: fbpicUrl) {
                        var error: NSError?
                        do{
                        var albumsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        print(albumsDictionary["data"]!)
                        }
                        catch{
                            print(error)
                        }
                    }
                    
                }
                
            }
            
            
        }
    }
    
    func getUserFriends(){
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        graphRequest.startWithCompletionHandler{ (connection, result, error) -> Void in
            if error != nil {
                print(print("Error: \(error!) \(error!.userInfo)"))
            }
            else if let result = result {
                let userId = result["id"]! as! String
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let facebookFriendsUrl = "https://graph.facebook.com/\(userId)/friends?access_token=\(accessToken)"
                
                if let fbfriendsUrl = NSURL(string: facebookFriendsUrl) {
                    
                    if let data = NSData(contentsOfURL: fbfriendsUrl) {
                    //background thread to parse the JSON data
                        
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        do{
                            let friendList: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            
                            if let data = friendList["data"] as? [[String: AnyObject]] {
                                var friendsArray:[String] = []
                                for item in data {
                                    if let name = item["name"] as? String {
                                        if let id = item["id"] as? String {
                                            
                                            print("\(name)'s id is \(id)")
                                            let query = PFQuery(className:"_User")
                                            query.whereKey("fb_id", equalTo:id)
                                            let objects = try query.findObjects()
                                            for object in objects {
                                                friendsArray.append(object.objectId!)
                                            }
                                                
                                        }
                                        else {
                                            print("Error: \(error!) \(error!.userInfo)")
                                        }
                                        
                                    }
                                }
                                //Update Parse DB to store the friendlist
                                
                                PFUser.currentUser()?["fb_friends"] = friendsArray
                                PFUser.currentUser()?["friend_list"] = friendsArray
                                
                                //Update Iphone's local storage to store the friendlist
                                let localData = LocalData()
                                localData.setFriendList(friendsArray)
                                localData.synchronize()
                                print("friends array -\(friendsArray)")
                            }
                          
                        }
                        catch  {
                            print(error)
                        }
                        }
                        
                    }
                }
            }
        }
    }


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
        //fetchUsers()
        
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
                    
                    self.getUserFriends()
                    
                   
                    
                    if user.isNew {
                        
                        print("got to new user")
                                                // Initialization  for coreData 06/09
                        
                        let moc = DataController().managedObjectContext
                        let entity = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: moc) as! Users
                        // end of this initialization
                        
                        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, interested_in, name, gender, email, friends, birthday, location"])
                        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
                            print("got into graph request")
                            var unarchivedNSCodingUsers:NSArray
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
                                    // Store the name in core data 06/09
                                    print("setting NSCoding name")
                                    global_name = name as! String
                    
                                    entity.setValue(global_name, forKey: "name")
                                    PFUser.currentUser()?["fb_name"] = name
                                    PFUser.currentUser()?["name"] = name
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
                                         // Store the name in core data 06/09
                                        entity.setValue(data, forKey: "profilePicture")
                                        
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
                                
                                
                                //Attemt to save the data first and then fetch it from the core-data  06/09
                                
                                do{
                                    try moc.save()
                                }
                                catch {
                                    fatalError("failure to save context:\(error)")
                                    
                                }
                                print("fetchUsers method called")
                                                                // Now lets unarchive the data and put it into a different array to verify
                                // that this all works. Unarchive the objects and put them in a new array
                               
                                let moc2 = DataController().managedObjectContext
                                let request = NSFetchRequest(entityName: "Users")
                                request.returnsObjectsAsFaults = false
                                request.predicate = NSPredicate(format: "name = %@", global_name)
                                do {
                                    var results:NSArray = try moc2.executeFetchRequest(request)
                                    if results.count > 0{
                                        print("results found")
                                        for user in results{
                                            var thisUser = user as! Users
                                            print(thisUser)
                                        }
                                        
                                    }else {
                                        print("No elements")
                                    }
                                    
                                }
                                catch {
                                    
                                }

                                // end of the this attempt
                                
                            }
                            
                            
                        }
                        
                        
                        
                        //self.updateUser()
                        
                        print("new")
                         //self.getUserPhotos()
                        
                    } else {
                        //spinner
                        //update user and friends
                        
                        //use while access token is nil instead of delay
                         print("not new")
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

