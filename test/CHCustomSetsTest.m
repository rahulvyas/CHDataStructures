/*
 CHDataStructures.framework -- CHCustomSetsTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLockableSet.h"
#import "CHOrderedSet.h"

@interface CHLockableSet (Test)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end

#pragma mark -

@interface CHLockableSetTest : SenTestCase {
	id set;
	NSEnumerator *e;
	id anObject;
}

- (void) checkEqualityWithArray:(NSArray*)anArray;

- (NSArray*) randomNumbers;

@end


@implementation CHLockableSetTest

- (void) setUp {
	set = [[CHLockableSet alloc] init];
}

- (void) tearDown {
	[set release];
}

- (void) checkEqualityWithArray:(NSArray*)anArray {
	STAssertTrue([set isEqualToSet:[NSSet setWithArray:anArray]], @"Unequal sets.");
}

// Provides an array of N unique NSNumber objects.
- (NSArray*) randomNumbers {
	NSMutableArray *array = [NSMutableArray array];
	NSNumber *number;
	for (NSUInteger count = 1; count <= 20; count++) {
		number = [NSNumber numberWithUnsignedInt:arc4random()];
		if ([array containsObject:number])
			count--;
		else
			[array addObject:number];
	}
	return array;
}

- (void) testAddObjectsFromArray {
	STAssertNoThrow([set addObjectsFromArray:nil], @"Should not raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	[self checkEqualityWithArray:abc];
	
	[set addObjectsFromArray:abc];
	[self checkEqualityWithArray:abc];
}

- (void) testAllObjects {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	[self checkEqualityWithArray:array];
	
	[set removeAllObjects];
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	[set addObject:@"A"];
	array = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
	[self checkEqualityWithArray:array];
	
	[set addObject:@"C"];
	[set addObject:@"B"];
	[self checkEqualityWithArray:array];
}

- (void) testAnyObject {
	STAssertNil([set anyObject], @"Should return nil.");
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertNotNil([set anyObject], @"Should not return nil.");
}

- (void) testCount {
	STAssertEquals([set count], (NSUInteger)0, @"Set should be empty.");
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEquals([set count], [array count], @"Set should be empty.");
}

- (void) testContainsObject {
	STAssertFalse([set containsObject:@"A"], @"Should not contain object.");
	STAssertFalse([set containsObject:@"Z"], @"Should not contain object.");
	[set addObject:@"A"];
	STAssertTrue([set containsObject:@"A"], @"Should not contain object.");
	STAssertFalse([set containsObject:@"Z"], @"Should not contain object.");
}

- (void) testDebugDescription {
	STAssertNotNil([set debugDescription], @"Description was nil.");
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertNotNil([set debugDescription], @"Description was nil.");
}

- (void) testHash {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	id set2 = [[[[set class] alloc] initWithArray:abc] autorelease];
	STAssertEquals([set hash], [set2 hash], @"Hashes should match.");
}

- (void) testIntersectsSet {
	NSSet *abc = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	NSSet *cde = [NSSet setWithObjects:@"C",@"D",@"E",nil];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	STAssertFalse([set intersectsSet:abc], @"Should not intersect.");
	[set addObjectsFromArray:[NSArray arrayWithObjects:@"A",@"B",@"C",nil]];
	
	STAssertTrue([set intersectsSet:abc], @"Should intersect.");
	STAssertTrue([set intersectsSet:cde], @"Should intersect.");
	STAssertFalse([set intersectsSet:xyz], @"Should not intersect.");
	
	STAssertFalse([set intersectsSet:nil], @"Should not intersect.");
	STAssertFalse([set intersectsSet:[NSSet set]], @"Should not intersect.");
}

- (void) testIsEqualToSet {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertTrue([set isEqualToSet:[NSSet setWithArray:array]], @"Unequal sets.");
}

- (void) testIntersectSet {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *cde = [NSArray arrayWithObjects:@"C",@"D",@"E",nil];
	NSArray *def = [NSArray arrayWithObjects:@"D",@"E",@"F",nil];
	NSArray *c = [NSArray arrayWithObjects:@"C",nil];
	NSArray *empty = [NSArray array];
	
	STAssertNoThrow([set intersectSet:nil], @"Should not raise exception");
	
	// Test intersecting identical sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:abc]];
	[self checkEqualityWithArray:abc];
	
	// Test intersecting overlapping sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:cde]];
	[self checkEqualityWithArray:c];
	[set removeAllObjects];
	
	[set addObjectsFromArray:cde];
	[set intersectSet:[NSSet setWithArray:abc]];
	[self checkEqualityWithArray:c];
	[set removeAllObjects];
	
	// Test intersecting disjoint sets
	[set addObjectsFromArray:abc];
	[set intersectSet:[NSSet setWithArray:def]];
	[self checkEqualityWithArray:empty];
}

- (void) testMinusSet {
	NSArray *axbycz = [NSArray arrayWithObjects:@"A",@"X",@"B",@"Y",@"C",@"Z",nil];
	NSArray *xaybzc = [NSArray arrayWithObjects:@"X",@"A",@"Y",@"B",@"Z",@"C",nil];
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *empty = [NSArray array];
	NSSet *xyz = [NSSet setWithObjects:@"X",@"Y",@"Z",nil];
	
	STAssertNoThrow([set minusSet:nil], @"Should not raise exception");
	[self checkEqualityWithArray:empty];
	
	[set minusSet:[NSSet set]];
	[self checkEqualityWithArray:empty];
	
	[set minusSet:xyz];
	[self checkEqualityWithArray:empty];
	
	[set addObjectsFromArray:axbycz];
	
	STAssertNoThrow([set minusSet:nil], @"Should not raise exception");
	[self checkEqualityWithArray:axbycz];
	
	[set minusSet:[NSSet set]];
	[self checkEqualityWithArray:axbycz];
	
	// Test removing even elements
	[set addObjectsFromArray:axbycz];
	STAssertNoThrow([set minusSet:xyz], @"Should not raise exception");
	[self checkEqualityWithArray:abc];
	[set removeAllObjects];
	
	// Test removing odd elements
	[set addObjectsFromArray:xaybzc];	
	STAssertNoThrow([set minusSet:xyz], @"Should not raise exception");
	[self checkEqualityWithArray:abc];
	[set removeAllObjects];
	
	// Test differencing disjoint sets
	[set addObjectsFromArray:abc];
	[set minusSet:xyz];
	[self checkEqualityWithArray:abc];
	
	// Test differencing identical sets
	[set addObjectsFromArray:abc];
	[set minusSet:[NSSet setWithArray:abc]];
	[self checkEqualityWithArray:empty];
}

- (void) testIsSubsetOfSet {
	NSSet *abc = [NSSet setWithObjects:@"A",@"B",@"C",nil];
	[set addObject:@"A"];
	STAssertTrue([set isSubsetOfSet:abc], @"Should be a subset.");
	[set addObject:@"B"];
	STAssertTrue([set isSubsetOfSet:abc], @"Should be a subset.");
	[set addObject:@"C"];
	STAssertTrue([set isSubsetOfSet:abc], @"Should be a subset.");
	[set addObject:@"D"];
	STAssertFalse([set isSubsetOfSet:abc], @"Should not be a subset.");
}

- (void) testRemoveAllObjects {
	[set addObjectsFromArray:[self randomNumbers]];
	STAssertTrue([set count] != 0, @"Count should not be zero.");
	[set removeAllObjects];
	STAssertTrue([set count] == 0, @"Count should be zero.");
}

- (void) testMember {
	STAssertNil([set member:@"A"], @"Should not be a member.");
	[set addObject:@"A"];
	STAssertEqualObjects([set member:@"A"], @"A", @"Should be a member.");
	STAssertNil([set member:@"Z"], @"Should not be a member.");
	[set removeAllObjects];
	STAssertNil([set member:@"A"], @"Should not be a member.");
}

- (void) testRemoveObject {
	STAssertNoThrow([set removeObject:nil], @"Should not raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	STAssertTrue([set containsObject:@"A"], @"Should contain object.");
	[set removeObject:@"A"];
	STAssertFalse([set containsObject:@"A"], @"Should not contain object.");
}

#pragma mark <Protocols>

- (void) testNSCoding {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEquals([set count], [array count], @"Incorrect count.");
	[self checkEqualityWithArray:array];
	NSString *filePath = @"/tmp/CHDataStructures-ordered-set.plist";
	[NSKeyedArchiver archiveRootObject:set toFile:filePath];
	
	CHOrderedSet *set2 = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
	STAssertEquals([set2 count], [set count], @"Incorrect count on reconstruction.");
	[self checkEqualityWithArray:[set2 allObjects]];
#if MAC_OS_X_VERSION_10_5_AND_LATER
	[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
#else
	[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
#endif
	[set2 release];	
}

- (void) testNSCopying {
	[set addObjectsFromArray:[self randomNumbers]];
	CHOrderedSet *copy = [set copy];
	STAssertEqualObjects([set class], [copy class], @"Wrong class.");
	STAssertEquals([set count], [copy count], @"Count mismatch.");
	[self checkEqualityWithArray:[copy allObjects]];
}

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (void) testNSFastEnumeration {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *enumerator = [array objectEnumerator];
	NSUInteger count = 0;
	for (NSNumber *number in set) {
		count++;
		STAssertNotNil([enumerator nextObject], @"Should not be nil.");
	}
	STAssertEquals(count, [set count], @"Wrong count.");
	STAssertNil([enumerator nextObject], @"Enumerator was not exhausted.");
}
#endif

@end

#pragma mark -

@interface CHOrderedSetTest : CHLockableSetTest

@end

@implementation CHOrderedSetTest

- (void) setUp {
	set = [[CHOrderedSet alloc] init];
}

- (void) checkEqualityWithArray:(NSArray*)anArray {
	STAssertTrue([anArray isEqualToArray:[set allObjects]], @"Wrong ordering.");
}

#pragma mark Initialization

- (void) testInitialization {
	STAssertNotNil(set, @"Initialization failed.");
	[set release];
	// This tests -initWithArray: directly, and -initWithCapacity: indirectly.
	NSArray *array = [self randomNumbers];
	set = [[CHOrderedSet alloc] initWithArray:array];
	[self checkEqualityWithArray:array];
}

#pragma mark Adding Objects

- (void) testAddObjectsAndOrdering {
	STAssertThrows([set addObject:nil], @"Should raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	[self checkEqualityWithArray:abc];
	
	e = [abc objectEnumerator];
	while (anObject = [e nextObject])
		[set addObject:anObject];
	[self checkEqualityWithArray:abc];
}

- (void) testExchangeObjectAtIndexWithObjectAtIndex {
	STAssertThrows([set exchangeObjectAtIndex:0 withObjectAtIndex:1],
				   @"Should raise exception, set is empty.");
	
	NSArray *abc  = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	// Just sanity-check the code, since the implementation is tested elsewhere.
	[set exchangeObjectAtIndex:0 withObjectAtIndex:2];
	STAssertEqualObjects([set objectAtIndex:2], [abc objectAtIndex:0], @"Bad order");
	STAssertEqualObjects([set objectAtIndex:0], [abc objectAtIndex:2], @"Bad order");
}

- (void) testInsertObjectAtIndex {
	NSArray *abc  = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *acb  = [NSArray arrayWithObjects:@"A",@"C",@"B",nil];
	NSArray *dacb  = [NSArray arrayWithObjects:@"D",@"A",@"C",@"B",nil];
	
	STAssertThrows([set insertObject:@"X" atIndex:1], @"Should raise exception");
	
	[set addObjectsFromArray:abc];
	
	[set insertObject:@"C" atIndex:1];
	STAssertEqualObjects([set allObjects], acb, @"Wrong ordering");
	
	[set insertObject:@"D" atIndex:0];
	STAssertEqualObjects([set allObjects], dacb, @"Wrong ordering");
}

- (void) testUnionSet {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSSet *ade = [NSSet setWithObjects:@"A",@"D",@"E",nil];
	NSMutableArray *order;
	
	order = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",nil];
	e = [ade objectEnumerator];
	while (anObject = [e nextObject])
		if (![anObject isEqual:@"A"])
			[order addObject:anObject];
	[set addObjectsFromArray:abc];
	[set unionSet:ade];
	[self checkEqualityWithArray:order];
}

#pragma mark Querying Contents

- (void) testDescription {
	STAssertEqualObjects([set description], [[NSArray array] description],
						 @"Wrong description.");

	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	STAssertEqualObjects([set description], [array description],
						 @"Wrong description.");
}

- (void) testIndexOfObject {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEquals([set indexOfObject:[abc objectAtIndex:i]], i,
					   @"Wrong index for object");
	}
}

- (void) testIsEqualToOrderedSet {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	NSArray *cba = [NSArray arrayWithObjects:@"C",@"B",@"A",nil];
	NSArray *xyz = [NSArray arrayWithObjects:@"X",@"Y",@"Z",nil];
	CHOrderedSet* set2;
	[set addObjectsFromArray:abc];
	set2 = [[[CHOrderedSet alloc] initWithArray:abc] autorelease];
	STAssertTrue([set isEqualToOrderedSet:set2], @"Sets should be equal.");
	set2 = [[[CHOrderedSet alloc] initWithArray:cba] autorelease];
	STAssertFalse([set isEqualToOrderedSet:set2], @"Sets should not be equal.");
	set2 = [[[CHOrderedSet alloc] initWithArray:xyz] autorelease];
	STAssertFalse([set isEqualToOrderedSet:set2], @"Sets should not be equal.");
}

- (void) testObjectAtIndex {
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	for (NSUInteger i = 0; i < [abc count]; i++) {
		STAssertEquals([set objectAtIndex:i], [abc objectAtIndex:i],
					   @"Wrong object at index");
	}
}

- (void) testObjectEnumerator {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *arrayEnumerator = [array objectEnumerator];
	NSEnumerator *setEnumerator = [set objectEnumerator];
	id arrayObject, setObject;
	do {
		arrayObject = [arrayEnumerator nextObject];
		setObject   = [setEnumerator nextObject];
		STAssertEqualObjects(arrayObject, setObject, @"Error while enumerating.");
	} while (arrayObject && setObject);
}

#pragma mark Removing Objects

- (void) testRemoveFirstObject {
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	
	STAssertEqualObjects([set firstObject], @"A", @"Wrong first object.");
	[set removeFirstObject];
	STAssertEqualObjects([set firstObject], @"B", @"Wrong first object.");
	[set removeFirstObject];
	STAssertEqualObjects([set firstObject], @"C", @"Wrong first object.");
	[set removeFirstObject];
	STAssertNil([set firstObject], @"Wrong first object.");
}

- (void) testRemoveLastObject {
	[set addObject:@"A"];
	[set addObject:@"B"];
	[set addObject:@"C"];
	
	STAssertEqualObjects([set lastObject], @"C", @"Wrong last object.");
	[set removeLastObject];
	STAssertEqualObjects([set lastObject], @"B", @"Wrong last object.");
	[set removeLastObject];
	STAssertEqualObjects([set lastObject], @"A", @"Wrong last object.");
	[set removeLastObject];
	STAssertNil([set lastObject], @"Wrong last object.");
}

- (void) testRemoveObjectAtIndex {
	STAssertThrows([set removeObjectAtIndex:0], @"Should raise exception");
	
	NSArray *abc = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
	[set addObjectsFromArray:abc];
	STAssertThrows([set removeObjectAtIndex:[abc count]], @"Should raise exception");
	for (NSInteger i = [abc count]-1; i >= 0; i--) {
		STAssertEqualObjects([set lastObject], [abc objectAtIndex:i],
							 @"Wrong object at index before removing at index");
		[set removeObjectAtIndex:i];
	}
}

#pragma mark <Protocols>

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (void) testNSFastEnumeration {
	NSArray *array = [self randomNumbers];
	[set addObjectsFromArray:array];
	NSEnumerator *enumerator = [array objectEnumerator];
	for (NSNumber *number in set) {
		STAssertEqualObjects(number, [enumerator nextObject], @"Wrong ordering.");
	}
	STAssertNil([enumerator nextObject], @"Enumerator was not exhausted.");
}
#endif

@end
