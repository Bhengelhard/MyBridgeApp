import UIKit
import Parse
import FBSDKCoreKit

class BridgeViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var secondUserImage: UIImageView!
    
    var displayedUserId = ""
    
    //Need to fix ignoredUsers to not reiterate through different users and to add the correct people**
    /*var ignoredUsers = [String]()
    var currentUserAdded = 0
    
    var ignoredPairings = [[String]]()
    var friendCombinations = [[String]]()*/
    
    func updateImage() {
        
        /*if let builtBridges = PFUser.currentUser()?["built_bridges"] {
            
            let builtBridges2 = builtBridges as! [[String]]
            
            ignoredPairings = ignoredPairings + builtBridges2
            
            print(builtBridges)
            
        }
        
        if let rejectedBridges = PFUser.currentUser()?["rejected_bridges"] {
            
            let rejectedBridges2 = rejectedBridges as! [[String]]
            
            ignoredPairings = ignoredPairings + rejectedBridges2
            
            print(rejectedBridges)
            
        }*/
        var friendPairings = [[String]]()
        
        
        if let friendList = PFUser.currentUser()?["friend_list"] as? [String] {
            
            //while friendpairings.count <4
            
            for friend1 in friendList {
                
                for friend2 in friendList {
                    
                    let pairingAlreadyAdded = friendPairings.contains {$0 == [friend2, friend1]}
                    
                    if friend1 != friend2 && pairingAlreadyAdded == false {
                        
                        friendPairings = friendPairings + [[friend1,friend2]]

                    }
                    
                }
                
            }
            
        }
        
        var counter = 0
        
        var query: PFQuery = PFUser.query()!
        
        //problem with this containedIn query returing one object, when it should return 2
        query.whereKey("objectId", containedIn: friendPairings[0])
        
        query.limit = 2
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else if let objects = objects {
                
                print(objects.count)
                
                for object in objects {
                    
                    let imageFile = object["fb_profile_picture"] as! PFFile
                    
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        if error != nil {
                            
                            print(error)
                            
                        } else if counter == 0 {
                            
                            if let data = imageData {
                                
                                self.userImage.image = UIImage(data: data)
                                
                            }
                            
                            counter = 1
                        
                        
                        } else {
                            
                            if let data = imageData {
                                
                                self.secondUserImage.image = UIImage(data: data)
                                
                            }
                            
                        }
                    
                    }
                    
                }
                
            }
            
        }
        
        /*
        
        //Query for Image in BridgeViewController
        var query: PFQuery = PFUser.query()!
        
        //Querying based on who is not in accepted or rejected arrays of the currentUser

        //making sure the currentUser doesn't show up more than once
        
        if currentUserAdded == 0 {
            
            if let user = PFUser.currentUser()?.objectId {
                
                ignoredUsers = ignoredUsers + [user]
                currentUserAdded = 1
                
            }
            
        }
        
        
        if let acceptedUsers  = PFUser.currentUser()?["accepted"] as? [String] {
            
            ignoredUsers = ignoredUsers + acceptedUsers
            
        }
        
        if let rejectedUsers = PFUser.currentUser()?["rejected"] as? [String] {
            
            ignoredUsers = ignoredUsers + rejectedUsers
            
        }
        
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
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            //var acceptedOrRejected = ""
            
            if label.center.x < 100 {
                
                //acceptedOrRejected = "rejected"
                
                
            } else if label.center.x > self.view.bounds.width - 100 {
                
                //acceptedOrRejected = "accepted"
                
            }
            
            /*if acceptedOrRejected != "" {
                
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: acceptedOrRejected)
                
                PFUser.currentUser()?.saveInBackground()
                
            }*/
            
            
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            label.transform = stretch
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            
            updateImage()
            
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Creating gesture recognizer
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        userImage.addGestureRecognizer(gesture)
        userImage.userInteractionEnabled = true
        
        secondUserImage.addGestureRecognizer(gesture)
        secondUserImage.userInteractionEnabled = true
        
        //Accessing User locations
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if let geoPoint = geoPoint {
                
                PFUser.currentUser()?["location"] = geoPoint
                PFUser.currentUser()?.saveInBackground()
                
            }
            
        }
        
        PFUser.currentUser()?["friend_list"] = ["INN0TDBFYZ", "zuKhtqAHgj"]
        
        updateImage()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOut" {
            
            PFUser.logOut()
            
        }
        
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
