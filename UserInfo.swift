//
//  UserInfo.swift
//  HitList
//
//  Created by Sagar Sinha on 6/14/16.
//  Copyright © 2016 SagarSinha. All rights reserved.
//

import Foundation
class UserInfo:NSObject, NSCoding  {
    var username: String? = nil
    var interestedIn: String? = nil
    var friendlist: [String]? = []
    var mainProfilePicture: NSData? = nil
    var pairings:[UserInfoPair]? = nil
    var profilePictureFromFb:Bool? = nil
    var newMessagesPushNotifications:Bool? = nil
    var newBridgesPushNotifications:Bool? = nil
    init( username:String?, friendlist: [String]?, mainProfilePicture: NSData? ,pairings:[UserInfoPair]?,
          interestedIn: String?, profilePictureFromFb:Bool?, newMessagesPushNotifications:Bool?, newBridgesPushNotifications:Bool? ) {
        self.username = username
        self.friendlist = friendlist
        self.mainProfilePicture = mainProfilePicture
        self.pairings = pairings
        self.interestedIn = interestedIn
        self.profilePictureFromFb = profilePictureFromFb
        self.newMessagesPushNotifications = newMessagesPushNotifications
        self.newBridgesPushNotifications = newBridgesPushNotifications
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObjectForKey("username") as! String?
        let friendlist = aDecoder.decodeObjectForKey("friendlist") as! [String]?
        let mainProfilePicture = aDecoder.decodeObjectForKey("mainProfilePicture") as! NSData?
        let pairings = aDecoder.decodeObjectForKey("pairings") as! [UserInfoPair]?
        let interestedIn = aDecoder.decodeObjectForKey("interestedIn") as! String?
        let profilePictureFromFb = aDecoder.decodeObjectForKey("profilePictureFromFb") as! Bool?
        let newMessagesPushNotifications = aDecoder.decodeObjectForKey("newMessagesPushNotifications") as! Bool?
        let newBridgesPushNotifications = aDecoder.decodeObjectForKey("newBridgesPushNotifications") as! Bool?
        
        self.init(username: username, friendlist: friendlist, mainProfilePicture: mainProfilePicture, pairings: pairings, interestedIn: interestedIn, profilePictureFromFb: profilePictureFromFb, newMessagesPushNotifications:newMessagesPushNotifications,
                  newBridgesPushNotifications:newBridgesPushNotifications)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(friendlist, forKey: "friendlist")
        aCoder.encodeObject(mainProfilePicture, forKey: "mainProfilePicture")
        aCoder.encodeObject(pairings, forKey: "pairings")
        aCoder.encodeObject(interestedIn, forKey: "interestedIn")
        aCoder.encodeObject(profilePictureFromFb, forKey: "profilePictureFromFb")
        aCoder.encodeObject(newMessagesPushNotifications, forKey: "newMessagesPushNotifications")
        aCoder.encodeObject(newBridgesPushNotifications, forKey: "newBridgesPushNotifications")
    }
    
}