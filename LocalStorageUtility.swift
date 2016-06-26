//
//  LocalStorageUtility.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/16/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import FBSDKLoginKit
import CoreData
class LocalStorageUtility{
    
    func getUserPhotos(){
        // Need to be worked upon after we get permission
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        graphRequest.startWithCompletionHandler{ (connection, result, error) -> Void in
            print(" graph request")
            if error != nil {
                
                print(error)
                print("got error")
                
            } else if let result = result {
                print("got result")
                let userId = result["id"]! as! String
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                let facebookProfilePictureUrl = "https://graph.facebook.com/\(userId)/albums?access_token=\(accessToken)"
                if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                    print(fbpicUrl)
                    if let data = NSData(contentsOfURL: fbpicUrl) {
                        var error: NSError?
                        do{
                            var albumsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            print(albumsDictionary["data"]!)
                        }
                        catch{
                            print(error)
                        }
                    }
                    
                }
                
            }
            
            
        }
    }
    //saves  to LocalDataStorage & Parse
    func getMainProfilePicture(){
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name"])
        graphRequest.startWithCompletionHandler{ (connection, result, error) -> Void in
                if error != nil {
                print(error)
                }
                else if let result = result {
                let localData = LocalData()
                let userId = result["id"]! as! String
                /*let username = result["name"]! as! String
                localData.setUsername(username)*/
                let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
                    if let data = NSData(contentsOfURL: fbpicUrl) {
                        let imageFile: PFFile = PFFile(data: data)!
                        PFUser.currentUser()?["profile_picture"] = imageFile
                        PFUser.currentUser()?["profile_picture_from_fb"] = true
                        print("storing profile picture to local storage")
                        localData.setMainProfilePicture(data)
                        localData.setProfilePictureFromFb(true)
                        localData.synchronize()
                    }
                }
        
            }
        }
    }
    func getUserDetails(id:String)->PairInfo?{
        var user:PairInfo? = nil
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo:id)
        do{
            let objects = try query.findObjects()
            for object in objects {
                var name:String? = nil
                if let ob = object["name"] {
                    name = ob as? String
                }
                var main_profile_picture:NSData? = nil
                if let ob = object["fb_profile_picture"] {
                    let main_profile_picture_file = ob as! PFFile
                    let data = try main_profile_picture_file.getData()
                    main_profile_picture = data
                }
                var location:String? = nil
                if let ob = object["location"] {
                    //location = ob as! String
                }
                var bridge_status:String? = nil
                if let ob = object["current_bridge_status"] {
                    bridge_status = ob as? String
                }
                
                user = PairInfo(name:name, mainProfilePicture: main_profile_picture, profilePictures: nil,location: location, bridgeStatus: bridge_status, objectId: object.objectId )
            }
        }
        catch {
            
        }
        return user
        
    }
    //saves to LocalDataStorage and Parse

    func getUserFriends(){
        
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
        graphRequest.startWithCompletionHandler{ (connection, result, error) -> Void in
            if error != nil {
                print(print("Error: \(error!) \(error!.userInfo)"))
            }
            else if let result = result {
                let userId = result["id"]! as! String
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let facebookFriendsUrl = "https://graph.facebook.com/\(userId)/friends?access_token=\(accessToken)"
                
                if let fbfriendsUrl = NSURL(string: facebookFriendsUrl) {
                    
                    if let data = NSData(contentsOfURL: fbfriendsUrl) {
                        //background thread to parse the JSON data
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            do{
                                let friendList: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                                
                                if let data = friendList["data"] as? [[String: AnyObject]] {
                                    var friendsArray:[String] = []
                                    var friendsArrayFbId:[String] = []
                                    for item in data {
                                        if let name = item["name"] as? String {
                                            if let id = item["id"] as? String {
                                                
                                                print("\(name)'s id is \(id)")
                                                friendsArrayFbId.append(id)
                                                let query = PFQuery(className:"_User")
                                                query.whereKey("fb_id", equalTo:id)
                                                let objects = try query.findObjects()
                                                for object in objects {
                                                    friendsArray.append(object.objectId!)
                                                }
                                                
                                            }
                                            else {
                                                print("Error: \(error!) \(error!.userInfo)")
                                            }
                                            
                                        }
                                    }
                                    //Update Parse DB to store the friendlist
                                    
                                    PFUser.currentUser()?["fb_friends"] = friendsArrayFbId
                                    PFUser.currentUser()?["friend_list"] = friendsArray
                                    
                                    //Update Iphone's local storage to store the friendlist
                                    let localData = LocalData()
                                    localData.setFriendList(friendsArray)
                                    localData.synchronize()
                                    print("friends array -\(friendsArray)")
                                }
                                
                            }
                            catch  {
                                print(error)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func getBridgePairings(){
        var ignoredPairings = [[String]]()
        
        if let builtBridges = PFUser.currentUser()?["built_bridges"] {
            let builtBridges2 = builtBridges as! [[String]]
            ignoredPairings = ignoredPairings + builtBridges2
        }
        
        if let rejectedBridges = PFUser.currentUser()?["rejected_bridges"] {
            let rejectedBridges2 = rejectedBridges as! [[String]]
            ignoredPairings = ignoredPairings + rejectedBridges2
        }
        var friendPairings =  [[String]]()
        
        if let friendList = PFUser.currentUser()?["friend_list"] as? [String] {
            var pairings = [UserInfoPair]()
            for friend1 in friendList {
                if friendPairings.count >= 10 {
                    break
                }
                for friend2 in friendList {
                    if friendPairings.count >= 10 {
                        break
                    }
                    let containedInIgnoredPairings = ignoredPairings.contains {$0 == [friend1, friend2]} || ignoredPairings.contains {$0 == [friend2, friend1]}
                    
                    let PreviouslyDisplayedUser = friendPairings.contains {$0 == [friend1, friend2]} || friendPairings.contains {$0 == [friend2, friend1]}
                    if PreviouslyDisplayedUser == false && friend1 != friend2 && containedInIgnoredPairings == false  {
                        friendPairings.append([friend1,friend2])
                        var user1:PairInfo? = nil
                        var user2:PairInfo? = nil
                        user1 = getUserDetails(friend1)
                        user2 = getUserDetails(friend2)
                        
                        let userInfoPair = UserInfoPair(user1: user1, user2: user2)
                        pairings.append(userInfoPair)
                    }
                    
                }
                
            }
            let localData = LocalData()
            localData.setPairings(pairings)
            localData.synchronize()
        }
        
    }
}