//
//  UserInfo.swift
//  HitList
//
//  Created by Sagar Sinha on 6/14/16.
//  Copyright © 2016 SagarSinha. All rights reserved.
//

import Foundation
class UserInfo:NSObject, NSCoding  {
    var username: String? = ""
    var interested_in: String? = nil
    var friendlist: [String]? = []
    var mainProfilePicture: NSData? = nil
    var pairings:[UserInfoPair]? = []
    init( username:String?, friendlist: [String]?, mainProfilePicture: NSData? ,pairings:[UserInfoPair]?, interested_in: String? ) {
        self.username = username
        self.friendlist = friendlist
        self.mainProfilePicture = mainProfilePicture
        self.pairings = pairings
        self.interested_in = interested_in
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObjectForKey("username") as! String?
        let friendlist = aDecoder.decodeObjectForKey("friendlist") as! [String]?
        let mainProfilePicture = aDecoder.decodeObjectForKey("shortname") as! NSData?
        let pairings = aDecoder.decodeObjectForKey("pairings") as! [UserInfoPair]?
        let interested_in = aDecoder.decodeObjectForKey("interested_in") as! String?
        self.init(username: username, friendlist: friendlist, mainProfilePicture: mainProfilePicture, pairings: pairings, interested_in: interested_in )
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(friendlist, forKey: "friendlist")
        aCoder.encodeObject(mainProfilePicture, forKey: "mainProfilePicture")
        aCoder.encodeObject(pairings, forKey: "pairings")
        aCoder.encodeObject(interested_in, forKey: "interested_in")
    }
    
}