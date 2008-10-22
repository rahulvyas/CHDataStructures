//  CHMutableArrayHeapTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHMutableArrayHeap.h"

@interface CHMutableArrayHeap (Test)

- (NSArray*) array;
- (NSComparisonResult) sortOrder;

@end

@implementation CHMutableArrayHeap (Test)

- (NSArray*) array {
	return array;
}

- (NSComparisonResult) sortOrder {
	return sortOrder;
}

@end

#pragma mark -

@interface CHMutableArrayHeapTest : SenTestCase {
	CHMutableArrayHeap *heap;
	NSArray *testArray;
}
@end

@implementation CHMutableArrayHeapTest

- (void) setUp {
	heap = [[CHMutableArrayHeap alloc] init];
	testArray = [NSArray arrayWithObjects:
						  @"I",@"H",@"G",@"F",@"E",@"D",@"C",@"B",@"A",nil];
}

- (void) tearDown {
	[heap release];
}

- (void) verifyHeapProperty {
	NSArray *array = [heap array];
	NSComparisonResult order = [heap sortOrder];
	id parent, leftChild, rightChild;
	NSUInteger parentIndex = 0, leftIndex, rightIndex;
	NSUInteger arraySize = [array count];
	// Iterate from 0 to n/2-1 and check that children hold heap's sort order
	while (parentIndex < arraySize / 2) {
		leftIndex = parentIndex * 2 + 1;
		rightIndex = parentIndex * 2 + 2;
		parent = [array objectAtIndex:parentIndex];
		leftChild = (leftIndex < arraySize) ? [array objectAtIndex:leftIndex] : nil;
		rightChild = (rightIndex < arraySize) ? [array objectAtIndex:rightIndex] : nil;
		if (leftChild != nil)
			STAssertEquals([parent compare:leftChild], order,  @"Wrong ordering.");
		if (rightChild != nil)
			STAssertEquals([parent compare:rightChild], order,  @"Wrong ordering.");
		++parentIndex;
	}
}

#pragma mark -

- (void) testAddObject {
	STAssertEquals([heap count], 0u, @"-count is incorrect.");
	for (id anObject in testArray) {
		[heap addObject:anObject];
		[self verifyHeapProperty];
	}
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
}

- (void) testAddObjectsFromArray {
	[heap addObjectsFromArray:testArray];
	[self verifyHeapProperty];
}

- (void) testFirstObject {
	[heap addObjectsFromArray:testArray];
	STAssertEqualObjects([heap firstObject], @"A", @"-firstObject returned bad value.");
}

- (void) testRemoveFirstObject {
	[heap addObjectsFromArray:testArray];

	NSComparisonResult order = [heap sortOrder];
	id object, lastObject = nil;
	NSUInteger count = [heap count];
	while (object = [heap firstObject]) {
		if (lastObject)
			STAssertEquals([lastObject compare:object], order,  @"Wrong ordering.");
		lastObject = object;
		[heap removeFirstObject];
		STAssertEquals([heap count], --count, @"-count is incorrect.");	
		[self verifyHeapProperty];
	}
}

- (void) testRemoveObject {
	[heap addObjectsFromArray:testArray];
	
	STAssertEquals([heap count], 9u, @"-count is incorrect.");
	[heap removeObject:@"F"];
	STAssertEquals([heap count], 8u, @"-count is incorrect.");
	[self verifyHeapProperty];
}

@end
