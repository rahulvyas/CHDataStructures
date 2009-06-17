/*
 CHDataStructures.framework -- CHCustomDictionariesTest.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>

#import "CHLockableDictionary.h"
#import "CHLinkedDictionary.h"
#import "CHSortedDictionary.h"

@interface CHCustomDictionariesTest : SenTestCase {
	id dictionary;
	NSArray *keyArray;
	NSArray *expectedKeyOrder;
}
@end

@implementation CHCustomDictionariesTest

- (void) setUp {
	dictionary = [[[CHLockableDictionary alloc] init] autorelease];
	keyArray = [NSArray arrayWithObjects:@"baz", @"foo", @"bar", @"yoo", @"hoo", nil];
	expectedKeyOrder = nil;
}

- (void) populateDictionary {
	NSEnumerator *keys = [keyArray objectEnumerator];
	id aKey;
	while (aKey = [keys nextObject]) {
		[dictionary setObject:aKey forKey:aKey];
	}
}

- (void) verifyKeyCountAndOrdering {
	STAssertEquals([dictionary count], [keyArray count], @"Incorrect key count.");

	if (expectedKeyOrder != nil) {
		NSArray *allKeys = [[dictionary keyEnumerator] allObjects];
		NSUInteger count = MIN([dictionary count], [expectedKeyOrder count]);
		for (int i = 0; i < count; i++) {
			STAssertEqualObjects([allKeys objectAtIndex:i],
								 [expectedKeyOrder objectAtIndex:i],
								 @"Wrong output ordering of keys.");
		}
	}
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
	NSEnumerator *keyEnumerator = [dictionary keyEnumerator];
	STAssertNotNil(keyEnumerator, @"Key enumerator should be non-nil");
	NSArray *allKeys = [keyEnumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	STAssertEquals([allKeys count], (NSUInteger)0, @"Wrong number of keys.");
	
	[self populateDictionary];
	
	keyEnumerator = [dictionary keyEnumerator];
	STAssertNotNil(keyEnumerator, @"Key enumerator should be non-nil");
	allKeys = [keyEnumerator allObjects];
	STAssertNotNil(allKeys, @"Key enumerator should return non-nil array.");
	
	[self verifyKeyCountAndOrdering];
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

- (void) testRemoveObjectForFirstKey {
	if (![dictionary respondsToSelector:@selector(firstKey)])
		return;
	STAssertEquals([dictionary count], (NSUInteger)0, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeObjectForFirstKey], @"Should be no exception.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary firstKey],
						 [expectedKeyOrder objectAtIndex:0],
						 @"Wrong first key.");
	[dictionary removeObjectForFirstKey];
	STAssertEqualObjects([dictionary firstKey],
						 [expectedKeyOrder objectAtIndex:1],
						 @"Wrong last key.");
}

- (void) testRemoveObjectForLastKey {
	if (![dictionary respondsToSelector:@selector(lastKey)])
		return;
	STAssertEquals([dictionary count], (NSUInteger)0, @"Dictionary should be empty.");
	STAssertNoThrow([dictionary removeObjectForLastKey], @"Should be no exception.");
	[self populateDictionary];
	STAssertEqualObjects([dictionary lastKey],
						 [expectedKeyOrder objectAtIndex:[expectedKeyOrder count]-1],
						 @"Wrong last key.");
	[dictionary removeObjectForLastKey];
	STAssertEqualObjects([dictionary lastKey],
						 [expectedKeyOrder objectAtIndex:[expectedKeyOrder count]-2],
						 @"Wrong last key.");
}

#pragma mark -

- (void) testNSCoding {
	[self populateDictionary];
	[self verifyKeyCountAndOrdering];
	
	CHQuietLog(@"Before NSCoding: %@", [dictionary className]);
	CHQuietLog([dictionary description]);
	
	NSString *filePath = @"/tmp/CHDataStructures-dictionary.plist";
	[NSKeyedArchiver archiveRootObject:dictionary toFile:filePath];
	dictionary = nil; // created as autoreleased object
	
	dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
	CHQuietLog(@"After NSCoding:  %@", [dictionary className]);
	CHQuietLog([dictionary description]);
	[self verifyKeyCountAndOrdering];
	
	[[NSFileManager defaultManager] removeFileAtPath:filePath handler:nil];
}

- (void) testNSCopying {
	id copy = [dictionary copy];
	STAssertEquals([copy count], (NSUInteger)0, @"Copy of dictionary should be empty.");
	STAssertEqualObjects([copy class], [dictionary class], @"Wrong class.");
	[copy release];
	
	[self populateDictionary];
	dictionary = [dictionary copy];
	[self verifyKeyCountAndOrdering];
	[dictionary release];
}

@end

#pragma mark -

@interface CHSortedDictionaryTest : CHCustomDictionariesTest
@end

@implementation CHSortedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHSortedDictionary alloc] init] autorelease];
	expectedKeyOrder = [keyArray sortedArrayUsingSelector:@selector(compare:)];
}

@end

#pragma mark -

@interface CHLinkedDictionaryTest : CHCustomDictionariesTest
@end

@implementation CHLinkedDictionaryTest

- (void) setUp {
	[super setUp];
	dictionary = [[[CHLinkedDictionary alloc] init] autorelease];
	expectedKeyOrder = keyArray;
}

@end
