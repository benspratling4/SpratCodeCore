//
//  SCCKVObserver.m
//  SpratCodeCore
//
//  Created by Ben Spratling on 3/21/14.
//  Copyright (c) 2014 Ben Spratling. All rights reserved.
//

#import "SCCKVObserver_Private.h"

#import "NSObject+SCCAdditions.h"

@implementation SCCKVObserver

- (instancetype)initWithDelegate:(NSObject *)theDelegate key:(NSString *)theKey observedObject:(NSObject *)theObservedObject action:(SCCKVObserverDidChange)action
{
	self = [super init];
	
	self.delegate = theDelegate;
	self.key = theKey;
	self.observedObject = theObservedObject;
	self.didChangeAction = action;
	
	[self.observedObject addObserver:self
						  forKeyPath:self.key
							 options:NSKeyValueObservingOptionOld
							 context:(__bridge void *)self];
	
	SCCKVObserverHelper* helper = [SCCKVObserverHelper new];
	helper.observer = self;
	helper.observedObject = self.observedObject;
	self.helper = helper;
	objc_setAssociatedObject(self.observedObject, (__bridge const void *)(self), helper, OBJC_ASSOCIATION_RETAIN );
	
	return self;
}


- (instancetype)initWithDelegate:(NSObject *)theDelegate key:(NSString *)theKey observedObject:(NSObject *)theObservedObject changesAction:(SCCKVObserverChanges)theChangesAction {
	self = [super init];
	
	self.delegate = theDelegate;
	self.key = theKey;
	self.observedObject = theObservedObject;
	self.changesAction = theChangesAction;
	
	[self.observedObject addObserver:self
						  forKeyPath:self.key
							 options:NSKeyValueObservingOptionOld
							 context:(__bridge void *)self];
	
	SCCKVObserverHelper* helper = [SCCKVObserverHelper new];
	helper.observer = self;
	helper.observedObject = self.observedObject;
	self.helper = helper;
	objc_setAssociatedObject(self.observedObject, (__bridge const void *)(self), helper, OBJC_ASSOCIATION_RETAIN );
	
	return self;
}


+ (SCCKVObserver *)observerWithDelegate:(NSObject *)theDelegate key:(NSString *)theKey observedObject:(NSObject *)theObservedObject action:(SCCKVObserverDidChange)action
{
	SCCKVObserver* observer = [[SCCKVObserver alloc] initWithDelegate:theDelegate key:theKey observedObject:theObservedObject action:action];
	return observer;
}


+ (SCCKVObserver *)observerWithDelegate:(NSObject *)theDelegate
									key:(NSString *)theKey
						 observedObject:(NSObject *)theObservedObject
						  changesAction:(SCCKVObserverChanges)theAction {
	SCCKVObserver* observer = [[SCCKVObserver alloc] initWithDelegate:theDelegate key:theKey observedObject:theObservedObject changesAction:theAction];
	return observer;
}


- (void)dealloc
{
	NSObject* observedObject = self.observedObject;
	if (!observedObject)
	{
		[self.helper.observedObject removeObserver:self forKeyPath:self.key context:(__bridge void *)(self)];
		self.helper.observedObject = nil;
	}
	else
		[observedObject removeObserver:self forKeyPath:self.key context:(__bridge void *)(self)];
	
	if (observedObject)
		objc_setAssociatedObject(observedObject, (__bridge const void *)(self), nil, OBJC_ASSOCIATION_RETAIN );
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self informDelegateOfChange:change];
}


- (void)informDelegateOfChange:(NSDictionary *)theChange
{
	if (nil != self.didChangeAction) {
		NSObject* oldValue = [theChange[NSKeyValueChangeOldKey] nullFilter_scc];
		self.didChangeAction(self, oldValue);
	} else if (nil != self.changesAction) {
		self.changesAction(self, theChange);
	}
}


//will not get called during -dealloc because our weak reference, held by the helper, is already nil
- (void)observerHelperIsDeallocing:(SCCKVObserverHelper *)helper
{
	[helper.observedObject removeObserver:self forKeyPath:self.key context:(__bridge void *)(self)];
	helper.observedObject = nil;
}

@end


@implementation NSObject (SCCKVObserver)

- (SCCKVObserver *)observerWithDelegate_scc:(NSObject *)theDelegate
										key:(NSString *)theKey
									 action:(SCCKVObserverDidChange)theAction
{
	return [SCCKVObserver observerWithDelegate:theDelegate key:theKey observedObject:self action:theAction];
}

- (SCCKVObserver *)observerWithDelegate_scc:(NSObject *)theDelegate
										key:(NSString *)theKey
									 changesAction:(SCCKVObserverChanges)changesAction {
	return [SCCKVObserver observerWithDelegate:theDelegate key:theKey observedObject:self changesAction:changesAction];
}


static unsigned char _observerDictionaryKey;

- (NSMutableDictionary *)bsc_observerDictionary
{
	NSMutableDictionary* existingDictionary = objc_getAssociatedObject(self, &_observerDictionaryKey);
	if (!existingDictionary)
	{
		existingDictionary = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &_observerDictionaryKey, existingDictionary, OBJC_ASSOCIATION_RETAIN);
	}
	return existingDictionary;
}


- (SCCKVObserver *)observerForKeyPath_scc:(NSString *)theKeyPath
{
	return [self bsc_observerDictionary][theKeyPath];
}


- (void)stopObservingKeyPath_scc:(NSString *)theKeyPath
{
	[[self bsc_observerDictionary] removeObjectForKey:theKeyPath];
}


- (void)observeKeyPath_scc:(NSString *)theKeyPath action:(SCCKVObserverDidChange)action
{
	//if there is more than one component in the path, take the first component as the object to be observed?
	SCCKVObserver* observer = [SCCKVObserver observerWithDelegate:self key:theKeyPath observedObject:self action:action];
	[self bsc_observerDictionary][theKeyPath] = observer;
}

@end


@implementation SCCKVObserverHelper

- (void)dealloc
{
	[self.observer observerHelperIsDeallocing:self];
}

@end
