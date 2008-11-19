/*
 CHTreapTest.m
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
#import "CHTreap.h"

static NSString* badOrder(NSString *traversal, NSArray *order, NSArray *correct) {
	return [[[NSString stringWithFormat:@"%@ should be %@, was %@",
			  traversal, correct, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

#pragma mark -

@interface CHTreap (Test)

- (void) verify;
- (void) verifySubtreeAtNode:(CHTreeNode*)node;

@end

@implementation CHTreap (Test)

- (void) verify {
	[self verifySubtreeAtNode:header->right]; // Raises an exception on error
}

// Recursive method for verifying that BST and heap properties are not violated.
- (void) verifySubtreeAtNode:(CHTreeNode*)node {
	if (node == sentinel)
		return;
	
	if (node->left != sentinel) {
		// Verify BST property
		if ([node->left->object compare:node->object] == NSOrderedDescending)
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation left of %@", node->object];
		// Verify heap property
		if (node->left->priority > node->priority)
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation left of %@", node->object];
		// Recursively verity left subtree
		[self verifySubtreeAtNode:node->left];
	}
	
	if (node->right != sentinel) {
		// Verify BST property
		if ([node->right->object compare:node->object] == NSOrderedAscending)
			[NSException raise:NSInternalInconsistencyException
			            format:@"BST violation right of %@", node->object];
		// Verify heap property
		if (node->right->priority > node->priority)
			[NSException raise:NSInternalInconsistencyException
			            format:@"Heap violation right of %@", node->object];
		// Recursively verity right subtree
		[self verifySubtreeAtNode:node->right];
	}
}

@end

#pragma mark -

@interface CHTreapTest : SenTestCase {
	CHTreap *tree;
	NSArray *objects, *order, *correct;
}

@end

@implementation CHTreapTest

- (void) setUp {
	tree = [[CHTreap alloc] init];
	objects = [NSArray arrayWithObjects:@"G",@"D",@"K",@"B",@"I",@"F",@"L",@"C",
			   @"H",@"E",@"M",@"A",@"J",nil];
}

- (void) tearDown {
	[tree release];
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	NSUInteger count = 0;
	for (id anObject in objects) {
		[tree addObject:anObject];
		STAssertEquals([tree count], ++count, @"Incorrect count.");
		// Can't test a specific order because of randomly-assigned priorities
		STAssertNoThrow([tree verify], @"Not a valid treap: %@",
						[tree debugDescription]);
	}
	
	// Test adding an existing object to the treap
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
}

- (void) testAddObjectWithPriority {
	STAssertThrows([tree addObject:@"foo" withPriority:NSIntegerMax],
				   @"Should raise an exception.");
	
	NSUInteger priority = 0;
	NSEnumerator *e = [objects objectEnumerator];
	
	// Simulate by inserting unordered elements with increasing priority
	// This artificially balances the tree, but we can test the result.

	[tree addObject:[e nextObject] withPriority:(++priority)]; // G
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // D
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"D",@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // K
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"K",@"D",@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // B
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"B",@"K",@"D",@"G",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // I
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"I",@"B",@"D",@"G",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // F
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"D",@"I",@"G",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // L
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"L",@"F",@"B",@"D",@"I",@"G",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // C
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"C",@"B",@"L",@"F",@"D",@"I",@"G",@"K",
			   nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // H
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"H",@"C",@"B",@"F",@"D",@"G",@"L",@"I",
			   @"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // E
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"E",@"C",@"B",@"D",@"H",@"F",@"G",@"L",
			   @"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // M
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"M",@"E",@"C",@"B",@"D",@"H",@"F",@"G",
			   @"L",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // A
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"A",@"M",@"E",@"C",@"B",@"D",@"H",@"F",
			   @"G",@"L",@"I",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
	
	[tree addObject:[e nextObject] withPriority:(++priority)]; // J
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"J",@"A",@"E",@"C",@"B",@"D",@"H",@"F",
			   @"G",@"I",@"M",@"L",@"K",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
}

- (void) testAllObjectsWithTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseAscending];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",@"J",@"K",@"L",@"M",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Ascending order", order, correct));
	
	order = [tree allObjectsWithTraversalOrder:CHTraverseDescending];
	correct = [NSArray arrayWithObjects:@"M",@"L",@"K",@"J",@"I",@"H",@"G",@"F",
			   @"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Descending order", order, correct));
	
	// Test adding an existing object to the treap
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree addObject:@"A" withPriority:NSIntegerMin];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");	
}

- (void) testPriorityForObject {
	STAssertEquals([tree priorityForObject:nil], NSNotFound,
	               @"Priority should indicate that the object is absent.");
	STAssertEquals([tree priorityForObject:@"Z"], NSNotFound,
	               @"Priority should indicate that the object is absent.");

	NSInteger priority = 0;
	for (id object in objects)
		[tree addObject:object withPriority:(++priority)];
	
	STAssertEquals([tree priorityForObject:nil], NSNotFound,
	               @"Priority should indicate that the object is absent.");
	STAssertEquals([tree priorityForObject:@"Z"], NSNotFound,
	               @"Priority should indicate that the object is absent.");
	
	// Inserting from 'objects' with these priorities creates a known ordering.
	int priorities[] = {8,11,13,12,1,4,5,9,6,3,10,7,2};
	
	int index = 0;
	[tree removeAllObjects];
	for (id anObject in objects) {
		[tree addObject:anObject withPriority:(priorities[index++])];
		[tree verify];
	}
	
	// Verify that the assigned priorities are what we expect
	index = 0;
	for (id anObject in objects)
		STAssertEquals([tree priorityForObject:anObject], priorities[index++],
		               @"Wrong priority for object '%@'.", anObject);
	
	// Verify the required tree structure with these objects and priorities.
	order = [tree allObjectsWithTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"K",@"B",@"A",@"D",@"C",@"G",@"F",@"E",
	           @"H",@"J",@"I",@"M",@"L",nil];
	STAssertTrue([order isEqualToArray:correct],
	             badOrder(@"Pre-order", order, correct));
}

- (void) testRemoveObject {
	
	for (id anObject in objects)
		[tree addObject:anObject];
	
	// Test removing nil
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");
	
	CHLocationLog([tree debugDescription]);
	
	// Test removing a node which doesn't occur in the tree
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], [objects count], @"Incorrect count.");
		
	NSUInteger count = [objects count];
	for (id anObject in objects) {
		[tree removeObject:anObject];
		CHLocationLog(@"Remove %@\n%@", anObject, [tree debugDescription]);
		STAssertEquals([tree count], --count,
					   @"Incorrect count after removing %@.", anObject);
		STAssertNoThrow([tree verify], @"Not a valid treap: %@",
						[tree debugDescription]);
	}
	
	// Test removing a node which has been removed from the tree
	STAssertEquals([tree count], 0u, @"Incorrect count.");
	[tree removeObject:@"A"];
	STAssertEquals([tree count], 0u, @"Incorrect count.");
}

- (void) testDebugDescriptionForNode {
	CHTreeNode *sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->left = sentinel->right = sentinel;
	CHTreeNode *node = malloc(kCHTreeNodeSize);
	node->object = [NSString stringWithString:@"A B C"];
	node->left = node->right = sentinel;
	node->priority = 123456789;
	
	STAssertEqualObjects([tree debugDescriptionForNode:node],
						 @"	[  123456789]\t\"A B C\" -> \"(null)\" and \"(null)\"\n", nil);
}

- (void) testDotStringForNode {
	CHTreeNode *sentinel = malloc(kCHTreeNodeSize);
	sentinel->object = nil;
	sentinel->left = sentinel->right = sentinel;
	CHTreeNode *node = malloc(kCHTreeNodeSize);
	node->object = [NSString stringWithString:@"A B C"];
	node->left = node->right = sentinel;
	node->priority = 123456789;
	
	STAssertEqualObjects([tree dotStringForNode:node],
						 @"  \"A B C\" [label=\"A B C\\n123456789\"];\n", nil);
}

@end
