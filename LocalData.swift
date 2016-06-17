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
    var interested_in:String? = nil

    init(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let decoded = userDefaults.objectForKey("userInfo") {
            if let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded as! NSData) {
                username = (userInfo as! UserInfo).username
                friendlist = (userInfo as! UserInfo).friendlist
                mainProfilePicture = (userInfo as! UserInfo).mainProfilePicture
                pairings = (userInfo as! UserInfo).pairings
            }
        }
    }
    func setUsername(username:String){
        self.username = username
    }
    func getUsername()-> String?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.username
    }
    
    func setInterestedIN(interested_in:String){
        self.interested_in = interested_in
    }
    func getInterestedIN()-> String?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.interested_in
    }

    func setFriendList(friendlist: [String]){
        self.friendlist = friendlist
    }
    func getFriendList()-> [String]?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.friendlist

    }
    
    func setMainProfilePicture(mainProfilePicture:NSData){
        self.mainProfilePicture = mainProfilePicture
    }
    func getMainProfilePicture()->NSData?{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.mainProfilePicture
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
        let decoded  = userDefaults.objectForKey("userInfo") as! NSData
        let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! UserInfo
        return userInfo.pairings
    }
    
    func synchronize(){
        //print("Setting mainProfilePicture to \(mainProfilePicture)")
        let userInfo:UserInfo = UserInfo(username: username, friendlist: friendlist,
                                         mainProfilePicture: mainProfilePicture, pairings: pairings, interested_in: interested_in)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userInfo)
        userDefaults.setObject(encodedData, forKey: "userInfo")
        userDefaults.synchronize()
    }
    
}