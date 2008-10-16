//  CHAbstractListCollectionTest.m
//  CHDataStructures.framework

#import <SenTestingKit/SenTestingKit.h>
#import "CHAbstractListCollection.h"
#import "CHSinglyLinkedList.h"

@interface CHAbstractListCollection (Test)

- (void) addObject:(id)anObject;

@end

@implementation CHAbstractListCollection (Test)

- (id) init {
	if ([super init] == nil) {
		[self release];
		return nil;
	}
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

- (void) addObject:(id)anObject {
	[list appendObject:anObject];
}

@end


#pragma mark -

@interface CHAbstractListCollectionTest : SenTestCase
{
	CHAbstractListCollection *collection;
}

@end

@implementation CHAbstractListCollectionTest

- (void) setUp {
	collection = [[CHAbstractListCollection alloc] init];
}

- (void) tearDown {
	[collection release];
}

- (void) testInit {
	STAssertNotNil(collection, @"collection should not be nil");
}

- (void) testCount {
	STAssertEquals([collection count], 0u, @"-count is incorrect.");
	[collection addObject:@"Hello, World!"];
	STAssertEquals([collection count], 1u, @"-count is incorrect.");
}

- (void) testContainsObject {
	[collection addObject:@"A"];
	[collection addObject:@"B"];
	[collection addObject:@"C"];
	STAssertTrue([collection containsObject:@"A"], @"Should contain object");
	STAssertTrue([collection containsObject:@"B"], @"Should contain object");
	STAssertTrue([collection containsObject:@"C"], @"Should contain object");
	STAssertFalse([collection containsObject:@"a"], @"Should NOT contain object");
	STAssertFalse([collection containsObject:@"Z"], @"Should NOT contain object");
}

- (void) testContainsObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertTrue([collection containsObjectIdenticalTo:a], @"Should return YES.");
	STAssertFalse([collection containsObjectIdenticalTo:@"A"], @"Should return NO.");
	STAssertFalse([collection containsObjectIdenticalTo:@"Z"], @"Should return NO.");
}

- (void) testIndexOfObject {
	[collection addObject:@"A"];
	[collection addObject:@"B"];
	[collection addObject:@"C"];
	STAssertEquals([collection indexOfObject:@"A"], 0u, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"B"], 1u, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"C"], 2u, @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"a"], (unsigned)NSNotFound,
				   @"Wrong index for object");
	STAssertEquals([collection indexOfObject:@"Z"], (unsigned)NSNotFound,
				   @"Wrong index for object");
}

- (void) testIndexOfObjectIdenticalTo {
	NSString *a = [NSString stringWithFormat:@"A"];
	[collection addObject:a];
	STAssertEquals([collection indexOfObjectIdenticalTo:a],
				   0u, @"Wrong index for object");
	STAssertEquals([collection indexOfObjectIdenticalTo:@"A"],
				   (unsigned)NSNotFound, @"Wrong index for object");
	STAssertEquals([collection indexOfObjectIdenticalTo:@"Z"],
				   (unsigned)NSNotFound, @"Wrong index for object");
}

- (void) testObjectAtIndex {
	[collection addObject:@"A"];
	[collection addObject:@"B"];
	[collection addObject:@"C"];
	STAssertThrows([collection objectAtIndex:-1], @"Bad index should raise exception");
	STAssertEqualObjects([collection objectAtIndex:0], @"A", @"Wrong object at index");
	STAssertEqualObjects([collection objectAtIndex:1], @"B", @"Wrong object at index");
	STAssertEqualObjects([collection objectAtIndex:2], @"C", @"Wrong object at index");
	STAssertThrows([collection objectAtIndex:3], @"Bad index should raise exception");
}

- (void) testAllObjects {
	NSArray *allObjects;
	
	allObjects = [collection allObjects];
	STAssertNotNil(allObjects, @"Array should not be nil");
	STAssertEquals([allObjects count], 0u, @"Incorrect array length.");

	[collection addObject:@"A"];
	[collection addObject:@"B"];
	[collection addObject:@"C"];
	allObjects = [collection allObjects];
	STAssertNotNil(allObjects, @"Array should not be nil");
	STAssertEquals([allObjects count], 3u, @"Incorrect array length.");
}

- (void) testRemoveAllObjects {
	STAssertEquals([collection count], 0u, @"-count is incorrect.");
	[collection addObject:@"A"];
	[collection addObject:@"B"];
	[collection addObject:@"C"];
	STAssertEquals([collection count], 3u, @"-count is incorrect.");
	[collection removeAllObjects];
	STAssertEquals([collection count], 0u, @"-count is incorrect.");
}

- (void) testObjectEnumerator {
	NSEnumerator *enumerator;
	enumerator = [collection objectEnumerator];
	STAssertNotNil(enumerator, @"-objectEnumerator should NOT return nil.");
	STAssertNil([enumerator nextObject], @"-nextObject should return nil.");
	
	[collection addObject:@"Hello, World!"];
	enumerator = [collection objectEnumerator];
	STAssertNotNil(enumerator, @"-objectEnumerator should NOT return nil.");
	STAssertNotNil([enumerator nextObject], @"-nextObject should NOT return nil.");	
	STAssertNil([enumerator nextObject], @"-nextObject should return nil.");	
}

@end
