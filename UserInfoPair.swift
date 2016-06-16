//
//  UserInfoPair.swift
//  HitList
//
//  Created by Sagar Sinha on 6/14/16.
//  Copyright © 2016 SagarSinha. All rights reserved.
//

import Foundation
class UserInfoPair:NSObject, NSCoding {
    var user1:PairInfo? = nil
    var user2:PairInfo? = nil
    init( user1:PairInfo?, user2:PairInfo?) {//, mainProfilePicture: NSData?) {//,pairings:[UserInfoPair]? ) {
        self.user1 = user1
        self.user2 = user2
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let user1 = aDecoder.decodeObjectForKey("user1") as! PairInfo?
        let user2 = aDecoder.decodeObjectForKey("user2") as! PairInfo?
        self.init(user1: user1, user2: user2)
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(user1, forKey: "user1")
        aCoder.encodeObject(user2, forKey: "user2")
    }
    
}