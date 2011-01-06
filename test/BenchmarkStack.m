//
//  BenchmarkStack.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkStack.h"
#import "BenchmarkUtils.h"
#import <CHDataStructures/CHDataStructures.h>

@implementation BenchmarkStack

- (void) testClass:(Class)testClass {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHStack> stack;
	double startTime;
	
	printf("(Operation)         ");
	for (NSArray * array in objects) {
		printf("\t%-8lu", (unsigned long)[array count]);
	}
	
	printf("\npushObject:       ");
	for (NSArray * array in objects) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[stack pushObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	for (NSArray * array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[stack popObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (NSArray * array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray * array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [stack objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (NSArray * array in objects) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

- (void) runWithTestObjects:(NSArray *)testObjects {
	CHQuietLog(@"\n<CHStack> Implemenations");
	
	objects = [testObjects retain];
	
	[self testClass:[CHCircularBufferStack class]];
	[self testClass:[CHListStack class]];
	
	[objects release], objects = nil;
}

+ (NSUInteger) executionOrder { return 3; }

@end
