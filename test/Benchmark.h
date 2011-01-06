//
//  Benchmark.h
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol Benchmark <NSObject>

@required
- (void) runWithTestObjects:(NSArray *)testObjects;
+ (NSUInteger) executionOrder;

@end
