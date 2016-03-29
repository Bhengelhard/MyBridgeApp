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
                                    
                                    let imageFile: PFFile = PFFile(data: data)!
                                    
                                    PFUser.currentUser()?["fb_profile_picture"] = imageFile
                                    
                                    PFUser.currentUser()?.saveInBackground()
                                    
                                }
                                
                            }
                        }
                    }
                    self.performSegueWithIdentifier("showSigninScreen", sender: self)
                    print(user)
                }
            }
        }
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        //PFUser.logOut()
        
        if let username = PFUser.currentUser()?.username{
            
            
            performSegueWithIdentifier("showBridgeViewController", sender: self)
            
        } else {
            print("not yet logged in")
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

