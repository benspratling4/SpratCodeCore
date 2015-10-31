//
//  SCCArrayController.m
//  SpratCodeCore
//
//  Created by Ben Spratling on 9/14/15.
//  Copyright (c) 2015 recoveryfriendfinder.com. All rights reserved.
//

#import "SCCArrayController.h"

#import "NSArray+SCCAdditions.h"

//this is the object returned by the
@interface SCCArrayControllerHandlerOwner : NSObject 

@property (copy) SCCArrayControllerHandler handler;

@end


@interface SCCArrayController ()

@property (strong) NSMutableArray* privateContents;

@property (strong) NSPointerArray* handlerOwners;

@end


@implementation SCCArrayController

- (instancetype)init {
	self = [super init];
	if (self) {
		_handlerOwners = [NSPointerArray weakObjectsPointerArray];
		_privateContents = [NSMutableArray new];
	}
	return self;
}


- (void)performChangeSet:(SCCChangeSet *)changeSet withInsertedObjects:(NSArray *)insertedObjects {
	
	//get all the indexes of things which need t be removed
	NSMutableIndexSet* allRemovedIndexes = [changeSet.removedIndexes mutableCopy];
	if (!allRemovedIndexes) {
		allRemovedIndexes = [NSMutableIndexSet new];
	}
	
	//add the indexes of the objects which are moved, since we need to remove them
	NSMutableIndexSet* movedIndexes = [NSMutableIndexSet new];
	NSMapTable* reverseMapMovedObjects = [NSMapTable strongToStrongObjectsMapTable];	//a table containing the moved object based on the destination index
	NSMutableIndexSet* destinationMovedIndexes = [NSMutableIndexSet new];
	if (changeSet.movingMapTable) {
		NSNumber* aNumber;
		while ((aNumber = changeSet.movingMapTable.keyEnumerator.nextObject)) {
			NSNumber* destinationNumber = [changeSet.movingMapTable objectForKey:aNumber];
			[movedIndexes addIndex:aNumber.integerValue];
			[destinationMovedIndexes addIndex:destinationNumber.integerValue];
			[reverseMapMovedObjects setObject:_privateContents[aNumber.integerValue] forKey:destinationNumber];
		}
	}
	[allRemovedIndexes addIndexes:movedIndexes];
	[_privateContents removeObjectsAtIndexes:allRemovedIndexes];
	
	NSMutableIndexSet* allInsertedIndexes = [NSMutableIndexSet new];
	[allInsertedIndexes addIndexes:destinationMovedIndexes];
	if (changeSet.insertedIndexes) {
		[allInsertedIndexes addIndexes:changeSet.insertedIndexes];
	}
	
	__block NSUInteger insertedObjectCount = 0;
	[allInsertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		//insert the object either from the moved map or from the inserted array
		if ([destinationMovedIndexes containsIndex:idx]) {
			NSObject* movedObject = [reverseMapMovedObjects objectForKey:@(idx)];
			[_privateContents insertObject:movedObject atIndex:idx];
		} else {
			NSObject* insertedObject = insertedObjects[insertedObjectCount];
			[_privateContents insertObject:insertedObject atIndex:idx];
			insertedObjectCount++;
		}
	}];
	
	[self executeHandlers:changeSet];
}


- (void)executeHandlers:(SCCChangeSet*)changeSet {
	[_handlerOwners compact];
	NSArray* handlerOwners = _handlerOwners.allObjects;
	for (SCCArrayControllerHandlerOwner* handlerOwner in handlerOwners) {
		handlerOwner.handler(changeSet);
	}
}


- (id)registerForChanges:(SCCArrayControllerHandler)handler {
	if (!handler) {
		return nil;
	}
	SCCArrayControllerHandlerOwner* handlerOwner = [SCCArrayControllerHandlerOwner new];
	handlerOwner.handler = handler;
	[_handlerOwners addPointer:(__bridge void *)(handlerOwner)];
	return handlerOwner;
}


- (NSArray *)contents {
	return [_privateContents copy];
}

@end


@implementation SCCMutableArrayController

- (instancetype)initWithUniqueKeyPath:(NSString *)uniqueKeyPath {
	self = [super init];
	if (self) {
		_uniqueKeyPath = uniqueKeyPath;
	}
	return self;
}


- (void)setContents:(NSArray *)contents {
	//calculate a change from the previous array value, replaces the array, and executes the handlers
	
	NSArray* oldUniqueIdentifierArray = [self.privateContents valueForKeyPath:_uniqueKeyPath];
	NSArray* newUniqueIdentifierArray = [contents valueForKeyPath:_uniqueKeyPath];
	
	SCCChangeSet* changeSet = (SCCChangeSet*)[newUniqueIdentifierArray changesetFromArray_scc:oldUniqueIdentifierArray];
	self.privateContents = contents.mutableCopy;
	
	[self executeHandlers:changeSet];
}

@end


@implementation SCCArrayControllerHandlerOwner

@end