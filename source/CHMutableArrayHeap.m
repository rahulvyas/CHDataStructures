/*
 CHDataStructures.framework -- CHMutableArrayHeap.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHMutableArrayHeap.h"

@implementation CHMutableArrayHeap

- (void) heapifyFromIndex:(NSUInteger)parentIndex {
	NSUInteger leftIndex, rightIndex;
	id parent, leftChild, rightChild;
	
	// Bubble the specified node down until the heap property is satisfied.
	NSUInteger count = [array count];
	while (parentIndex < count / 2) {
		leftIndex = parentIndex * 2 + 1;
		rightIndex = leftIndex + 1;
		
		parent = [array objectAtIndex:parentIndex];
		leftChild = [array objectAtIndex:leftIndex];
		rightChild = (rightIndex < count) ? [array objectAtIndex:rightIndex] : nil;
		// A binary heap is always a complete tree, so left will never be nil.
		if (rightChild == nil || [leftChild compare:rightChild] == sortOrder) {
			if ([parent compare:leftChild] != sortOrder) {
				[array exchangeObjectAtIndex:parentIndex withObjectAtIndex:leftIndex];
				parentIndex = leftIndex;
			}
			else
				break;
		}
		else {
			if ([parent compare:rightChild] != sortOrder) {
				[array exchangeObjectAtIndex:parentIndex withObjectAtIndex:rightIndex];
				parentIndex = rightIndex;
			}
			else
				break;
		}
	}
}

#pragma mark -

- (void) dealloc {
	[sortDescriptor release];
	[super dealloc];
}

- (id) init {
	return [self initWithOrdering:NSOrderedAscending array:nil];
}

- (id) initWithArray:(NSArray*)anArray {
	return [self initWithOrdering:NSOrderedAscending array:anArray];
}

- (id) initWithOrdering:(NSComparisonResult)order {
	return [self initWithOrdering:order array:nil];
}

- (id) initWithOrdering:(NSComparisonResult)order array:(NSArray*)anArray {
	// Parent's initializer allocates the actual array
	if ([super init] == nil) return nil;
	if (order != NSOrderedAscending && order != NSOrderedDescending)
		CHInvalidArgumentException([self class], _cmd, @"Invalid sort order.");
	sortOrder = order;
	sortDescriptor = [[NSSortDescriptor alloc]
                       initWithKey:nil
                         ascending:(sortOrder == NSOrderedAscending)];
	[self addObjectsFromArray:anArray];
	return self;
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder *)decoder {
	if ([super initWithCoder:decoder] == nil) return nil;
	sortOrder = [decoder decodeIntegerForKey:@"sortOrder"];
	sortDescriptor = [[NSSortDescriptor alloc]
                       initWithKey:nil
                         ascending:(sortOrder == NSOrderedAscending)];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeInteger:sortOrder forKey:@"sortOrder"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithOrdering:sortOrder array:array];
}

#pragma mark <NSFastEnumeration>

// This overridden method returns the heap contents in fully-sorted order.
// Just as -objectEnumerator above, the first call incurs a hidden sorting cost.
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	// Currently (in Leopard) NSEnumerators from NSArray only return 1 each time
	if (state->state == 0) {
		// Create a sorted array to use for enumeration, store it in the state.
		state->extra[4] = (unsigned long) [self allObjects];
	}
	NSArray *sorted = (NSArray*) state->extra[4];
	NSUInteger count = [sorted countByEnumeratingWithState:state
	                                               objects:stackbuf
	                                                 count:len];
	state->mutationsPtr = &mutations; // point state to mutations for heap array
	return count;
}

#pragma mark -

- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	++mutations;
	[array addObject:anObject];
	// Bubble the new object (at the end of the array) up the heap as necessary.
	NSUInteger parentIndex;
	NSUInteger index = [array count] - 1;
	while (index > 0) {
		parentIndex = (index - 1) / 2;
		if ([[array objectAtIndex:parentIndex] compare:anObject] != sortOrder) {
			[array exchangeObjectAtIndex:parentIndex withObjectAtIndex:index];
			index = parentIndex;
		}
		else
			break;
	}
}

- (void) addObjectsFromArray:(NSArray*)anArray {
	if (anArray == nil)
		return;
	++mutations;
	[array addObjectsFromArray:anArray];
	// Re-heapify from the middle of the heap array bacwards to the beginning.
	// (This must be done since we don't know the ordering of the new objects.)
	// We could choose to bubble each new element up, but this is likely faster.
	NSUInteger index = [array count]/2;
	while (0 < index--)
		[self heapifyFromIndex:index];
}

- (id) firstObject {
	@try {
		return [array objectAtIndex:0];
	}
	@catch (NSException *exception) {}
	return nil;
}
		
- (void) removeFirstObject {
	@try {
		[array exchangeObjectAtIndex:0 withObjectAtIndex:([array count]-1)];
		[array removeLastObject];
		++mutations;
		// Bubble the swapped node down until the heap property is again satisfied
		[self heapifyFromIndex:0];
	}
	@catch (NSException *exception) {}
}

- (void) removeObject:(id)anObject {
	NSUInteger index = [array indexOfObject:anObject];
	if (index != NSNotFound) {
		[array exchangeObjectAtIndex:index withObjectAtIndex:([array count]-1)];
		[array removeLastObject];
		++mutations;
		// Bubble the swapped node down until the heap property is again satisfied
		[self heapifyFromIndex:index];
	}
}

- (void) removeAllObjects {
	[array removeAllObjects];
	++mutations;
}

- (NSArray*) allObjects {
	return [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (NSEnumerator*) objectEnumerator {
	return [[self allObjects] objectEnumerator];
}

// CHAbstractMutableArrayCollection provides this method for indexed access.
// However, this is meaningless in a heap, so we'll specifically disallow it.
- (id) objectAtIndex:(NSUInteger)index {
	CHUnsupportedOperationException([self class], _cmd);
	return nil;
}

@end
