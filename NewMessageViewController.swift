//
//  NewMessageViewController.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/23/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
class NewMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate {

    
    @IBOutlet weak var bridgeMessage: UITextField!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var sendButon: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var friendNames = [String]()
    var friendObjectIds = [String]()
    var friendProfilePictures = [UIImage]()
    var filteredPositions = [Int]()
    var nameAdded = false
    var picker = UIImagePickerController()
    var imageViewRef = UIButton()
    var sendToObjectIds = [String]()
    var imageSet = false
    
    func getFriendNames(){
        let friendList = LocalData().getFriendList()
        if let _ = friendList{
            let query: PFQuery = PFQuery(className: "_User")
            query.whereKey("objectId", containedIn: friendList!)
            query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let error = error {
                    print(error)
                }
                else if let results = results {
                    for result in results{
                        self.friendObjectIds.append(result.objectId!)
                        if let name = result["name"] as? String{
                            self.friendNames.append(name)
                        }
                        else {
                            self.friendNames.append("Anonymous")
                        }
                        if let profilePhoto = result["fb_profile_picture"] as? PFFile{
                            do {
                                let imageData = try profilePhoto.getData()
                                print("fb_profile_picture")
                                self.friendProfilePictures.append(UIImage(data:imageData)!)
                                
                            }
                            catch{
                                print(error)
                            }
                            
                        }
                        else if let profilePhoto = result["profile_picture"] as? PFFile{
                            do {
                                let imageData = try profilePhoto.getData()
                                print("profile_picture")
                                self.friendProfilePictures.append(UIImage(data:imageData)!)
                                
                            }
                            catch{
                                print(error)
                            }
                            
                        }
                        
                    }
                }
                
            })
        }
    }

    
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        if bridgeMessage.text != "" || self.imageSet{
            //self.imageSet = false
            imageMessage.hidden = true
            
            self.sendButon.userInteractionEnabled = false
            self.sendButon.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            self.searchController.searchBar.text = ""
            self.bridgeMessage.text = ""
            let query: PFQuery = PFQuery(className: "Messages")
            var objectIdsInMessage = sendToObjectIds
            objectIdsInMessage.append((PFUser.currentUser()?.objectId)!)
            print("objectIdsInMessage - \(objectIdsInMessage)")
            query.whereKey("ids_in_message", containsAllObjectsInArray: objectIdsInMessage)
            query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let error = error {
                    print(error)
                    
                } else if let results = results {
                    var messageId = String()
                    var messageIdNotFound = true
                    for result in results{
                        let objectIdsRetrieved = result["ids_in_message"] as! [String]
                        if objectIdsInMessage.count == objectIdsRetrieved.count{
                            print("object found")
                            messageId = result.objectId!
                            messageIdNotFound = false
                            result.saveInBackground() // to update the time
                            break
                        }
                    }
                    if (messageIdNotFound) {
                        print("object not found")
                        let message = PFObject(className: "Messages")
                        message["ids_in_message"]  = objectIdsInMessage
                        message["bridge_builder"] = PFUser.currentUser()?.objectId
                        do{
                            try message.save()
                            messageId = message.objectId!
                        }
                        catch{
                            print(error)
                        }

                    }
                    let singleMessage = PFObject(className: "SingleMessages")
                    if self.bridgeMessage.text != "" {
                        singleMessage["message_text"] = self.bridgeMessage.text!
                    }
                    if self.imageSet {
                        print("imageSet is Set to true")
                        let file = PFFile(data: UIImageJPEGRepresentation(self.imageMessage.image!, 1.0)!)
                        singleMessage["message_image"] = file
                        self.imageSet = false
                    }
                    singleMessage["sender"] = PFUser.currentUser()?.objectId
                    singleMessage["message_id"] = messageId
                    do{
                        try singleMessage.save()
                    }
                    catch{
                        print(error)
                    }

                }
            })
            
        }
        
    }
    @IBAction func photoButton(sender: AnyObject) {
        let savedSendTo = searchController.searchBar.text!
        searchController.active = false
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        self.picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        searchController.searchBar.text = savedSendTo
    }
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertView()
            alert.title = "Warning"
            alert.message = "You don't have camera"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    func openGallary(){
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker .dismissViewControllerAnimated(true, completion: nil)
        imageMessage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageMessage.hidden = false
        self.imageSet = true
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        print("picker cancel.")
        self.imageSet = false
    }

    
      override func viewDidLoad() {
        super.viewDidLoad()
        self.getFriendNames()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "To:                                                        "
        self.sendButon.userInteractionEnabled = false
        self.sendButon.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        imageMessage.hidden = true
        // Do any additional setup after loading the view.
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("tapped")
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.sendButon.userInteractionEnabled = false
        self.sendButon.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.sendToObjectIds = [String]()
        print("cancel button tapped")
    }
    func filterContentForSearchText(searchText:String, scope: String = "All"){
        print("searchText is \(searchText) and friend ids are \(self.friendObjectIds)")
        self.filteredPositions = [Int]()
        var searchTerms = searchText.characters.split{$0 == ","}.map(String.init)
        var searchFor = searchText
        if searchTerms.count > 1 {
         searchFor = searchTerms[searchTerms.count - 1]
        }
        for i in 0 ..< self.friendNames.count  {
            if self.friendNames[i].lowercaseString.containsString(searchFor.lowercaseString){
                self.filteredPositions.append(i)
            }

        }
        tableView.reloadData()
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       /* if self.nameAdded {
            if let _ = searchController.searchBar.text{
            searchController.searchBar.text = searchController.searchBar.text! + ", "
            print("comma added")
            }
            
        }*/
        self.nameAdded = false
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPositions.count
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewMessageTableCell
        cell.name.text = self.friendNames[filteredPositions[indexPath.row]]
        cell.profilePhoto.image = self.friendProfilePictures[filteredPositions[indexPath.row]]
        cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.size.width/2
        cell.profilePhoto.clipsToBounds = true
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController.searchBar.text!.containsString(","){
            var searchTerms = searchController.searchBar.text!.characters.split{$0 == ","}.map(String.init)
            var preSearchedTerms = ""
            for i in 0 ..< searchTerms.count-1 {
                preSearchedTerms += searchTerms[i]+","
            }
            self.sendToObjectIds.append(self.friendObjectIds[filteredPositions[indexPath.row]])
            searchController.searchBar.text = preSearchedTerms+friendNames[filteredPositions[indexPath.row]]+","
            
        }
        else {
            print("filteredPositions \(filteredPositions) ")
            self.sendToObjectIds.append(self.friendObjectIds[filteredPositions[indexPath.row]])
            searchController.searchBar.text = friendNames[filteredPositions[indexPath.row]] + ","
            
        }
        
        
        self.sendButon.userInteractionEnabled = true
        self.sendButon.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.nameAdded = true
        //tableView.reloadData()
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
