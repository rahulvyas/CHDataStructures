/*
 CHRedBlackTreeTest.m
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHRedBlackTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

#pragma mark -

@interface CHRedBlackTree (Test)

- (BOOL) verify;
- (NSUInteger) verifySubtreeAtNode:(CHTreeNode*)node;

@end

@implementation CHRedBlackTree (Test)

- (BOOL) verify {
	sentinel->object = nil;
	return ([self verifySubtreeAtNode:header->right] != 0);
}

// Recursive method for verifying that red-black properties are not violated.
- (NSUInteger) verifySubtreeAtNode:(CHTreeNode*)node {
	if (node == sentinel)
		return 1;
	/* Test for consecutive red links */
	if (node->color == kRED) {
		if (node->left->color == kRED || node->right->color == kRED) {
			[NSException raise:NSInternalInconsistencyException
						format:@"Consecutive red below %@", node->object];
		}
	}
	NSUInteger leftBlackHeight  = [self verifySubtreeAtNode:node->left];
	NSUInteger rightBlackHeight = [self verifySubtreeAtNode:node->left];
	/* Test for invalid binary search tree */
	if ([node->left->object compare:(node->object)] == NSOrderedDescending ||
		[node->right->object compare:(node->object)] == NSOrderedAscending)
	{
		[NSException raise:NSInternalInconsistencyException
		            format:@"Binary tree violation below %@", node->object];
	}
	/* Test for black height mismatch */
	if (leftBlackHeight != rightBlackHeight && leftBlackHeight != 0) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"Black height violation below %@", node->object];
	}
	/* Count black links */
	if (leftBlackHeight != 0 && rightBlackHeight != 0)
		return (node->color == kRED) ? leftBlackHeight : leftBlackHeight + 1;
	else
		return 0;
}

@end

#pragma mark -

@interface CHRedBlackTreeTest : SenTestCase {
	CHRedBlackTree *tree;
	NSArray *objects, *order, *correct;
}
@end

@implementation CHRedBlackTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
	tree = [[CHRedBlackTree alloc] init];
	objects = [NSArray arrayWithObjects:@"B",@"M",@"C",@"K",@"D",@"I",@"E",@"G",
			   @"J",@"L",@"N",@"F",@"A",@"H",nil];
	// When inserted in this order, creates the tree from: Weiss pg. 631 
}

- (void) tearDown {
	[tree release];
}

#pragma mark -

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	NSEnumerator *e = [objects objectEnumerator];
	NSUInteger count = 0;
	STAssertEquals([tree count], count, @"Incorrect count.");
	
	[tree addObject:[e nextObject]]; // B
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"B",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // M
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"B",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // C
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // K
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"M",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // D
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // I
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"K",@"D",@"M",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // E
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"K",@"E",@"M",@"D",@"I",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // G
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // J
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // L
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",@"L",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // N
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",@"L",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // F
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"G",
			   @"J",@"L",@"N",@"F",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // A
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",
			   @"G",@"J",@"L",@"N",@"F",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	[tree addObject:[e nextObject]]; // H
	STAssertEquals([tree count], ++count, @"Incorrect count.");
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",
			   @"G",@"J",@"L",@"N",@"F",@"H",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
}

- (void) testAddObjectsAscending {
	objects = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",nil];
	for (id anObject in objects)
		[tree addObject:anObject];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"H",@"D",@"L",@"B",@"F",@"J",@"N",@"A",
			   @"C",@"E",@"G",@"I",@"K",@"M",@"P",@"O",@"Q",@"R",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
}

- (void) testAddObjectsDescending {
	objects = [NSArray arrayWithObjects:@"R",@"Q",@"P",@"O",@"N",@"M",@"L",@"K",
			   @"J",@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	for (id anObject in objects)
		[tree addObject:anObject];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"K",@"G",@"O",@"E",@"I",@"M",@"Q",@"C",
			   @"F",@"H",@"J",@"L",@"N",@"P",@"R",@"B",@"D",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level order", order, correct));
	STAssertNoThrow([tree verify], @"Not a valid red-black tree!");
}

- (void) testAllObjectsWithTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Ascending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
	correct = [NSArray arrayWithObjects:@"N",@"M",@"L",@"K",@"J",@"I",@"H",@"G",
			   @"F",@"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Descending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"B",@"A",@"D",@"K",@"I",@"G",
			   @"F",@"H",@"J",@"M",@"L",@"N",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraversePostOrder];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"D",@"C",@"F",@"H",@"G",@"J",
			   @"I",@"L",@"N",@"M",@"K",@"E",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Post-order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"K",@"B",@"D",@"I",@"M",@"A",
			   @"G",@"J",@"L",@"N",@"F",@"H",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Level-order", order, correct));
}

- (void) testRemoveObject {
	for (id object in objects)
		[tree addObject:object];

	// Test removing nil
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");
	
	// Test removing a node which doesn't occur in the tree
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	
	NSUInteger count = [objects count];
	for (id anObject in objects) {
		[tree removeObject:anObject];
		STAssertEquals([tree count], --count, @"Incorrect count.");
		STAssertNoThrow([tree verify], @"Not a valid red-black tree: %@",
						[tree debugDescription]);
	}
}

- (void) testDebugDescriptionForNode {
	CHTreeNode *node = malloc(kCHTreeNodeSize);
	node->object = [NSString stringWithString:@"A B C"];
	node->color = kRED;
	STAssertEqualObjects([tree debugDescriptionForNode:node],
						 @"[ RED ]	\"A B C\"", nil);
}

- (void) testDotStringForNode {
	CHTreeNode *node = malloc(kCHTreeNodeSize);
	node->object = [NSString stringWithString:@"A B C"];
	node->color = kRED;
	STAssertEqualObjects([tree dotStringForNode:node],
						 @"  \"A B C\" [color=red];\n", nil);
}

@end
