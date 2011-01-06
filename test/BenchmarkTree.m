//
//  BenchmarkTree.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkTree.h"
#import "BenchmarkUtils.h"
#import <CHDataStructures/CHDataStructures.h>

@implementation BenchmarkTree

- (void) testClass:(Class)testClass {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHSearchTree> tree;
	double startTime;
	
	printf("(Operation)         ");
	for (NSArray * array in objects) {
		printf("\t%-8lu", (unsigned long)[array count]);
	}	
	
	printf("\naddObject:          ");
	for (NSArray * array in objects) {
		tree = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[tree addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nmember:         ");
	for (NSArray * array in objects) {
		tree = [[testClass alloc] initWithArray:array];
		startTime = timestamp();
		for (id anObject in array)
			[tree member:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nremoveObject:       ");
	for (NSArray * array in objects) {
		tree = [[testClass alloc] initWithArray:array];
		startTime = timestamp();
		for (id anObject in array)
			[tree removeObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nNSEnumerator       ");
	for (NSArray * array in objects) {
		tree = [[testClass alloc] init];
		for (id anObject in array)
			[tree addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [tree objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	CHQuietLog(@"");
	[pool drain];	
}

- (void) runWithTestObjects:(NSArray *)testObjects {
	objects = [testObjects retain];
	
	CHQuietLog(@"-[%@ %@] has not been implemented", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	[objects release], objects = nil;
}

@end
