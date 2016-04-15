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
    
    var messageTextArray = [String]()
    
    @IBOutlet weak var singleMessageTableView: UITableView!
    
    @IBAction func sendMessage(sender: AnyObject) {
        
        if messageText.text != "" {
            
            messageTextArray.append(messageText.text!)
            singleMessageTableView.reloadData()
            
            
            let singleMessage = PFObject(className: "SingleMessages")
            singleMessage["message_text"] = messageText.text!
            singleMessage["sender"] = PFUser.currentUser()?.objectId
            
            singleMessage.saveInBackgroundWithBlock { (success, error) -> Void in
                
              print("Object has been saved.")
                
            }
            
            
            
            messageText.text = ""
            
            

        }
        
    }
    
    func updateMessages() {
        
        //querying for messages
        var query: PFQuery = PFQuery(className: "SingleMessages")
        
        query.whereKey("sender", equalTo: (PFUser.currentUser()?.objectId)!)
        
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            
            if let error = error {
                
                print(error)
                
            } else if let results = results {
                
                for result in results {
                    
                    self.messageTextArray.append(result["message_text"] as! String)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.singleMessageTableView.reloadData()
                    
                })
                
            }
            
            print(self.messageTextArray)
            
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = singleMessageTitle
        
        updateMessages()
        
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
        
        print(messageTextArray.count)
        return messageTextArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        print(messageTextArray[indexPath.row])
        cell.textLabel?.text = messageTextArray[indexPath.row]
        
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
