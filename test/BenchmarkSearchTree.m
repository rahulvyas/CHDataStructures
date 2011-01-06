//
//  BenchmarkSearchTree.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkSearchTree.h"
#import "BenchmarkUtils.h"
#import <CHDataStructures/CHDataStructures.h>
#import <objc/runtime.h>

@interface CHAbstractBinarySearchTree (Height)
- (NSUInteger) height;
- (NSUInteger) heightOfSubtreeAtNode:(CHBinaryTreeNode*)node;
@end

@implementation CHAbstractBinarySearchTree (Height)

- (NSUInteger) height {
	return [self heightOfSubtreeAtNode:header->right];
}

- (NSUInteger) heightOfSubtreeAtNode:(CHBinaryTreeNode*)node {
	if (node == sentinel)
		return 0;
	else {
		NSUInteger leftHeight = [self heightOfSubtreeAtNode:node->left];
		NSUInteger rightHeight = [self heightOfSubtreeAtNode:node->right];
		return ((leftHeight > rightHeight) ? leftHeight : rightHeight) + 1;
	}
}

@end


@implementation BenchmarkSearchTree


- (NSArray *) randomNumberArrayOfSize:(NSUInteger)size {
	NSMutableSet *objectSet = [NSMutableSet set];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while ([objectSet count] < size) {
		[objectSet addObject:[NSNumber numberWithInt:arc4random()]];
	}
	[pool drain];
	return [objectSet allObjects];
}

- (void) runWithTestObjects:(NSArray *)testObjects {
	CHQuietLog(@"\n<CHSearchTree> Implemenations");
	
	NSArray *testClasses = [NSArray arrayWithObjects:
							[CHAnderssonTree class],
							[CHAVLTree class],
							[CHRedBlackTree class],
							[CHTreap class],
							[CHUnbalancedTree class],
							nil];
	NSMutableDictionary *treeResults = [NSMutableDictionary dictionary];
	for (Class aClass in testClasses) {
		NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
		[dictionary setObject:[NSMutableArray array] forKey:@"addObject"];
		[dictionary setObject:[NSMutableArray array] forKey:@"member"];
		[dictionary setObject:[NSMutableArray array] forKey:@"removeObject"];
		if ([aClass conformsToProtocol:@protocol(CHSearchTree)]) {
			[dictionary setObject:[NSMutableArray array] forKey:@"height"];
		}
		[treeResults setObject:dictionary forKey:NSStringFromClass(aClass)];
	}
	
	CHAbstractBinarySearchTree *tree;
	double duration;
	struct timespec sleepDelay = {0,1}, sleepRemain;
	
	NSUInteger jitteredSize; // For making sure scatterplot dots do not overlap
	NSInteger jitterOffset;
	
	NSUInteger limit = 100000;
	NSUInteger reps  = 20;
	NSUInteger scale = 1000000; // 10^6, which gives microseconds
	
	for (NSUInteger trial = 1; trial <= reps; trial++) {
		printf("\nPass %lu / %lu", (unsigned long)trial, (unsigned long)reps);
		for (NSUInteger size = 10; size <= limit; size *= 10) {
			printf("\n%8lu objects --", (unsigned long)size);
			// Create a set of N unique random numbers
			NSArray *randomNumbers = [self randomNumberArrayOfSize:size];
			jitterOffset = -([testClasses count]/2);
			for (Class aClass in testClasses) {
				NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
				printf(" %s", class_getName(aClass));
				tree = [[aClass alloc] init];
				NSDictionary * dictionary = [treeResults objectForKey:NSStringFromClass(aClass)];
				jitteredSize = size + ((size / 10) * jitterOffset++);
				
				// addObject:
				nanosleep(&sleepDelay, &sleepRemain);
				double startTime = timestamp();
				for (id anObject in randomNumbers)
					[tree addObject:anObject];
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"addObject"] addObject:[NSString stringWithFormat:@"%lu,%f", jitteredSize, duration/size*scale]];
				
				// containsObject:
				nanosleep(&sleepDelay, &sleepRemain);
				NSUInteger index = 0;
				startTime = timestamp();
				for (id anObject in randomNumbers) {
					if (index++ % 4 != 0)
						continue;
					[tree containsObject:anObject];
				}
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"member"] addObject:[NSString stringWithFormat:@"%lu,%f", jitteredSize, duration/size*scale]];
				
				// Maximum height
				if ([aClass conformsToProtocol:@protocol(CHSearchTree)])
					[[dictionary objectForKey:@"height"] addObject:[NSString stringWithFormat:@"%lu,%lu", jitteredSize, [tree height]]];
				
				// removeObject:
				nanosleep(&sleepDelay, &sleepRemain);
				startTime = timestamp();
				for (id anObject in randomNumbers)
					[tree removeObject:anObject];
				duration = timestamp() - startTime;
				[[dictionary objectForKey:@"removeObject"] addObject:[NSString stringWithFormat:@"%lu,%f", jitteredSize, duration/size*scale]];
				
				[tree release];
				[pool2 drain];
			}
		}
	}
	
	NSString *path = @"../../benchmark_data/";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager createDirectoryAtPath:path
			   withIntermediateDirectories:YES
								attributes:nil
									 error:NULL];
	}
	
	for (NSString * className in treeResults) {
		NSDictionary *resultSet = [treeResults objectForKey:className];
		for (NSString * operation in resultSet) {
			NSArray *results = [resultSet objectForKey:operation];
			results = [results sortedArrayUsingSelector:@selector(compare:)];
			NSString * resultsString = [results componentsJoinedByString:@"\n"];
			[resultsString writeToFile:[path stringByAppendingFormat:@"%@-%@.txt", className, operation]
							atomically:NO
							  encoding:NSUTF8StringEncoding
								 error:NULL];
		}
	}
}

+ (NSUInteger) executionOrder { return 5; }

@end
