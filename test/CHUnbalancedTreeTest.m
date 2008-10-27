/*
 CHUnbalancedTreeTest.m
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
#import "CHUnbalancedTree.h"

static BOOL gcDisabled;

static NSString* badOrder(NSArray *order, NSArray *correctOrder) {
	return [[[NSString stringWithFormat:@"Should be %@, not %@", correctOrder, order]
			 stringByReplacingOccurrencesOfString:@"\n" withString:@""]
			stringByReplacingOccurrencesOfString:@"    " withString:@""];
}

@interface CHUnbalancedTreeTest : SenTestCase {
	CHUnbalancedTree *tree;
	NSArray *objects;
	NSArray *order, *correct;
}
@end

@implementation CHUnbalancedTreeTest

+ (void) initialize {
	gcDisabled = ([NSGarbageCollector defaultCollector] == nil);
}

- (void) setUp {
    tree = [[CHUnbalancedTree alloc] init];
	objects = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",
			   @"H",nil]; // Specified using level-order travesal
	// Creates the tree from: http://en.wikipedia.org/wiki/Tree_traversal#Example
}

- (void) tearDown {
    [tree release];
}

#pragma mark -

- (void) testNSCoding {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]
			 allObjects];
	STAssertEqualObjects(order, objects, @"Wrong ordering before archiving.");
	
	NSString *filePath = @"/tmp/tree.archive";
	[NSKeyedArchiver archiveRootObject:tree toFile:filePath];
	[tree release];
	
	tree = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder]
			 allObjects];
	STAssertEqualObjects(order, objects, @"Wrong ordering on reconstruction.");
}

- (void) testNSCopying {
	for (id object in objects)
		[tree addObject:object];
	id<CHTree> tree2 = [tree copy];
	STAssertNotNil(tree2, @"-copy should not return nil for valid tree.");
	STAssertEquals([tree2 count], [objects count], @"-count is incorrect.");
	STAssertEqualObjects([tree allObjects], [tree2 allObjects], @"Unequal trees.");
	[tree2 release];
}

- (void) testNSFastEnumeration {
	NSUInteger number, expected, count = 0;
	for (number = 1; number <= 32; number++)
		[tree addObject:[NSNumber numberWithUnsignedInteger:number]];
	expected = 1;
	for (NSNumber *object in tree) {
		STAssertEquals([object unsignedIntegerValue], expected++,
		               @"Objects should be enumerated in ascending order.");
		++count;
	}
	STAssertEquals(count, 32u, @"Count of enumerated items is incorrect.");
}

#pragma mark -

- (void) testInitWithArray {
	[tree release];
	tree = [[CHUnbalancedTree alloc] initWithArray:objects];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	
}

- (void) testAddObject {
	STAssertThrows([tree addObject:nil], @"Should raise an exception.");
	
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	
	// Test adding identical object--should be replaced, and count stay the same
	[tree addObject:@"A"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
}

- (void) testContainsObject {
	for (id object in objects)
		[tree addObject:object];
	STAssertTrue([tree containsObject:@"A"], @"-containsObject should be true.");
	STAssertFalse([tree containsObject:@"Z"], @"-containsObject should be true.");
	STAssertFalse([tree containsObject:nil], @"Should not raise an exception.");	
}

- (void) testContentsAsArrayUsingTraversalOrder {
	for (id object in objects)
		[tree addObject:object];
	
	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseInOrder];
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",
			   @"I",nil];
	STAssertEqualObjects(order, correct, @"Incorrect for CHTraverseInOrder.");

	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseReverseOrder];
	correct = [NSArray arrayWithObjects:@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",
			   @"A",nil];
	STAssertEqualObjects(order, correct, @"Incorrect for CHTraverseReverseOrder.");

	order = [tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",
			   @"H",nil];
	STAssertEqualObjects(order, correct, @"Incorrect for CHTraversePreOrder.");

	order = [tree contentsAsArrayUsingTraversalOrder:CHTraversePostOrder];
	correct = [NSArray arrayWithObjects:@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",
			   @"F",nil];
	STAssertEqualObjects(order, correct, @"Incorrect for CHTraversePostOrder.");

	order = [tree contentsAsArrayUsingTraversalOrder:CHTraverseLevelOrder];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",
			   @"H",nil];
	STAssertEqualObjects(order, correct, @"Incorrect for CHTraverseLevelOrder.");
}

- (void) testContentsAsSet {
	for (id object in objects)
		[tree addObject:object];
	
	NSSet *set = [tree contentsAsSet];
	STAssertEquals([set count], [objects count], @"-[NSSet count] is incorrect.");
	
	for (id anObject in objects)
		STAssertTrue([set containsObject:anObject], @"Should contain object.");
}

- (void) testFindMin {
	STAssertNil([tree findMin], @"-findMin should return nil for empty tree.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findMin], @"A", @"-findMin is incorrect.");
}

- (void) testFindMax {
	STAssertNil([tree findMax], @"-findMax should return nil for empty tree.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findMax], @"I", @"-findMax is incorrect.");
}

- (void) testFindObject {
	STAssertNil([tree findObject:nil], @"Should not raise an exception.");
	for (id object in objects)
		[tree addObject:object];
	STAssertEqualObjects([tree findObject:@"A"], @"A", @"Should exist and match.");
	STAssertNil([tree findObject:@"Z"], @"Should not be found in tree.");
}

- (void) testObjectEnumerator {
	// Enumerator shouldn't retain collection if there are no objects
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	NSEnumerator *e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Should not retain collection");
	
	// Enumerator should retain collection when it has 1+ objects, release when 0
	for (id object in objects)
		[tree addObject:object];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 2u, @"Enumerator should retain collection");
	// Grab one object from the enumerator
	[e nextObject];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 2u, @"Collection should still be retained.");
	// Empty the enumerator of all objects
	[e allObjects];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Enumerator should release collection");
	
	// Test that enumerator releases on -dealloc
	NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Wrong retain count");
	e = [tree objectEnumerator];
	STAssertNotNil(e, @"Enumerator should not be nil.");
	if (gcDisabled)
		STAssertEquals([tree retainCount], 2u, @"Enumerator should retain collection");
	[pool drain]; // Force deallocation of enumerator
	if (gcDisabled)
		STAssertEquals([tree retainCount], 1u, @"Enumerator should release collection");
	
	// Test mutation in the middle of enumeration
	e = [tree objectEnumerator];
	[tree addObject:@"Z"];
	STAssertThrows([e nextObject], @"Should raise mutation exception.");
	STAssertThrows([e allObjects], @"Should raise mutation exception.");
	BOOL raisedException = NO;
	@try {
		for (id object in tree)
			[tree addObject:@"123"];
	}
	@catch (NSException *exception) {
		raisedException = YES;
	}
	STAssertTrue(raisedException, @"Should raise mutation exception.");
	
	// Test deallocation in the middle of enumeration
	pool  = [[NSAutoreleasePool alloc] init];
	e = [tree objectEnumerator];
	[e nextObject];
	[e nextObject];
	e = nil;
	[pool drain]; // Will cause enumerator to be deallocated
	
	pool  = [[NSAutoreleasePool alloc] init];
	e = [tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder];
	[e nextObject];
	e = nil;
	[pool drain]; // Will cause enumerator to be deallocated
}

- (void) testTraversalInOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseInOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalReverseOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPreOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePreOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"F",@"B",@"A",@"D",@"C",@"E",@"G",@"I",@"H",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalPostOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraversePostOrder] allObjects];	
	correct = [NSArray arrayWithObjects:@"A",@"C",@"E",@"D",@"B",@"H",@"I",@"G",@"F",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testTraversalLevelOrder {
	for (id object in objects)
		[tree addObject:object];
	order = [[tree objectEnumeratorWithTraversalOrder:CHTraverseLevelOrder] allObjects];
	correct = [NSArray arrayWithObjects:@"F",@"B",@"G",@"A",@"D",@"I",@"C",@"E",@"H",nil];
	STAssertTrue([order isEqualToArray:correct], badOrder(order, correct));
}

- (void) testRemoveObject {
	STAssertThrows([tree removeObject:nil], @"Should raise an exception.");

	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeObject:@"Z"];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeObject:@"A"];
	STAssertEquals([tree count], [objects count]-1, @"-count is incorrect.");
	
	[tree release];
	// Test remove and subsequent pre-order of nodes for 4 broad possible cases
	objects = [NSArray arrayWithObjects:
			   @"F",@"B",@"A",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil];
	tree = [[CHUnbalancedTree alloc] initWithArray:objects];
	
	// 1 - Remove a node with no children
	[tree removeObject:@"A"];
	STAssertEquals([tree count], 10u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",@"K",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	[tree removeObject:@"K"];
	STAssertEquals([tree count], 9u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects:@"F",@"B",@"C",@"E",@"D",@"J",@"I",@"G",@"H",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");

	// 2 - Remove a node with only a right child
	[tree removeObject:@"C"];
	STAssertEquals([tree count], 8u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects:@"F",@"B",@"E",@"D",@"J",@"I",@"G",@"H",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	[tree removeObject:@"B"];
	STAssertEquals([tree count], 7u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"I",@"G",@"H",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	
	// 3 - Remove a node with only a left child
	[tree removeObject:@"I"];
	STAssertEquals([tree count], 6u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects:@"F",@"E",@"D",@"J",@"G",@"H",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	[tree removeObject:@"J"];
	STAssertEquals([tree count], 5u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects:@"F",@"E",@"D",@"G",@"H",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	
	// 4 - Remove a node with two children
	[tree release];
	objects = [NSArray arrayWithObjects: @"B",@"A",@"E",@"C",@"D",@"F",nil];
	tree = [[CHUnbalancedTree alloc] initWithArray:objects];

	[tree removeObject:@"B"];
	STAssertEquals([tree count], 5u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects: @"C",@"A",@"E",@"D",@"F",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	
	[tree removeObject:@"C"];
	STAssertEquals([tree count], 4u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects: @"D",@"A",@"E",@"F",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	
	[tree removeObject:@"D"];
	STAssertEquals([tree count], 3u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects: @"E",@"A",@"F",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
	
	[tree removeObject:@"E"];
	STAssertEquals([tree count], 2u, @"-count is incorrect.");
	correct = [NSArray arrayWithObjects: @"F",@"A",nil];
	STAssertEqualObjects([tree contentsAsArrayUsingTraversalOrder:CHTraversePreOrder],
	                     correct, @"Bad pre-ordering after removing node.");
}

- (void) testRemoveAllObjects {
	for (id object in objects)
		[tree addObject:object];
	STAssertEquals([tree count], [objects count], @"-count is incorrect.");
	[tree removeAllObjects];
	STAssertEquals([tree count], 0u, @"-count is incorrect.");
}

@end
