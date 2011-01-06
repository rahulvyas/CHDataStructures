//
//  BenchmarkQueue.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkQueue.h"
#import "BenchmarkUtils.h"
#import <CHDataStructures/CHDataStructures.h>

@implementation BenchmarkQueue

- (void) testClass:(Class)testClass {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHQueue> queue;
	double startTime;
	
	printf("(Operation)         ");
	for (NSArray * array in objects) {
		printf("\t%-8lu", (unsigned long)[array count]);
	}
	
	printf("\naddObject:         ");
	for (NSArray * array in objects) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[queue addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (NSArray * array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[queue removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray * array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray * array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [queue objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray * array in objects) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		for (id object in queue)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

- (void) runWithTestObjects:(NSArray *)testObjects {
	CHQuietLog(@"\n<CHQueue> Implemenations");
	
	objects = [testObjects retain];
	[self testClass:[CHCircularBufferQueue class]];
	[self testClass:[CHListQueue class]];
	[objects release], objects = nil;
}

+ (NSUInteger) executionOrder { return 2; }

@end
