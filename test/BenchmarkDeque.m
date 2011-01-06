//
//  BenchmarkDeque.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkDeque.h"
#import "BenchmarkUtils.h"
#import <CHDataStructures/CHDataStructures.h>


@implementation BenchmarkDeque

- (void) testClass:(Class)testClass {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	double startTime;
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHDeque> deque;
	
	printf("(Operation)         ");
	for (NSArray * array in objects) {
		printf("\t%-8lu", (unsigned long)[array count]);
	}
	
	printf("\nprependObject:    ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		[deque prependObjectsFromArray:array];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		[deque appendObjectsFromArray:array];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		[deque appendObjectsFromArray:array];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++) {
			[deque removeFirstObject];
		}
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveLastObject:  ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		[deque appendObjectsFromArray:array];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++) {
			[deque removeLastObject];
		}
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		[deque appendObjectsFromArray:array];
		startTime = timestamp();
		[deque removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		[deque appendObjectsFromArray:array];
		startTime = timestamp();
		NSEnumerator * objectEnumerator = [deque objectEnumerator];
		while ([objectEnumerator nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray * array in objects) {
		deque = [[testClass alloc] init];
		[deque appendObjectsFromArray:array];
		startTime = timestamp();
		for (id object in deque)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}


- (void) runWithTestObjects:(NSArray *)testObjects {
	CHQuietLog(@"\n<CHDeque> Implemenations");
	
	objects = [testObjects retain];
	
	[self testClass:[CHCircularBufferDeque class]];
	[self testClass:[CHListDeque class]];
	
	[objects release], objects = nil;
}

+ (NSUInteger) executionOrder { return 1; }

@end
