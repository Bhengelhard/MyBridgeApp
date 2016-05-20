//
//  SingleMessageViewController.swift
//  MyBridgeApp
//
//  Created by Blake Engelhard on 4/8/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

//var segueFromExitedMessage = false

class SingleMessageViewController: UIViewController, UITableViewDelegate {

    
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var messageTextArray = [String]()
    
    @IBOutlet weak var singleMessageTableView: UITableView!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    @IBAction func sendMessage(sender: UIButton) {
        
        if messageText.text != "" {
            
            //call the end editing method for the text field
            messageText.endEditing(true)
            
            //disable the  textfield and sendButton
            
            messageText.enabled = false
            sendButton.enabled = false
            
            let singleMessage = PFObject(className: "SingleMessages")
            singleMessage["message_text"] = messageText.text!
            singleMessage["sender"] = PFUser.currentUser()?.objectId
            //save users_in_message to singleMessage
            singleMessage["message_id"] = messageId
            
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
        let query: PFQuery = PFQuery(className: "SingleMessages")
        
        query.whereKey("message_id", equalTo: messageId)
        
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
    
    @IBAction func exitMessage(sender: AnyObject) {
        
        //create the alert controller
        let alert = UIAlertController(title: "Exiting the Message", message: "Are you sure you want to leave this conversation?", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Create the actions
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
            
            //take currentUser out of the current ids_in_message
            
            let messageQuery = PFQuery(className: "Messages")
            messageQuery.getObjectInBackgroundWithId(messageId, block: { (object, error) in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    /*dispatch_async(dispatch_get_main_queue(), {
                        
                        segueFromExitedMessage = true
                        
                    })*/
                    
                    let CurrentIdsInMessage: NSArray = object!["ids_in_message"] as! NSArray
                    let CurrentNamesInMessage: NSArray = object!["names_in_message"] as! NSArray
                    
                    var updatedIdsInMessage = [String]()
                    var updatedNamesInMessage = [String]()
                    
                    for i in 0...(CurrentIdsInMessage.count - 1) {
                        
                        if CurrentIdsInMessage[i] as? String != PFUser.currentUser()?.objectId {
                            
                            updatedIdsInMessage.append(CurrentIdsInMessage[i] as! String)
                            updatedNamesInMessage.append(CurrentNamesInMessage[i] as! String)
                            
                        }
                        
                    }
                    
                    object!["ids_in_message"] = updatedIdsInMessage
                    object!["names_in_message"] = updatedNamesInMessage
                    
                    object!.saveInBackgroundWithBlock({ (success, error) in
                        
                        print("message updated for exited user")
                        
                    })
                    
                }
                
                
                
            })
            /*var newIdsInMessage = [String]()
            for ID in idsInMessage {
                
                if ID != PFUser.currentUser()?.objectId {
                    
                    newIdsInMessage.append(ID)
                    
                }
            
            }
            
            //var message = PFObject(outDataWithClassName: "Messages", objectId: "ids")
            /*var messages = PFObject(className: "Messages")
            //messages.
            messages.saveInBackground()*/*/
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
            
            dispatch_async(dispatch_get_main_queue(), {
                
                //pop-up/drop-down segue for BridgeViewController Message creations
                self.performSegueWithIdentifier("showBridgeFromSingleMessage", sender: self)
                
                //slide in and slide back segue from Messages message access.
                
                //self.performSegueWithIdentifier("showMessagesFromSingleMessage", sender: self)
                
            })
            
            
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = singleMessageTitle
        if previousViewController == "MessagesViewController" {
            
            updateMessages()
            
        }
        
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
