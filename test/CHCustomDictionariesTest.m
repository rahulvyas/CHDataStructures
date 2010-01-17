/*
 CHDataStructures.framework -- CHCustomDictionariesTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "CHLockableDictionary.h"
#import "CHOrderedDictionary.h"
#import "CHSortedDictionary.h"

@interface CHLockableDictionary (Test)

- (NSString*) debugDescription; // Declare here to prevent compiler warnings.

@end

#pragma mark -

@interface CHLockableDictionaryTest : SenTestCase {
	id dictionary;
	NSArray *keyArray;
	NSArray *expectedKeyOrder;
	NSEnumerator *enumerator;
}
@end

@implementation CHLockableDictionaryTest

- (void) setUp {
	dictionary = [[[CHLockableDictionary alloc] init] autorelease];
	keyArray = [NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil];
	expectedKeyOrder = nil;
}

- (void) populateDictionary {
	enumerator = [keyArray objectEnumerator];
	id aKey;
	while (aKey = [enumerator nextObject]) {
		[dictionary setObject:aKey forKey:aKey];
	}
}

- (void) verifyKeyCountAndOrdering:(NSArray*)allKeys {
	STAssertEquals([dictionary count], [keyArray count], @"Incorrect key count.");

	if (expectedKeyOrder != nil) {
		if (allKeys == nil)
			allKeys = [dictionary allKeys];
		NSUInteger count = MIN([dictionary count], [expectedKeyOrder count]);
		for (NSUInteger i = 0; i < count; i++) {
			STAssertEqualObjects([allKeys objectAtIndex:i],
								 [expectedKeyOrder objectAtIndex:i],
								 @"Wrong output ordering of keys.");
		}
	}
}

- (void) verifyKeyCountAndOrdering {
	[self verifyKeyCountAndOrdering:nil];
}

- (void) testInitWithObjectsForKeysCount {
	dictionary = [[[dictionary class] alloc] initWithObjects:keyArray forKeys:keyArray];
	// Should call down to -initWithObjects:forKeys:count:
}

- (void) testSetObjectForKey {
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should be nil.");
	[dictionary setObject:@"bar" forKey:@"foo"];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"bar",
						 @"Wrong object for key.");

	// Verify that setting a different value for a key "takes" the new value
	[dictionary removeAllObjects];
	[self populateDictionary];
	id key = [keyArray lastObject];
	NSString *value = [dictionary objectForKey:key];
	
	[dictionary setObject:value forKey:key];
	STAssertTrue([value isEqual:[dictionary objectForKey:key]], @"Should be equal.");
	
	[dictionary setObject:[NSString string] forKey:key];
	STAssertFalse([value isEqual:[dictionary objectForKey:key]], @"Should not be equal.");
}

- (void) testDebugDescription {
	STAssertNotNil([dictionary debugDescription], @"Description was nil.");
	[dictionary setObject:@"xyz" forKey:@"abc"];
	STAssertNotNil([dictionary debugDescription], @"Description was nil.");
}

- (void) testDescription {
	STAssertEqualObjects([dictionary description], [[NSDictionary dictionary] description], @"Incorrect description");
}

- (void) testFirstKey {
	if (![dictionary respondsToSelector:@selector(firstKey)])
		return;
	STAssertNil([dictionary firstKey], @"First key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary firstKey],
						 [expectedKeyOrder objectAtIndex:0],
						 @"Wrong first key.");
}

- (void) testLastKey {
	if (![dictionary respondsToSelector:@selector(lastKey)])
		return;
	STAssertNil([dictionary lastKey], @"Last key should be nil.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey],
						 [expectedKeyOrder lastObject],
						 @"Wrong last key.");
}

- (void) testKeyEnumerator {
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], (NSUInteger)0, @"Wrong number of keys.");
	
	[self populateDictionary];
	
	enumerator = [dictionary keyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	
	[self verifyKeyCountAndOrdering];
}

- (void) testReverseKeyEnumerator {
	if (![dictionary respondsToSelector:@selector(reverseKeyEnumerator)])
		return;
	enumerator = [dictionary reverseKeyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], (NSUInteger)0, @"Wrong number of keys.");
	
	[self populateDictionary];

	enumerator = [dictionary reverseKeyEnumerator];
	STAssertNotNil(enumerator, @"Key enumerator should be non-nil");
	allKeys = [enumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	
	if ([dictionary isMemberOfClass:[CHOrderedDictionary class]]) {
		expectedKeyOrder = keyArray;
	} else {
		expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
	}
	expectedKeyOrder = [[expectedKeyOrder reverseObjectEnumerator] allObjects];
	[self verifyKeyCountAndOrdering:[[dictionary reverseKeyEnumerator] allObjects]];
}

- (void) testRemoveAllObjects {
	STAssertEquals([dictionary count], (NSUInteger)0, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeAllObjects], @"Should be no exception.");
	[self populateDictionary];
	STAssertEquals([dictionary count], [keyArray count], @"Wrong key count.");
	[dictionary removeAllObjects];
	STAssertEquals([dictionary count], (NSUInteger)0, @"Dictionary should be empty.");
}

- (void) testRemoveObjectForKey {
	STAssertNoThrow([dictionary removeObjectForKey:@"foo"], @"Should be no exception.");
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should not exist.");
	[self populateDictionary];
	STAssertNotNil([dictionary objectForKey:@"foo"], @"Object should exist.");
	[dictionary removeObjectForKey:@"foo"];
	STAssertNil([dictionary objectForKey:@"foo"], @"Object should not exist.");
}

#pragma mark -

- (void) testNSCoding {
	[self populateDictionary];
	[self verifyKeyCountAndOrdering];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
	id oldDictionary = dictionary;
	dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	[self verifyKeyCountAndOrdering];
	if ([dictionary isMemberOfClass:[CHLockableDictionary class]])
		STAssertTrue([[NSSet setWithArray:[dictionary allKeys]] isEqualToSet:
		              [NSSet setWithArray:[oldDictionary allKeys]]],
		             @"Wrong keys on reconstruction.");
	else
		STAssertEqualObjects([dictionary allKeys], [oldDictionary allKeys],
		                     @"Wrong key ordering on reconstruction.");
}

- (void) testNSCopying {
	id copy = [dictionary copy];
	STAssertEquals([copy count], (NSUInteger)0, @"Copy of dictionary should be empty.");
	STAssertEquals([dictionary hash], [copy hash], @"Hashes should match.");
	STAssertEqualObjects([copy class], [dictionary class], @"Wrong class.");
	[copy release];
	copy = dictionary;
	
	[self populateDictionary];
	dictionary = [dictionary copy];
	[self verifyKeyCountAndOrdering];
	STAssertEquals([dictionary hash], [copy hash], @"Hashes should match.");
	[dictionary release];
}

@end

#pragma mark -

@interface CHSortedDictionaryTest : CHLockableDictionaryTest
@end

@implementation CHSortedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHSortedDictionary alloc] init] autorelease];
	expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
}

- (void) testSubsetFromKeyToKeyOptions {
	STAssertNoThrow([dictionary subsetFromKey:nil toKey:nil options:0],
					@"Should not raise exception.");
	STAssertNoThrow([dictionary subsetFromKey:@"A" toKey:@"Z" options:0],
					@"Should not raise exception.");
	
	[self populateDictionary];
	NSMutableDictionary* subset;
	
	STAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:0]
												 toKey:[expectedKeyOrder lastObject]
											   options:0],
					@"Should not raise exception.");
	STAssertEquals([subset count], [expectedKeyOrder count], @"Wrong count for subset");

	STAssertNoThrow(subset = [dictionary subsetFromKey:[expectedKeyOrder objectAtIndex:1]
												 toKey:[expectedKeyOrder objectAtIndex:3]
											   options:0],
					@"Should not raise exception.");
	STAssertEquals([subset count], (NSUInteger)3, @"Wrong count for subset");
}

@end

#pragma mark -

@interface CHOrderedDictionaryTest : CHLockableDictionaryTest
@end

@implementation CHOrderedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHOrderedDictionary alloc] init] autorelease];
	expectedKeyOrder = keyArray;
}

- (void) testExchangeKeyAtIndexWithKeyAtIndex {
	STAssertThrows([dictionary exchangeKeyAtIndex:0 withKeyAtIndex:1],
				   @"Should raise exception, collection is empty.");
	STAssertThrows([dictionary exchangeKeyAtIndex:1 withKeyAtIndex:0],
				   @"Should raise exception, collection is empty.");
	
	[self populateDictionary];
	[dictionary exchangeKeyAtIndex:1 withKeyAtIndex:1];
	STAssertEqualObjects([dictionary allKeys], keyArray, @"Should have no effect.");
	[dictionary exchangeKeyAtIndex:0 withKeyAtIndex:[keyArray count]-1];
	STAssertEqualObjects([dictionary firstKey], @"hoo", @"Bad order after swap.");
	STAssertEqualObjects([dictionary lastKey],  @"baz", @"Bad order after swap.");
}

- (void) testIndexOfKey {
	STAssertEquals([dictionary indexOfKey:@"foo"], (NSUInteger)NSNotFound,
				   @"Key should not be found in dictionary");
	[self populateDictionary];
	for (NSUInteger i = 0; i < [keyArray count]; i++) {
		STAssertEquals([dictionary indexOfKey:[keyArray objectAtIndex:i]], i,
					   @"Wrong index for key.");
	}
}

- (void) testInsertObjectForKeyAtIndex {
	STAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:1],
	               @"Should raise NSRangeException for bad index.");
	STAssertThrows([dictionary insertObject:nil forKey:@"foo" atIndex:0],
	               @"Should raise NSInvalidArgumentException for nil param.");
	STAssertThrows([dictionary insertObject:@"foo" forKey:nil atIndex:0],
	               @"Should raise NSInvalidArgumentException for nil param.");
	
	[self populateDictionary];
	NSUInteger count = [dictionary count];
	STAssertThrows([dictionary insertObject:@"foo" forKey:@"foo" atIndex:count+1],
	               @"Should raise NSRangeException for bad index.");
	STAssertNoThrow([dictionary insertObject:@"xyz" forKey:@"xyz" atIndex:count],
	                @"Should be able to insert a new value at the end");
	STAssertEqualObjects([dictionary lastKey], @"xyz", @"Last key should be 'xyz'.");
	STAssertNoThrow([dictionary insertObject:@"abc" forKey:@"abc" atIndex:0],
	                @"Should be able to insert a new value at the end");
	STAssertEqualObjects([dictionary firstKey], @"abc", @"First key should be 'abc'.");
}

- (void) testKeyAtIndex {
	STAssertThrows([dictionary keyAtIndex:0], @"Should raise exception.");
	STAssertThrows([dictionary keyAtIndex:1], @"Should raise exception.");
	[self populateDictionary];
	NSUInteger i;
	for (i = 0; i < [keyArray count]; i++) {
		STAssertEqualObjects([dictionary keyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong key at index %d.", i);
	}
	STAssertThrows([dictionary keyAtIndex:i], @"Should raise exception.");
}

- (void) testKeysAtIndexes {
	STAssertThrows([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:0]],
				   @"Should raise NSRangeException for nonexistent index.");
	[self populateDictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		STAssertNoThrow([dictionary keysAtIndexes:[NSIndexSet indexSetWithIndex:location]],
		                @"Should not raise exception, valid index.");
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow([dictionary keysAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			STAssertEqualObjects([dictionary keysAtIndexes:indexes],
			                     [keyArray objectsAtIndexes:indexes],
								 @"Key selection mismatch.");
		}
	}
}

- (void) testObjectForKeyAtIndex {
	STAssertThrows([dictionary objectForKeyAtIndex:0], @"Should raise exception");
	
	[self populateDictionary];
	NSUInteger i;	
	for (i = 0; i < [keyArray count]; i++) {
		STAssertEqualObjects([dictionary objectForKeyAtIndex:i], [keyArray objectAtIndex:i],
							 @"Wrong object for key at index %d.", i);
	}
	STAssertThrows([dictionary objectForKeyAtIndex:i], @"Should raise exception.");
}

- (void) testObjectsForKeyAtIndexes {
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], @"Should raise exception.");
	[self populateDictionary];
	STAssertThrows([dictionary objectsForKeysAtIndexes:nil], @"Should raise exception.");
	
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)];
			
			[dictionary objectsForKeysAtIndexes:indexes];
		}
	}
}

- (void) testOrderedDictionaryWithKeysAtIndexes {
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], @"Index set cannot be nil.");
	[self populateDictionary];
	STAssertThrows([dictionary orderedDictionaryWithKeysAtIndexes:nil], @"Index set cannot be nil.");

	CHOrderedDictionary* newDictionary;
	STAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:[NSIndexSet indexSet]],
	                @"Should not raise exception");
	STAssertNotNil(newDictionary, @"Result should not be nil.");
	STAssertEquals([newDictionary count], (NSUInteger)0, @"Wrong count.");
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			STAssertNoThrow(newDictionary = [dictionary orderedDictionaryWithKeysAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			STAssertEqualObjects([newDictionary allKeys],
			                     [keyArray objectsAtIndexes:indexes],
								 @"Key selection mismatch.");
		}
	}
}

- (void) testRemoveObjectForKeyAtIndex {
	STAssertThrows([dictionary removeObjectForKeyAtIndex:0], @"Nonexistent index.");
	
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectForKeyAtIndex:[keyArray count]], @"Nonexistent index.");
	
	NSMutableArray *expected = [keyArray mutableCopy];
	[expected removeObjectAtIndex:4];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:4], @"Should be no exception");
	STAssertEqualObjects([dictionary allKeys], expected, @"Wrong key ordering");	
	[expected removeObjectAtIndex:2];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:2], @"Should be no exception");
	STAssertEqualObjects([dictionary allKeys], expected, @"Wrong key ordering");	
	[expected removeObjectAtIndex:0];
	STAssertNoThrow([dictionary removeObjectForKeyAtIndex:0], @"Should be no exception");
	STAssertEqualObjects([dictionary allKeys], expected, @"Wrong key ordering");	
}

- (void) testSetObjectForKeyAtIndex {
	STAssertThrows([dictionary setObject:@"new foo" forKeyAtIndex:0],
	               @"Should raise exception");
	
	[self populateDictionary];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"foo", @"Wrong object");
	[dictionary setObject:@"X" forKeyAtIndex:1];
	STAssertEqualObjects([dictionary objectForKey:@"foo"], @"X", @"Wrong object");
	STAssertThrows([dictionary setObject:@"X" forKeyAtIndex:[keyArray count]],
	               @"Should raise exception");
}

- (void) testRemoveObjectsForKeysAtIndexes {
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], @"Index set cannot be nil.");
	[self populateDictionary];
	STAssertThrows([dictionary removeObjectsForKeysAtIndexes:nil], @"Index set cannot be nil.");
	
	NSDictionary* master = [NSDictionary dictionaryWithDictionary:dictionary];
	NSMutableDictionary* expected = [NSMutableDictionary dictionary];
	// Select ranges of indexes and test that they line up with what we expect.
	NSIndexSet* indexes;
	for (NSUInteger location = 0; location < [dictionary count]; location++) {
		for (NSUInteger length = 0; length < [dictionary count] - location; length++) {
			indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)]; 
			// Repopulate dictionary and reset expected
			[dictionary removeAllObjects];
			[dictionary addEntriesFromDictionary:master];
			expected = [NSMutableDictionary dictionaryWithDictionary:master];
			[expected removeObjectsForKeys:[dictionary keysAtIndexes:indexes]];
			STAssertNoThrow([dictionary removeObjectsForKeysAtIndexes:indexes],
							@"Should not raise exception, valid index range.");
			STAssertEqualObjects([dictionary allKeys],
			                     [expected allKeys],
								 @"Key selection mismatch.");
		}
	}	
}

@end
