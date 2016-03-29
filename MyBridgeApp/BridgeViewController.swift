import UIKit
import Parse
import FBSDKCoreKit
//import ParseFacebookUtilsV4
//import ParseUI


class BridgeViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var query: PFQuery = PFUser.query()!
        
        query.limit = 1
        
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            
            if error != nil {
                
                print(error)
                
            } else if let objects = objects {
                
                for object in objects {
                    
                    let imageFile = object["fb_profile_picture"] as! PFFile
                    
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        if error != nil {
                            
                            print(error)
                            
                        } else if let data = imageData {
                            
                            self.userImage.image = UIImage(data: data)
                            
                        }
                        
                        
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
