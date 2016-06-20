//
//  LocalData.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/15/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
class LocalData {
    
    var username:String? = nil
    var friendlist: [String]? = nil
    var mainProfilePicture: NSData? = nil
    var pairings:[UserInfoPair]? = nil
    var interestedIn:String? = nil
    var profilePictureFromFb:Bool? = nil
    var newMessagesPushNotifications:Bool? = nil
    var newBridgesPushNotifications:Bool? = nil
    init(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let decoded = userDefaults.objectForKey("userInfo") {
            if let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) {
                username = (userInfo as! UserInfo).username
                friendlist = (userInfo as! UserInfo).friendlist
                mainProfilePicture = (userInfo as! UserInfo).mainProfilePicture
                pairings = (userInfo as! UserInfo).pairings
                interestedIn = (userInfo as! UserInfo).interestedIn
                profilePictureFromFb = (userInfo as! UserInfo).profilePictureFromFb
                newMessagesPushNotifications = (userInfo as! UserInfo).newMessagesPushNotifications
                newBridgesPushNotifications = (userInfo as! UserInfo).newBridgesPushNotifications
            }
        }
    }
    
    
    func setUsername(username:String){
        self.username = username
    }
    func getUsername()-> String?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.username
        }
        else{
        return nil
        }
    }
    
    
    func setInterestedIN(interestedIn:String){
        self.interestedIn = interestedIn
    }
    func getInterestedIN()-> String?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.interestedIn
        }
        else{
            return nil
        }
    }
    
    
    func setProfilePictureFromFb(profilePictureFromFb:Bool){
        self.profilePictureFromFb = profilePictureFromFb
    }
    func getProfilePictureFromFb()-> Bool?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.profilePictureFromFb
        }
        else{
            return nil
        }
    }
    
    func setNewMessagesPushNotifications(newMessagesPushNotifications:Bool){
        self.newMessagesPushNotifications = newMessagesPushNotifications
    }
    func getNewMessagesPushNotifications()-> Bool?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.newMessagesPushNotifications
        }
        else{
            return nil
        }
    }

    
    func setNewBridgesPushNotifications(newBridgesPushNotifications:Bool){
        self.newBridgesPushNotifications = newBridgesPushNotifications
    }
    func getNewBridgesPushNotifications()-> Bool?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.newBridgesPushNotifications
        }
        else{
            return nil
        }
    }



    func setFriendList(friendlist: [String]){
        self.friendlist = friendlist
    }
    func getFriendList()-> [String]?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.friendlist
        }
        else{
            return nil
        }

    }
    
    
    func setMainProfilePicture(mainProfilePicture:NSData){
        self.mainProfilePicture = mainProfilePicture
    }
    func getMainProfilePicture()->NSData?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.mainProfilePicture
        }
        else{
            return nil
        }
    }
    
    
    
    // add an array of pairs
    func setPairings(pairings:[UserInfoPair]){
        self.pairings = pairings
    }
    // add a single pair
    func addPair(userInfoPair:UserInfoPair){
        if var pairings = pairings{
            pairings.append(userInfoPair)
        }
        else{
            pairings = [userInfoPair]
        }
    }
    func getPairings()->[UserInfoPair]?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("userInfo"){
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.pairings
        }
        else{
            return nil
        }
    }
    
    
    
    func synchronize(){
        //print("Setting mainProfilePicture to \(mainProfilePicture)")
        let userInfo:UserInfo = UserInfo(username: username, friendlist: friendlist, mainProfilePicture: mainProfilePicture, pairings:pairings, interestedIn: interestedIn, profilePictureFromFb:profilePictureFromFb, newMessagesPushNotifications:newMessagesPushNotifications, newBridgesPushNotifications:newBridgesPushNotifications  )
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userInfo)
        userDefaults.setObject(encodedData, forKey: "userInfo")
        userDefaults.synchronize()
    }
    
}