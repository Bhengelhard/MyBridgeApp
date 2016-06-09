//
//  Users+CoreDataProperties.swift
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Users {

    @NSManaged var name: String?
    @NSManaged var profilePicture: String?

}
