//
//  BenchmarkHeap.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkHeap.h"
#import "BenchmarkUtils.h"
#import <CHDataStructures/CHDataStructures.h>

@implementation BenchmarkHeap

- (void) testClass:(Class)testClass {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHHeap> heap;
	double startTime;
	
	printf("(Operation)         ");
	for (NSArray * array in objects) {
		printf("\t%-8lu", (unsigned long)[array count]);
	}
	
	printf("\naddObject:          ");
	for (NSArray * array in objects) {
		heap = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[heap addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (NSArray * array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[heap removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray * array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		[heap removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	printf("\nNSEnumerator       ");
	for (NSArray * array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [heap objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray * array in objects) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (id object in heap)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

- (void) runWithTestObjects:(NSArray *)testObjects {
	CHQuietLog(@"\n<CHHeap> Implemenations");
	
	objects = [testObjects retain];
	
	[self testClass:[CHMutableArrayHeap class]];
	[self testClass:[CHBinaryHeap class]];
	
	[objects release], objects = nil;
}

+ (NSUInteger) executionOrder { return 4; }

@end
