//
//  SCCKVObserver_Private.h
//  BSCommon
//
//  Created by Ben Spratling on 3/21/14.
//  Copyright (c) 2014 Ben Spratling. All rights reserved.
//

#import "SCCKVObserver.h"

#import <objc/runtime.h>

@class SCCKVObserverHelper;

@interface SCCKVObserver ()

@property (weak, readwrite) NSObject* delegate;
@property (copy, readwrite) NSString* key;
@property (weak, readwrite) NSObject* observedObject;
@property (weak) SCCKVObserverHelper* helper;
@property (copy) SCCKVObserverDidChange didChangeAction;
@property (copy) SCCKVObserverChanges changesAction;

- (instancetype)initWithDelegate:(NSObject *)theDelegate key:(NSString *)theKey observedObject:(NSObject *)theObservedObject action:(SCCKVObserverDidChange)theAction;

- (instancetype)initWithDelegate:(NSObject *)theDelegate key:(NSString *)theKey observedObject:(NSObject *)theObservedObject changesAction:(SCCKVObserverChanges)theChangesAction;

@end


//interface for a helper class
@interface SCCKVObserverHelper : NSObject

///This must be unsafe unretained, because weak references becomes nil at the beginning of their dealloc, before this object gets released (and hence triggered)
@property (unsafe_unretained) NSObject* observedObject;

///
@property (weak) SCCKVObserver* observer;

@end
