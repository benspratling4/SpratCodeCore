//
//  SCCKVObserver.h
//  SpratCodeCore
//
//  Created by Ben Spratling on 3/21/14.
//  Copyright (c) 2014 Ben Spratling. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class SCCKVObserver
 @abstract SCCKVObserver simplifies and adds rigour to the use of Key-Value Observing.
 @discussion In addition to clearing up code by providing simplified methods for obtaining observers,
 SCCKVObserver also makes the removal of exactly the observers you add rigorous.  If you accidentally deallocate the object it observes first, it notices and removes the KV Observation.
 SCCKVObserver does not retain the object being observed, so it does not interfere in the ownserhip graph you have already developed.
 It also allows you to get rid of a centralized call back and use methods dynamically named by the key names themselves.
 
 To use a SCCKVObserver, ask the object being observed for an observer, and hold it strongly until you are done.
 Implement a method with the signature SCCKVObserver:(SCCKVObserver *) <key>DidChange:(NSObject *)theOldObjectValue for each value you track.  If you do not implement this method, the creation methods will return nil.
 */


@class SCCKVObserver;
typedef void (^SCCKVObserverDidChange)(SCCKVObserver* observer, NSObject* oldValue);

typedef void (^SCCKVObserverChanges)(SCCKVObserver* observer, NSDictionary* change);

@interface SCCKVObserver : NSObject

///The object which recieves the notifications
@property (weak, readonly) NSObject* delegate;

///The keypath of the observation
@property (copy, readonly) NSString* key;

///the object whose property is observed
@property (weak, readonly) NSObject* observedObject;

+ (SCCKVObserver *)observerWithDelegate:(NSObject *)theDelegate
									key:(NSString *)theKey
						 observedObject:(NSObject *)theObservedObject
								 action:(SCCKVObserverDidChange)theAction;

+ (SCCKVObserver *)observerWithDelegate:(NSObject *)theDelegate
									key:(NSString *)theKey
						 observedObject:(NSObject *)theObservedObject
						  changesAction:(SCCKVObserverChanges)theAction;

@end



@interface NSObject (SCCKVObserver)

/// Convenience method for obtaining an observer on any object.
- (SCCKVObserver *)observerWithDelegate_scc:(NSObject *)theDelegate
										key:(NSString *)theKey
									 action:(SCCKVObserverDidChange)theAction;

- (SCCKVObserver *)observerWithDelegate_scc:(NSObject *)theDelegate
										key:(NSString *)theKey
									 changesAction:(SCCKVObserverChanges)changesAction;

- (void)observeKeyPath_scc:(NSString *)theKeyPath
					action:(SCCKVObserverDidChange)action;

- (void)stopObservingKeyPath_scc:(NSString *)theKeyPath;

@end
