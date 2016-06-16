import UIKit
import Parse
import FBSDKCoreKit

var previousViewController = String()

class BridgeViewController: UIViewController {
    
    var timer = NSTimer()
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var secondUserImage: UIImageView!
    
    //make arrays
    var userId1 = ""
    var userId2 = ""
    var firstUpdatedImage = true
    
    @IBOutlet weak var rejectOrBridgeLabel: UILabel!
    @IBOutlet weak var displayedUserName1: UILabel!
    @IBOutlet weak var displayedUserName2: UILabel!
    
    //Need to fix ignoredUsers to not reiterate through different users and to add the correct people**
    /*var ignoredUsers = [String]()
    var currentUserAdded = 0
     
    var friendCombinations = [[String]]()*/
    
    @IBAction func bridgeButton(sender: AnyObject) {
        
        previousViewController = "BridgeViewController"
        
        let bridgeBuiltorRejected = "built_bridges"
        
        let message = PFObject(className: "Messages")
        
        let currentUserId = PFUser.currentUser()?.objectId
        
        //Need to check for Bridge type to assign name
        
        //**if BridgeType = love {} else if BridgeType = business {} else if bridgeType = friendship {}
        let currentUserName = PFUser.currentUser()?["love_name"]
        
        message["names_in_message"] = [displayedUserName1.text!, displayedUserName2.text!, currentUserName!]
        message["ids_in_message"] = [userId1, userId2, currentUserId!]
        message["bridge_builder"] = currentUserId
        
        message.saveInBackgroundWithBlock({ (success, error) in
            
            print("message saved")
            messageId = message.objectId!
            
        })
        
        //messageId = message.objectId!
        
        singleMessageTitle = "\(displayedUserName1.text!) & \(displayedUserName2.text!)"
        
        //message.save
        
        print("built")
        
        //animation when bridge is built
        UIView.animateWithDuration(1) {
        
            self.userImage.center = CGPointMake(self.userImage.center.x + 400, self.userImage.center.y*2)
            self.secondUserImage.center = CGPointMake(self.secondUserImage.center.x + 400, self.secondUserImage.center.y/2)
            //self.displayedUserName1.center = CGPointMake(self.userImage.center.x + 400, self.userImage.center.y*2)
            //self.displayedUserName2.center = CGPointMake(self.userImage.center.x + 400, self.userImage.center.y/2)
            

        }
        
        if bridgeBuiltorRejected != "" {
            
            //error checking
            //change or's and second users
            
            if let previousBridges = (PFUser.currentUser()?[bridgeBuiltorRejected]) as? [[String]] {
                
                let newBridges = previousBridges + [[userId1, userId2]]
                PFUser.currentUser()?[bridgeBuiltorRejected] = newBridges
                PFUser.currentUser()?.saveInBackground()
                
            }
            
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("segueToSingleMessage"), userInfo: nil, repeats: false)
        
        
        
    }
    
    func segueToSingleMessage() {
        
        self.performSegueWithIdentifier("showSingleMessage", sender: self)

        
    }
    @IBAction func rejectButton(sender: AnyObject) {
        
        let bridgeBuiltorRejected = "rejected_bridges"
        
        print("rejected")
        
        //animation when bridge is rejected
        UIView.animateWithDuration(1) { 
            
            self.userImage.center = CGPointMake(self.userImage.center.x - 400, self.userImage.center.y)
            self.secondUserImage.center = CGPointMake(self.secondUserImage.center.x - 400, self.secondUserImage.center.y)
            //self.displayedUserName1.center = CGPointMake(self.userImage.center.x - 400, self.userImage.center.y)
            //self.displayedUserName2.center = CGPointMake(self.userImage.center.x - 400, self.userImage.center.y)

        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("updateImage"), userInfo: nil, repeats: false)
        //updateImage()
        
        if bridgeBuiltorRejected != "" {
            
            //error checking
            //change or's and second users
            
            if let previousBridges = (PFUser.currentUser()?[bridgeBuiltorRejected]) as? [[String]] {
                
                let newBridges = previousBridges + [[userId1, userId2]]
                PFUser.currentUser()?[bridgeBuiltorRejected] = newBridges
                PFUser.currentUser()?.saveInBackground()
                
            }
            
        }
        
    }
    @IBAction func segueToProfile(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    func updateImage() {
        
        //making the images appear back in the center
       // self.userImage.center = CGPointMake(self.userImage.center.x - 400, self.userImage.center.y)
        //self.secondUserImage.center = CGPointMake(self.secondUserImage.center.x - 400, self.secondUserImage.center.y)
        
        userImage.userInteractionEnabled = false
        
        var ignoredPairings = [[String]]()
        
        if let builtBridges = PFUser.currentUser()?["built_bridges"] {
            
            let builtBridges2 = builtBridges as! [[String]]
            
            ignoredPairings = ignoredPairings + builtBridges2
            
        }
        
        if let rejectedBridges = PFUser.currentUser()?["rejected_bridges"] {
            
            let rejectedBridges2 = rejectedBridges as! [[String]]
            
            ignoredPairings = ignoredPairings + rejectedBridges2
            
        }
        
        var friendPairings = [String]()
        
        
        if let friendList = PFUser.currentUser()?["friend_list"] as? [String] {
            
            //while friendpairings.count <4
            
            //currentlyDisplayedUsers = [self.userId1, self.userId2]
            
            for friend1 in friendList {
                
                for friend2 in friendList {
                    
                    let containedInIgnoredPairings = ignoredPairings.contains {$0 == [friend1, friend2]} || ignoredPairings.contains {$0 == [friend2, friend1]}
                    
                    let notPreviouslyDisplayedUser = friend1 != self.userId1 && friend2 != self.userId1 && friend1 != self.userId2 && friend2 != self.userId2
                    
                    //add geographic vetting
                    
                    if notPreviouslyDisplayedUser && friend1 != friend2 && containedInIgnoredPairings == false /*&& friendPairings.count < 5*/ {
                        
                        
                        friendPairings = [friend1,friend2]
                        
                        self.userId1 = friend1
                        self.userId2 = friend2
                        
                        break

                    }
                    
                }
                
                if friendPairings.count != 0 {
                    
                    break
                    
                }
                
            }
            
        }
        
        /*if last pairing in database {
            //disable swipe
            //show missing image images
            rejectOrBridgeLabel.textColor = UIColor.blackColor()
            rejectOrBridgeLabel.text = "Sorry, there are more bridges to be built at this time. Try again later!"
            print("no more pairings")
            
        }*/
        
        var isDisplayedUser1 = true
        let query: PFQuery = PFQuery(className: "_User")
        
        query.whereKey("objectId", containedIn: friendPairings)
        query.limit = 2
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            
            if error != nil {
                
                print(error)
                
            } else if let objects = objects {
                
                for object in objects {
                    
                    let imageFile = object["fb_profile_picture"] as! PFFile
                    
                    imageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) in
                        
                        if error != nil {
                            
                            print(error)
                            
                        } else if isDisplayedUser1 == true {
                            
                            if let data = imageData {
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    self.displayedUserName1.text = "Yahoo"// object["name"] as! String
                                    self.userImage.image = UIImage(data: data)
                                    
                                })
                                
                            }
                            
                            isDisplayedUser1 = false
                            
                        } else {
                            
                            if let data = imageData {
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    self.displayedUserName2.text = "Google"//object["name"] as! String
                                    self.secondUserImage.image = UIImage(data: data)
                                    
                                    self.userImage.userInteractionEnabled = true
                                    self.rejectOrBridgeLabel.text = ""
                                    
                                })
                                
                                //friendPairings = [String]()
                                //print(friendPairings)
                                
                            }
                            
                        }
                        
                    })
                    
                }
                
            }
            
        }
        
        
        
        
        /*
         
        query.whereKey("objectId", notContainedIn: ignoredUsers)
        
        //Querying based on Geolocation boundary - Querying based on who's closest is shown in Uber Udemy tutorial
        
        if let latitude = PFUser.currentUser()?["location"]!.latitude {
            
            if let longitude = PFUser.currentUser()?["location"]!.longitude {
                
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1, longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1, longitude: longitude + 1))
                
            }
            
            
        }
 
 
        
*/
        
    }
 
    func wasDragged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translationInView(self.view)
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        let scale = min(100 / abs(xFromCenter), 1)
        
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
        
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        label.transform = stretch
        
        if label.center.x < view.center.x - 5 {
            
            rejectOrBridgeLabel.text = "reject"
            rejectOrBridgeLabel.textColor = UIColor.redColor()
            
        } else if label.center.x > view.center.x + 5 {
            
            rejectOrBridgeLabel.text = "Bridge"
            rejectOrBridgeLabel.textColor = UIColor.greenColor()
            
        } else {
            
            rejectOrBridgeLabel.text = ""
        }
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            var bridgeBuiltorRejected = ""
            
            if label.center.x < 100 {
                
                bridgeBuiltorRejected = "rejected_bridges"
                
                print("rejected")
                updateImage()
                
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                //add pop-up for if currentUser wants to be apart of message***
                
                previousViewController = "BridgeViewController"
                
                bridgeBuiltorRejected = "built_bridges"
                
                let message = PFObject(className: "Messages")
                
                let currentUserId = PFUser.currentUser()?.objectId
                
                //Need to check for Bridge type to assign name
                
                //**if BridgeType = love {} else if BridgeType = business {} else if bridgeType = friendship {}
                let currentUserName = PFUser.currentUser()?["love_name"]
                
                message["names_in_message"] = [displayedUserName1.text!, displayedUserName2.text!, currentUserName!]
                message["ids_in_message"] = [userId1, userId2, currentUserId!]
                message["bridge_builder"] = currentUserId
                
                message.saveInBackgroundWithBlock({ (success, error) in
                    
                    print("message saved")
                    messageId = message.objectId!
                    
                })
                
                //messageId = message.objectId!
                
                singleMessageTitle = "\(displayedUserName1.text!) & \(displayedUserName2.text!)"
                
                //message.save
                
                print("built")
                performSegueWithIdentifier("showSingleMessage", sender: self)
                
                
            }
                /*
                message.saveInBackgroundWithBlock{ (success, error) -> Void in
                    
                    print("Object has been saved.")
                    
                }*/

            
        
            if bridgeBuiltorRejected != "" {
                
                //error checking
                //change or's and second users
                
                if let previousBridges = (PFUser.currentUser()?[bridgeBuiltorRejected]) as? [[String]] {
                    
                    let newBridges = previousBridges + [[userId1, userId2]]
                    PFUser.currentUser()?[bridgeBuiltorRejected] = newBridges
                    PFUser.currentUser()?.saveInBackground()
                    
                }
                
            }
            
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            label.transform = stretch
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            rejectOrBridgeLabel.text = ""
            
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Creating gesture recognizer
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        displayedUserName1.addGestureRecognizer(gesture)
        displayedUserName1.userInteractionEnabled = true
        
        userImage.addGestureRecognizer(gesture)
        userImage.userInteractionEnabled = true
        
        /*secondUserImage.addGestureRecognizer(gesture)
        secondUserImage.userInteractionEnabled = true*/
        
        //Accessing User locations
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if let geoPoint = geoPoint {
                
                PFUser.currentUser()?["location"] = geoPoint
                PFUser.currentUser()?.saveInBackground()
                
            }
            
        }
        
        if firstUpdatedImage {
            
            updateImage()
            firstUpdatedImage = false
            
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






//Notes

//Parse
//Adding Test Users

/*let urlArray = ["http://www.polyvore.com/cgi/img-thing?.out=jpg&size=l&tid=44643840ee80c0744e41bc767f2b9907c7df48d2.jpg",
 "http://content9.flixster.com/question/62/66/35/6266355_std.jpg",
 "http://4.bp.blogspot.com/_BEogiLoYMCk/TOJBQlCxmyI/AAAAAAAACBY/hxfpaKqTrKw/s400/10.jpg",
 "https://s-media-cache-ak0.pinimg.com/236x/ee/80/c0/",
 "https://s-media-cache-ak0.pinimg.com/236x/be/70/00/be700020e48e1020d6d8539d1cc19685.jpg",
 "https://img.buzzfeed.com/buzzfeed-static/static/2015-08/18/13/enhanced/webdr13/grid-cell-15170-1439918492-2.jpg"]
 
 var counter = 1
 
 for url in urlArray {
 
 let nsUrl = NSURL(string: url)
 print(nsUrl)
 if let data = NSData(contentsOfURL: nsUrl!) {
 
 self.userImage.image = UIImage(data: data)
 
 let imageFile: PFFile = PFFile(data: data)!
 var user:PFUser = PFUser()
 var username = "user\(counter)"
 
 user["fb_profile_picture"] = imageFile
 user["gender"] = "female"
 user.username = username
 user.password = "pass"
 counter += 1
 user.signUpInBackground()
 
 }
 
 
 }
 */
