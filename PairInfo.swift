//
//  PairInfo.swift
//  HitList
//
//  Created by Sagar Sinha on 6/14/16.
//  Copyright © 2016 SagarSinha. All rights reserved.
//

import Foundation
class PairInfo:NSObject, NSCoding {
    var name:String? = ""
    var mainProfilePicture:NSData? = nil
    var profilePictures: [NSData]? = nil
    var location:String? = ""
    var bridgeStatus:String? = ""
    init( name:String?, mainProfilePicture: NSData?, profilePictures: [NSData]?, location:String?, bridgeStatus:String?) {
        self.name = name
        self.mainProfilePicture = mainProfilePicture
        self.profilePictures = profilePictures
        self.location = location
        self.bridgeStatus = bridgeStatus
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String?
        let mainProfilePicture = aDecoder.decodeObjectForKey("mainProfilePicture") as! NSData?
        let profilePictures = aDecoder.decodeObjectForKey("profilePictures") as! [NSData]?
        let location = aDecoder.decodeObjectForKey("location") as! String?
        let bridgeStatus = aDecoder.decodeObjectForKey("bridgeStatus") as! String?
        self.init(name: name, mainProfilePicture: mainProfilePicture, profilePictures: profilePictures,
                  location: location, bridgeStatus: bridgeStatus)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(mainProfilePicture, forKey: "mainProfilePicture")
        aCoder.encodeObject(profilePictures, forKey: "profilePictures")
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(bridgeStatus, forKey: "bridgeStatus")
        
    }
    
}