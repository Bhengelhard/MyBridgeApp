//
//  SingleMessageViewController.swift
//  MyBridgeApp
//
//  Created by Blake Engelhard on 4/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SingleMessageViewController: UIViewController, UITableViewDelegate {

    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBAction func sendMessage(sender: AnyObject) {
        
        if messageText.text != "" {
            
            let singleMessage = PFObject(className: "SingleMessages")
            singleMessage["message_text"] = messageText.text!
            singleMessage["sender"] = PFUser.currentUser()?.objectId
            
            singleMessage.saveInBackgroundWithBlock { (success, error) -> Void in
              print("Object has been saved.")
            }

            
        }
        
        
        
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       navigationBar.title = singleMessageTitle
        //create singleMessage class in DB where row is created for each message sent with Sender (currentUser), MessageId (Id from Messages Class), MessageContent (TextField), recievers (recievers - current user) are displayed on title
        
        /*var query: PFQuery = PFQuery(className: "Messages")
        
        query.whereKey("objectId", containedIn: )
        query.limit = 2
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            
            if error != nil {
                
                print(error)
                
            } else if let objects = objects {
                
                for object in objects {
                    
                    
                    
                }
                    
                
            }
            
        }*/

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = "test"
        
        return cell
        
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
