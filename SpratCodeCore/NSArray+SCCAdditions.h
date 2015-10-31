//
//  NSArray+SCCAdditions.h
//  Presentation Calibration
//
//  Created by Ben Spratling on 5/3/15.
//  Copyright (c) 2015 benspratling.com. All rights reserved.
//

#import <Foundation/Foundation.h>


//A change set is returned by a diff algorithm, which compares strings.  A basic change set can have any objects
@interface SCCChangeSet : NSObject

@property (copy) NSIndexSet* insertedIndexes;

@property (copy) NSIndexSet* removedIndexes;

//keys are NSNumber of original index, value is NSNumber of new index
@property (copy) NSMapTable* movingMapTable;

//these indexes are still the same objects, but have properties which have changed
@property (copy) NSIndexSet* reloadIndexes;

@end


@interface NSArray (SpratCodeCore)

//Objects must be unique strings
- (SCCChangeSet *)changesetFromArray_scc:(NSArray *)originalArray;
//object may be BSCChangeSet or SCCChangeSet

/// While it uses the 'uniqueKeyPath' to determine which objects have been inserted removed, etc...  it uses the -isEqual: method to determine if the object needs to be reloaded
- (SCCChangeSet *)changesetFromArray_scc:(NSArray *)originalArray uniqueKeyPath:(NSString *)uniqueKeyPath;

@end
