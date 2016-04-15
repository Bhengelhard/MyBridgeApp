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
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    @IBAction func sendMessage(sender: UIButton) {
        
        //call the end editing method for the text field
        messageText.endEditing(true)
        
        //disable the  textfield and sendButton

        messageText.enabled = false
        sendButton.enabled = false
        
        if messageText.text != "" {
            
            /*messageTextArray.append(messageText.text!)
            singleMessageTableView.reloadData()*/
            
            
            let singleMessage = PFObject(className: "SingleMessages")
            singleMessage["message_text"] = messageText.text!
            singleMessage["sender"] = PFUser.currentUser()?.objectId
            //save users_in_message to singleMessage
            singleMessage["ids_in_message"] = idsInMessage
            
            singleMessage.saveInBackgroundWithBlock { (success, error) -> Void in
                
                if (success) {
                    self.updateMessages()
                    print("Object has been saved.")
                    
                } else {
                    
                    print(error)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //enable the textfield and sendButton
                    self.messageText.enabled = true
                    self.sendButton.enabled = true
                    self.messageText.text = ""
                    
                })
                
            }

        }
        
    }
    
    
    
    func updateMessages() {
        
        //querying for messages
        var query: PFQuery = PFQuery(className: "SingleMessages")
        
        query.whereKey("ids_in_message", containsAllObjectsInArray: idsInMessage as [AnyObject])
        
        //query.whereKey("ids_in_message", equalTo: idsInMessage)
        
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            
            //Clear the messagesArray
            self.messageTextArray = [String]()
            
            //retrive messages and update messageTextArray
            if let error = error {
                
                print(error)
                
            } else if let results = results {
                
                for result in results {
                    
                    let singleMessageText:String? = (result as PFObject)["message_text"] as? String
                    
                    if singleMessageText != nil {
                        
                        self.messageTextArray.append(singleMessageText!)
                        
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.singleMessageTableView.reloadData()
                    
                })
                
            }
            
        })
        
    }
    
    /*@IBAction func exitMessage(sender: AnyObject) {
        
        var alert = UIAlertController(title: "Exiting the Message", message: "Are you sure you want to leave this conversation?", preferredStyle: UIAlertControllerStyle.Alert)
        
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            
            //take user out of the current ids_in_message
            var messages = PFObject(className: "Messages")
            messages.saveInBackground()
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
            self.presentViewController(alert, animated: true, completion: nil)
        
    }*/
    
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
        
        return messageTextArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = messageTextArray[indexPath.row]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
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
