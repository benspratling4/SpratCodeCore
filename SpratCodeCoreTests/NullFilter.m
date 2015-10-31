//
//  NullFitler.m
//  SpratCodeCore
//
//  Created by Ben Spratling on 10/31/15.
//  Copyright (c) 2015 benspratling.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SpratCodeCore.h"

@interface NullFitler : XCTestCase

@end

@implementation NullFitler

- (void)testNSNull {
	
	XCTAssertNil([[NSNull null] nullFilter_scc], "");
}

- (void)testNSObject {
	NSObject* anObject = [NSObject new];
	XCTAssert([anObject nullFilter_scc] == anObject, "");
}

@end
