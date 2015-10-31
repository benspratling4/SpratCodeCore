//
//  NSArray+SCCAdditions.m
//  Presentation Calibration
//
//  Created by Ben Spratling on 5/3/15.
//  Copyright (c) 2015 benspratling.com. All rights reserved.
//

#import "NSArray+SCCAdditions.h"

@implementation SCCChangeSet

@end


@implementation NSArray (SpratCodeCore)

- (SCCChangeSet *)changesetFromArray_scc:(NSArray *)originalArray {
	NSUInteger newIndex = 0;
	NSUInteger oldIndex = 0;
	
	//indexes in the originalArray of strings which are not present in self
	NSMutableIndexSet* removedIndexes = [NSMutableIndexSet new];
	
	//indexes of strings in self which are not present in originalArray
	NSMutableIndexSet* insertedIndexes = [NSMutableIndexSet new];
	
	//make quick look up of the indexes from originalArray
	NSMutableDictionary* oldIndexes = [NSMutableDictionary new];
	for (NSString* string in originalArray) {
		oldIndexes[string] = @(oldIndex);
		oldIndex++;
	}
	
	//1) make the list of new indexes, and go ahead and mark strings with no corresponding old index as inserted
	NSMutableDictionary* newIndexes = [NSMutableDictionary new];
	for (NSString* string in self) {
		newIndexes[string] = @(newIndex);
		if (!oldIndexes[string]) {	//we've already built the original index, might as well check if these have been replaced.
			[insertedIndexes addIndex:newIndex];
		}
		newIndex++;
	}
	
	//get a list of removed indexes, which we know if they aren't in newIndexes
	oldIndex = 0;
	for (NSString* string in originalArray) {
		if (!newIndexes[string]) {
			[removedIndexes addIndex:oldIndex];
		}
		oldIndex++;
	}
	
	//now we only have to find the re-orders.
	//.... which are defined as the objects in the new array, which aren't where the additions and subtractions say they would be
	oldIndex = 0;
	newIndex = 0;
	
	BOOL exhaustedOld = NO;
	BOOL exhaustedNew = NO;
	
	//keys are original index number, values are new index number
	NSMapTable* movedMapTable = [NSMapTable strongToStrongObjectsMapTable];
	
	//keys are new index #, values are old number
	NSMapTable* reversedMovedMapTable = [NSMapTable strongToStrongObjectsMapTable];
	
	while (YES) {
		if (oldIndex == originalArray.count) {
			exhaustedOld = YES;
			break;
		}
		
		if (newIndex == self.count) {
			exhaustedNew = YES;
			break;
		}
		
		//if we're at a removed index, advance the old pointer and continue
		if ([removedIndexes containsIndex:oldIndex]) {
			oldIndex++;
			continue;
		}
		
		//if we inserted this index, advance the new pointer and continue
		if ([insertedIndexes containsIndex:newIndex]) {
			newIndex++;
			continue;
		}
		
		//if these string are not equal, we re-ordered something
		NSString* newString = self[newIndex];
		NSString* oldString = originalArray[oldIndex];
		
		if ([newString isEqualToString:oldString]) {
			newIndex++;
			oldIndex++;
			continue;
		}
		
		//if they are not equal, it was reordered something
		//check if we already knew this new string was moved in place.
		if ([reversedMovedMapTable objectForKey:@(newIndex)] != nil) {
			//we already knew about this move, skip it
			newIndex++;
			continue;
		}
		
		//figure out where we moved this string
		NSUInteger stringsNewPosition = [newIndexes[oldString] integerValue];
		//make note of the move
		[movedMapTable setObject:@(stringsNewPosition) forKey:@(oldIndex)];
		[reversedMovedMapTable setObject:@(oldIndex) forKey:@(stringsNewPosition)];
		
		oldIndex++;
	}
	
	SCCChangeSet* changeset = [SCCChangeSet new];
	
	changeset.removedIndexes = removedIndexes;
	changeset.insertedIndexes = insertedIndexes;
	changeset.movingMapTable = movedMapTable;
	return changeset;
}


- (SCCChangeSet *)changesetFromArray_scc:(NSArray *)originalArray uniqueKeyPath:(NSString *)uniqueKeyPath {
	NSMutableDictionary* oldArrayMapTable = [NSMutableDictionary new];
	for (NSObject* anObject in self) {
		NSString* key = [anObject valueForKeyPath:uniqueKeyPath];
		oldArrayMapTable[key] = anObject;
	}
	NSArray* originalUniques = [originalArray valueForKeyPath:uniqueKeyPath];
	NSArray* currentUniques = [self valueForKeyPath:uniqueKeyPath];
	SCCChangeSet* regularChangeSet = (SCCChangeSet *)[currentUniques changesetFromArray_scc:originalUniques];

	//now check all non-inserted objects for equality
	NSMutableIndexSet* reloadIndexes = [NSMutableIndexSet new];
	NSUInteger currentIndex = 0;
	for (NSObject* anObject in self) {
		NSString* uniqueKey = [anObject valueForKeyPath:uniqueKeyPath];
		NSObject* oldObject = oldArrayMapTable[uniqueKey];
		if (oldObject) {
			if (![anObject isEqual:oldObject]) {
				[reloadIndexes addIndex:currentIndex];
			}
		}
		currentIndex++;
	}
	regularChangeSet.reloadIndexes = reloadIndexes;
	return regularChangeSet;
}


@end
