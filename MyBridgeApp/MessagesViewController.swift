//
//  MessagesViewController.swift
//  MyBridgeApp
//
//  Created by Blake Engelhard on 3/30/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

var singleMessageTitle = "Message"
var messageId = String()
//var messageID =

//Change to MessagesTableViewController so other can be MessageViewController

func getWeekDay(num:Int)->String{
    switch num {
    case 1: return "Sunday"
    case 2: return "Monday"
    case 3: return "Tuesday"
    case 4: return "Wednesday"
    case 5: return "Thursday"
    case 6: return "Friday"
    case 7: return "Saturday"
    default : return "A good day to die hard!"
    }
}


class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating {
    
   
    @IBOutlet weak var tableView: UITableView!
   // @IBOutlet var tableView: UITableView!
    var emails = [String]()
    var images = [UIImage]()
    
    //need to combine these into a dictionary
    var names = [[String]]()
    var IDsOfMessages = [String]()
    var messages = [String]()
    var messageType = [String]()
    var messageTimestamps = [NSDate?]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPositions = [Int]()
    var toolbarTapped = false
    @IBAction func friendshipTapped(sender: AnyObject) {
       toolbarTapped = true
        filteredPositions = [Int]()
        for i in 0 ..< messageType.count{
            if messageType[i] == "Friendship" {
                filteredPositions.append(i)
            }
        }
        self.tableView.reloadData()
    }
    @IBAction func loveTapped(sender: AnyObject) {
        toolbarTapped = true
        filteredPositions = [Int]()
        for i in 0 ..< messageType.count{
            if messageType[i] == "Love" {
                filteredPositions.append(i)
            }
        }
        self.tableView.reloadData()
    }
    @IBAction func businessTapped(sender: AnyObject) {
        toolbarTapped = true
        filteredPositions = [Int]()
        for i in 0 ..< messageType.count{
            if messageType[i] == "Business" {
                filteredPositions.append(i)
            }
        }
        //print("Filtered positions count is \(messageType.count)")
        self.tableView.reloadData()
    }
   
    @IBAction func allBridgesTapped(sender: AnyObject) {
        toolbarTapped = true
        filteredPositions = [Int]()
        for i in 0 ..< messageType.count{
            filteredPositions.append(i)
        }

        self.tableView.reloadData()
    }
    @IBAction func segueToBridgeViewController(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    func updateMessagesTable() {
        
        //messages users_in_message are displayed in box, when clicked, open message with SingleMessages MessageId = Messages ObjectId
        
        let query: PFQuery = PFQuery(className: "Messages")
        
        query.whereKey("ids_in_message", containsString: PFUser.currentUser()?.objectId)
        query.orderByDescending("updatedAt")
        
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            
            if let error = error {
                
                print(error)
                
            } else if let results = results {
                
                for result in results{
                    self.IDsOfMessages.append(result.objectId!)
                    if let _ = result["message_type"] {
                        self.messageType.append(result["message_type"] as! (String))
                    }
                    else{
                        self.messageType.append("Default")
                    }
                    let message_userids = result["ids_in_message"] as! [String]
                    var names_per_message = [String]()
                    //get all those involved in this chat
                    do{
                        let userQuery = PFQuery(className:"_User")
                        userQuery.whereKey("objectId", containedIn:message_userids)
                        let userObjects = try userQuery.findObjects()
                        for userObject in userObjects {
                            names_per_message.append(userObject["name"] as! String)
                        }
                    }
                    catch{
                        
                    }
                    self.names.append(names_per_message)
                    // get the message
                    do{
                        let messageQuery = PFQuery(className:"SingleMessages")
                        messageQuery.whereKey("message_id", equalTo:result.objectId!)
                        messageQuery.orderByDescending("createdAt")
                        let messageObjects = try messageQuery.findObjects()
                        if messageObjects.count == 0{
                            self.messages.append("Your new bridge awaits")
                            self.messageTimestamps.append(result.createdAt!)
                        }
                        else {
                         for messageObject in messageObjects {
                             if let _ = messageObject["message_text"] {
                                 self.messages.append(messageObject["message_text"] as! (String))
                             }
                             else{
                                 self.messages.append("")
                             }
                            self.messageTimestamps.append((messageObject.createdAt))
                            break
                            //friendsArray.append(object.objectId!)
                         }
                        }
                    }
                    catch{
                        print(error)
                    }
                    
                    
                }

                print("current user - \(PFUser.currentUser()?["name"])")
                print("names - \(self.names)")
               dispatch_async(dispatch_get_main_queue(), {
                    
                    self.tableView.reloadData()
                    
                })
                
            }
            
            
        })

        
    }
    func filterContentForSearchText(searchText:String, scope: String = "All"){
        filteredPositions = [Int]()
        for i in 0 ..< names.count  {
            var flag = true
            for individualNames in names[i]{
                if individualNames.lowercaseString.containsString(searchText.lowercaseString){
                    filteredPositions.append(i)
                    flag = false
                    break
                }
            }
            
            if flag && messages[i].lowercaseString.containsString(searchText.lowercaseString){
                filteredPositions.append(i)
            }
        }
        tableView.reloadData()
        
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateMessagesTable()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        //self.navigationController!.toolbarHidden=false;
        //this should only update when a new message is created**
        //shouldn't be reloading the table more than once per viewDidLoad
        
        
        
        /*if segueFromExitedMessage == true {
            
            IDsOfMessages.removeFirst()
            names.removeFirst()
            
            print("ids")
            print(IDsOfMessages)
            print("names")
            print(names)
            
            segueFromExitedMessage = false
            
            tableView.reloadData()
            
            
            
        }*/
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print("numberOfRowsInSection \( IDsOfMessages.count + 1) \(LocalData().getUsername())")
        if (searchController.active && searchController.searchBar.text != "") || toolbarTapped {
            print ("Search term is \(searchController.searchBar.text) and number of results is \(filteredPositions.count)")
            return filteredPositions.count
        }
        return messages.count
        
    }

    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //print("Row is \(indexPath.row)")
        var names = self.names
        var messages = self.messages
        var messageType = self.messageType
        var messageTimestamps = self.messageTimestamps
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MessagesTableCell
        
        if (searchController.active && searchController.searchBar.text != "") || toolbarTapped {
             names = [[String]]()
             messages = [String]()
             messageType = [String]()
             messageTimestamps = [NSDate?]()

            for index in filteredPositions {
                names.append(self.names[index])
                messages.append(self.messages[index])
                messageType.append(self.messageType[index])
                messageTimestamps.append(self.messageTimestamps[index])
            }
        }
        var stringOfNames = ""
        var users = names[indexPath.row]
        users = users.filter { $0 != PFUser.currentUser()?["name"] as! String }
        
        for i in 0 ..< users.count  {
            
            var name = users[i]
            if users.count > 2 && i < users.count - 2 {
                var fullNameArr = name.characters.split{$0 == " "}.map(String.init)
                stringOfNames = stringOfNames + fullNameArr[0] + " , "
                
            } else if users.count >= 2 && i == users.count - 2 {
                var fullNameArr = name.characters.split{$0 == " "}.map(String.init)
                stringOfNames = stringOfNames + fullNameArr[0] + " & "
                
            }
            else {
                if users.count > 1{
                    name = name.characters.split{$0 == " "}.map(String.init)[0]
                }
                stringOfNames = stringOfNames + name
            }
            
        }
        
        //cell.participants.lineBreakMode = .ByWordWrapping
        //cell.participants.numberOfLines = 0
        cell.participants.text = stringOfNames
        cell.messageSnapshot.text = messages[indexPath.row]
        switch messageType[indexPath.row]{
            
        case "Business": cell.backgroundColor = UIColor(red: 139.0/255, green: 217.0/255, blue: 176.0/255, alpha: 1.0)
            break
        case "Love": cell.backgroundColor = UIColor.init(red: 255.0/255, green: 129.0/255, blue: 125.0/255, alpha: 1.0)
            break
        case "Friendship": cell.backgroundColor = UIColor.init(red: 144.0/255, green: 207.0/255, blue: 214.0/255, alpha: 1.0)
            break
        default: cell.backgroundColor = UIColor.init(red: 139.0/255, green: 217.0/255, blue: 176.0/255, alpha: 1.0)
            
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyy hh:mm:ss +zzzz"
        let calendar = NSCalendar.currentCalendar()
        let date = messageTimestamps[indexPath.row]!
        let components = calendar.components([.Month, .Day, .Year, .WeekOfYear],
                                             fromDate: date, toDate: NSDate(), options: NSCalendarOptions.WrapComponents)
        if components.day > 7 {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy"
            print(dateFormatter.stringFromDate(date))
            cell.messageTimestamp.text = dateFormatter.stringFromDate(date)+">"
        }
        else if components.day > 2 {
            let calendar = NSCalendar.currentCalendar()
            let date = messageTimestamps[indexPath.row]!
            let components = calendar.components([.Weekday],
                                                 fromDate: date)
            print(components.weekday)
            cell.messageTimestamp.text = String(getWeekDay(components.weekday))+">"
        }
        else if components.day > 1 {
            print ("Yesterday")
            cell.messageTimestamp.text = "Yesterday"+">"
        }
        else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss"
            cell.messageTimestamp.text = dateFormatter.stringFromDate(date)+">"
            print(dateFormatter.stringFromDate(date))
            
        }
        if indexPath == filteredPositions.count - 1 {
            toolbarTapped = false
        }
        return cell

        
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var IDsOfMessages = self.IDsOfMessages
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as! MessagesTableCell
        if (searchController.active && searchController.searchBar.text != "") || toolbarTapped {
            IDsOfMessages = [String]()
            for index in filteredPositions {
                IDsOfMessages.append(self.IDsOfMessages[index])
            }
        }

        singleMessageTitle = (currentCell.participants?.text)!
        messageId = IDsOfMessages[indexPath.row ]
        
        previousViewController = "MessagesViewController"
        toolbarTapped = false
        //messageId =
        
        //print(singleMessageTitle)
        /*if let cellText = cell.textLabel?.text {
            
            print(cellText)
            
            singleMessageTitle = cellText
            
        }*/
        
        performSegueWithIdentifier("showSingleMessageFromMessages", sender: self)
    

        
        //opening email to send mail
        /*let url = NSURL(string: "mailto:" + emails[indexPath.row])
        
        UIApplication.sharedApplication().openURL(url!)
        
        print(url!)*/
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
