//
//  SCCArrayController.h
//  SpratCodeCore
//
//  Created by Ben Spratling on 9/14/15.
//  Copyright (c) 2015 recoveryfriendfinder.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCCChangeSet, SCCArrayController;

typedef void(^SCCArrayControllerHandler)(SCCChangeSet* changeSet);

/// An array changer maintains a list of handlers which should be called when a change is made to the aray.  These changes are described by a changeset object, with any new objects in the 'insertedObjects' array
@interface SCCArrayController : NSObject

//The managed objects
@property (copy, readonly, nonatomic) NSArray* contents;


///perform a batch change, inserting, moving and removing objects
- (void)performChangeSet:(SCCChangeSet *)changeSet withInsertedObjects:(NSArray *)insertedObjects;


///If you want to be notified when this happens, register a handler for this, and hold the return value stongly.  When you're done, release the object which was returned by this method.  The handler will be copied, so handle memory management accordingly
- (id)registerForChanges:(SCCArrayControllerHandler)handler;

@end


/// A mutable array changer calculates the changes automatically by specifying a KVC key-path to a unique identifier (you may not repeat objects in the array). thus you trigger all the wonderful features of the superclass merely by setting the new array value.
@interface SCCMutableArrayController : SCCArrayController

- (instancetype)initWithUniqueKeyPath:(NSString *)uniqueKeyPath;

@property (copy, readwrite) NSString* uniqueKeyPath;

@property (copy, readwrite, nonatomic) NSArray* contents;

@end
