//
//  Users+CoreDataProperties.h
//  MyBridgeApp
//
//  Created by Sagar Sinha on 6/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Users.h"

NS_ASSUME_NONNULL_BEGIN

@interface Users (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *profilePicture;

@end

NS_ASSUME_NONNULL_END
