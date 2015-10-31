//
//  NSObject+SCCAdditions.h
//  SpratCodeCore
//
//  Created by Ben Spratling on 3/21/14.
//  Copyright (c) 2014 Ben Spratling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SpratCodeCore)

/// This method returns self for all objects except instances of NSNull
- (instancetype)nullFilter_scc;

@end
