/*
 CHDataStructures.framework -- CHLinkedListTest.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <SenTestingKit/SenTestingKit.h>
#import "CHLinkedList.h"
#import "CHDoublyLinkedList.h"
#import "CHSinglyLinkedList.h"

static BOOL gcDisabled;


@interface CHLinkedListTest : SenTestCase {
	id<CHLinkedList> list;
	NSEnumerator *e;
	NSArray* linkedListClasses;
	NSArray* objects;
}
@end

@implementation CHLinkedListTest

+ (void) initialize {
	gcDisabled = !objc_collectingEnabled();
}

- (void) setUp {
	objects = [NSArray arrayWithObjects:@"A", @"B", @"C", nil];
	linkedListClasses = [NSArray arrayWithObjects:
						 [CHDoublyLinkedList class],
						 [CHSinglyLinkedList class],
						 nil];	
}

#pragma mark -

- (void) testNSCoding {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		for (id anObject in objects)
			[list appendObject:anObject];
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		
		NSString *filePath = @"/tmp/CHDataStructures-list.plist";
		[NSKeyedArchiver archiveRootObject:list toFile:filePath];
		[list release];
		
		list = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([list allObjects], objects,
							 @"Wrong ordering on reconstruction.");
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
		[list release];
	}
}

- (void) testNSCopying {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		for (id anObject in objects)
			[list appendObject:anObject];
		id<CHLinkedList> list2 = [list copyWithZone:nil];
		STAssertNotNil(list2, @"-copy should not return nil for valid list.");
		STAssertEquals([list2 count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([list allObjects], [list2 allObjects], @"Unequal lists.");
		[list2 release];
		[list release];
	}
}

- (void) testNSFastEnumeration {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		NSUInteger number, expected = 1, count = 0;
		for (number = 1; number <= 32; number++)
			[list appendObject:[NSNumber numberWithUnsignedInteger:number]];
		for (NSNumber *object in list) {
			STAssertEquals([object unsignedIntegerValue], expected++,
						   @"Objects should be enumerated in ascending order.");
			count++;
		}
		STAssertEquals(count, (NSUInteger)32, @"Count of enumerated items is incorrect.");
		
		BOOL raisedException = NO;
		@try {
			for (id object in list)
				[list appendObject:@"123"];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise mutation exception.");
		[list release];
	}
}

#pragma mark -

- (void) testEmptyList {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		STAssertNotNil(list, @"list should not be nil");
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], nil, @"-firstObject should be nil.");	
		STAssertEqualObjects([list lastObject], nil, @"-lastObject should be nil.");
		[list release];
	}
}

- (void) testInitWithArray {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] initWithArray:objects];
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([list allObjects], objects,
							 @"Bad array ordering on -initWithArray:");
		[list release];
	}
}

- (void) testDescription {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		for (id anObject in objects)
			[list appendObject:anObject];
		STAssertEqualObjects([list description], [objects description],
							 @"-description uses bad ordering.");
		[list release];
	}
}

#pragma mark Insertion and Access

- (void) testPrependObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		STAssertThrows([list prependObject:nil], @"Should raise an exception on nil.");
		
		for (id anObject in objects)
			[list prependObject:anObject];
		
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"A", @"-lastObject is wrong.");
		[list release];
	}
}

- (void) testAppendObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		STAssertThrows([list appendObject:nil], @"Should raise an exception on nil.");
		
		for (id anObject in objects)
			[list appendObject:anObject];
		
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject], @"C", @"-lastObject is wrong.");
		[list release];
	}
}

- (void) testInsertObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		STAssertThrows([list insertObject:nil atIndex:-1],
					   @"Should raise an exception on nil.");
		
		STAssertThrows([list insertObject:@"Z" atIndex:-1], @"Should raise NSRangeException.");
		STAssertThrows([list insertObject:@"Z" atIndex:1], @"Should raise NSRangeException.");
		STAssertNoThrow([list insertObject:@"Z" atIndex:0], @"Should not raise exception.");
		[list removeLastObject];
		
		for (id anObject in objects)
			[list appendObject:anObject];
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		STAssertThrows([list insertObject:@"Z" atIndex:[objects count]+1], @"Should raise NSRangeException.");
		STAssertNoThrow([list insertObject:@"Z" atIndex:[objects count]], @"Should not raise exception.");
		[list removeLastObject];
		
		// Try inserting in the middle
		[list insertObject:@"D" atIndex:1];
		STAssertEquals([list count], [objects count]+1, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:1], @"D", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:2], @"B", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:3], @"C", @"-objectAtIndex: is wrong.");
		// Try inserting at the beginning
		[list insertObject:@"E" atIndex:0];
		STAssertEquals([list count], [objects count]+2, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"E", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:1], @"A", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:2], @"D", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:3], @"B", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:4], @"C", @"-objectAtIndex: is wrong.");
		// Try inserting at the end
		[list insertObject:@"F" atIndex:5];
		STAssertEquals([list count], [objects count]+3, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:5], @"F", @"-objectAtIndex: is wrong.");
		[list release];
	}
}

- (void) testObjectEnumerator {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		// Enumerator shouldn't retain collection if there are no objects
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [list objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Should not retain collection");
		STAssertNil([e nextObject], @"-nextObject should return nil.");
		
		// Enumerator should retain collection when it has 1+ objects, release when 0
		for (id anObject in objects)
			[list appendObject:anObject];
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [list objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		
		STAssertEqualObjects([e nextObject], @"A", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"B", @"Wrong -nextObject.");
		STAssertEqualObjects([e nextObject], @"C", @"Wrong -nextObject.");
		
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Collection should still be retained");
		STAssertNil([e nextObject], @"-nextObject should return nil.");
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Enumerator should release collection");
		
		e = [list objectEnumerator];
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		NSArray *array = [e allObjects];
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Enumerator should release collection");
		STAssertNotNil(array, @"Array should not be nil");
		STAssertEquals([array count], [objects count], @"Incorrect count.");
		STAssertEqualObjects([array objectAtIndex:0], @"A", @"Object order is wrong.");
		STAssertEqualObjects([array lastObject],      @"C", @"Object order is wrong.");
		
		// Test that enumerator releases on -dealloc
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Wrong retain count");
		e = [list objectEnumerator];
		STAssertNotNil(e, @"Enumerator should not be nil.");
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)2, @"Enumerator should retain collection");
		[pool drain]; // Force deallocation of enumerator
		if (gcDisabled)
			STAssertEquals([list retainCount], (NSUInteger)1, @"Enumerator should release collection");	
		
		// Test mutation in the middle of enumeration
		e = [list objectEnumerator];
		[list appendObject:@"Z"];
		STAssertThrows([e nextObject], @"Should raise mutation exception.");
		STAssertThrows([e allObjects], @"Should raise mutation exception.");
		BOOL raisedException = NO;
		@try {
			for (id object in list)
				[list appendObject:@"123"];
		}
		@catch (NSException *exception) {
			raisedException = YES;
		}
		STAssertTrue(raisedException, @"Should raise mutation exception.");
		
		// Test deallocation in the middle of enumeration
		pool = [[NSAutoreleasePool alloc] init];
		e = [list objectEnumerator];
		[e nextObject];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		
		pool = [[NSAutoreleasePool alloc] init];
		e = [list objectEnumerator];
		[e nextObject];
		e = nil;
		[pool drain]; // Will cause enumerator to be deallocated
		[list release];
	}
}

#pragma mark Search

- (void) testContainsObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		STAssertFalse([list containsObject:@"A"], @"Should return YES.");
		[list appendObject:@"A"];
		STAssertTrue([list containsObject:@"A"], @"Should return YES.");
		STAssertFalse([list containsObject:@"Z"], @"Should return NO.");
		[list release];
	}
}

- (void) testContainsObjectIdenticalTo {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		NSString *a = [NSString stringWithFormat:@"A"];
		STAssertFalse([list containsObjectIdenticalTo:a], @"Should return NO.");
		[list appendObject:a];
		STAssertTrue([list containsObjectIdenticalTo:a], @"Should return YES.");
		STAssertFalse([list containsObjectIdenticalTo:@"A"], @"Should return NO.");
		[list release];
	}
}

- (void) testIndexOfObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		[list appendObject:@"A"];
		STAssertEquals([list indexOfObject:@"A"], (NSUInteger)0, @"Should return 0.");
		STAssertEquals([list indexOfObject:@"Z"], (NSUInteger)CHNotFound,
					   @"Should return CHNotFound.");
		[list release];
	}
}

- (void) testIndexOfObjectIdenticalTo {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		NSString *a = [NSString stringWithFormat:@"A"];
		[list appendObject:a];
		STAssertEquals([list indexOfObjectIdenticalTo:a], (NSUInteger)0, @"Should return 0.");
		STAssertEquals([list indexOfObjectIdenticalTo:@"A"], (NSUInteger)CHNotFound,
					   @"Should return CHNotFound.");
		[list release];
	}
}

- (void) testObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		for (id anObject in objects)
			[list appendObject:anObject];
		STAssertThrows([list objectAtIndex:-1], @"Should raise NSRangeException.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:1], @"B", @"-objectAtIndex: is wrong.");
		STAssertEqualObjects([list objectAtIndex:2], @"C", @"-objectAtIndex: is wrong.");
		STAssertThrows([list objectAtIndex:3], @"Should raise NSRangeException.");
		[list release];
	}
}

#pragma mark Removal

- (void) testRemoveFirstObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		
		[list removeFirstObject]; // Should have no effect
		for (id anObject in objects)
			[list appendObject:anObject];
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"B", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"Wrong -lastObject.");
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"Wrong -lastObject.");
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeFirstObject];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		STAssertNil([list firstObject], @"Wrong -firstObject.");
		STAssertNil([list lastObject],  @"Wrong -lastObject.");
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
		[list release];
	}
}

- (void) testRemoveLastObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		
		[list removeLastObject]; // Should have no effect
		for (id anObject in objects)
			[list appendObject:anObject];
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"B", @"Wrong -lastObject.");
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		// Doubly-linked list:  head->next === tail->prev
		// Singly-linked list:  head->next === tail
		
		[list removeLastObject];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		// Doubly-linked list:  head->next === tail && tail->prev === head
		// Singly-linked list:  head === tail
		[list release];
	}
}

- (void) testRemoveObject {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		[list removeObject:@"Z"]; // Should have no effect
		
		for (id anObject in objects)
			[list appendObject:anObject];
		
		[list removeObject:@"B"];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
		
		[list removeObject:@"A"];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"C", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
		
		[list removeObject:@"C"];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		STAssertNil([list firstObject], @"-firstObject should return nil.");
		STAssertNil([list lastObject], @"-lastObject should return nil.");
		
		// Test removing all instances of an object	
		[list appendObject:@"A"];
		[list appendObject:@"Z"];
		[list appendObject:@"B"];
		[list appendObject:@"Z"];
		[list appendObject:@"Z"];
		[list appendObject:@"C"];
		
		STAssertEquals([list count], (NSUInteger)6, @"Incorrect count.");
		[list removeObject:@"Z"];
		STAssertEquals([list count], (NSUInteger)3, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
		[list release];
	}
}

- (void) testRemoveObjectIdenticalTo {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		NSString *a = [NSString stringWithFormat:@"A"];
		[list appendObject:a];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		[list removeObjectIdenticalTo:@"A"];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		[list removeObjectIdenticalTo:a];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		
		// Test removing all instances of an object
		[list appendObject:@"A"];
		[list appendObject:@"Z"];
		[list appendObject:@"B"];
		[list appendObject:@"Z"];
		[list appendObject:@"C"];
		[list appendObject:[NSString stringWithFormat:@"Z"]];
		
		STAssertEquals([list count], (NSUInteger)6, @"Incorrect count.");
		[list removeObjectIdenticalTo:@"Z"];
		STAssertEquals([list count], (NSUInteger)4, @"Incorrect count.");
		STAssertEqualObjects([list objectAtIndex:0], @"A", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:1], @"B", @"Wrong object at index.");
		STAssertEqualObjects([list objectAtIndex:2], @"C", @"Wrong object at index.");	
		STAssertEqualObjects([list objectAtIndex:3], @"Z", @"Wrong object at index.");
		[list release];
	}
}

- (void) testRemoveObjectAtIndex {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		for (id anObject in objects)
			[list appendObject:anObject];
		
		STAssertThrows([list removeObjectAtIndex:3], @"Should raise NSRangeException.");
		STAssertThrows([list removeObjectAtIndex:-1], @"Should raise NSRangeException.");
		
		[list removeObjectAtIndex:2];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
		
		[list removeObjectAtIndex:0];
		STAssertEquals([list count], (NSUInteger)1, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"B", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"B", @"-lastObject is wrong.");
		
		[list removeObjectAtIndex:0];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		
		// Test removing from an index in the middle
		for (id anObject in objects)
			[list appendObject:anObject];
		
		[list removeObjectAtIndex:1];
		STAssertEquals([list count], (NSUInteger)2, @"Incorrect count.");
		STAssertEqualObjects([list firstObject], @"A", @"Wrong -firstObject.");
		STAssertEqualObjects([list lastObject],  @"C", @"-lastObject is wrong.");
		[list release];
	}
}

- (void) testRemoveAllObjects {
	for (Class aClass in linkedListClasses) {
		list = [[aClass alloc] init];
		for (id anObject in objects)
			[list appendObject:anObject];
		STAssertEquals([list count], [objects count], @"Incorrect count.");
		[list removeAllObjects];
		STAssertEquals([list count], (NSUInteger)0, @"Incorrect count.");
		[list release];
	}
}

@end
