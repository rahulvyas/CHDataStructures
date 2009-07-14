/*
 CHDataStructures.framework -- CHDoublyLinkedList.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHDoublyLinkedList.h"

static size_t kCHDoublyLinkedListNodeSize = sizeof(CHDoublyLinkedListNode);

/**
 An NSEnumerator for traversing a CHDoublyLinkedList in forward or reverse order.
 */
@interface CHDoublyLinkedListEnumerator : NSEnumerator {
	CHDoublyLinkedList *collection; /**< The source of enumerated objects. */
	__strong CHDoublyLinkedListNode *current; /**< The next node to be enumerated. */
	__strong CHDoublyLinkedListNode *sentinel; /**< Node that signifies completion. */
	BOOL reverse; /**< Whether the enumerator is proceeding from back to front. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */
}

/**
 Create an enumerator which traverses a list in either forward or revers order.
 
 @param list The linked list collection being enumerated. This collection is to be retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param endNode The node which signifies that enumerations should terminate.
 @param direction The direction in which to enumerate. If greater than zero, uses @c NSOrderedDescending, else @c NSOrderedAscending.
 @param mutations A pointer to the collection's mutation count, for invalidation.
 
 The enumeration direction is inferred from the state of the provided start node. If @c startNode->next is @c NULL, enumeration proceeds from back to front; otherwise, enumeration proceeds from front to back. This works since the head and tail nodes always have @c NULL for their @c prev and @c next links, respectively. When there is only one node, order won't matter anyway.
 
 This enumerator doesn't support enumerating over a sub-list of nodes. (When a node from the middle is provided, enumeration will proceed towards the tail.)
 */
- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
            endNode:(CHDoublyLinkedListNode*)endNode
          direction:(NSComparisonResult)direction
    mutationPointer:(unsigned long*)mutations;

/**
 Returns the next object in the collection being enumerated.
 
 @return The next object in the collection being enumerated, or @c nil when all objects have been enumerated.
 */
- (id) nextObject;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent invocations of #nextObject return @c nil.
 */
- (NSArray*) allObjects;

@end

#pragma mark -

@implementation CHDoublyLinkedListEnumerator

- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
            endNode:(CHDoublyLinkedListNode*)endNode
          direction:(NSComparisonResult)direction
    mutationPointer:(unsigned long*)mutations;
{
	if ((self = [super init]) == nil) return nil;
	collection = ([list count] > 0) ? [list retain] : nil;
	current = startNode;
	sentinel = endNode;
	reverse = (direction > 0) ? YES : NO;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
	[super dealloc];
}

- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	if (current == sentinel) {
		[collection release];
		collection = nil;
		return nil;
	}
	id object = current->object;
	current = (reverse) ? current->prev : current->next;
	return object;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (current != sentinel) {
		[array addObject:current->object];
		current = (reverse) ? current->prev : current->next;
	}
	[collection release];
	collection = nil;
	return [array autorelease];
}

@end

#pragma mark -

@implementation CHDoublyLinkedList

// An internal method for locating a node at a specific position in the list.
// If the index is invalid, an NSRangeException is raised.
- (CHDoublyLinkedListNode*) nodeAtIndex:(NSUInteger)index {
	if (index > count) // If it's equal to count, return dummy tail node.
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	CHDoublyLinkedListNode *node;
	if (index < count/2) {
		node = head->next;
		NSUInteger nodeIndex = 0;
		while (index > nodeIndex++)
			node = node->next;
	} else {
		node = tail;
		NSUInteger nodeIndex = count;
		while (index < nodeIndex--)
			node = node->prev;
	}
	return node;
}

// An internal method for removing a given node and patching up neighbor links.
// Since we use dummy head and tail nodes, there is no need to check for null.
- (void) removeNode:(CHDoublyLinkedListNode*)node {
	node->prev->next = node->next;
	node->next->prev = node->prev;
	if (kCHGarbageCollectionNotEnabled && node != NULL) {
		[node->object release];
		free(node);
	}
	--count;
	++mutations;
}

#pragma mark -

- (void) dealloc {
	[self removeAllObjects];
	free(head);
	free(tail);
	[super dealloc];
}

- (id) init {
	return [self initWithArray:nil];
}

// This is the designated initializer for CHDoublyLinkedList
- (id) initWithArray:(NSArray*)anArray {
	if ((self = [super init]) == nil) return nil;
	head = NSAllocateCollectable(kCHDoublyLinkedListNodeSize, NSScannedOption);
	tail = NSAllocateCollectable(kCHDoublyLinkedListNodeSize, NSScannedOption);
	head->object = tail->object = nil;
	head->next = tail;
	head->prev = NULL;
	tail->next = NULL;
	tail->prev = head;
	count = 0;
	mutations = 0;
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in anArray)
#else
	NSEnumerator *e = [anArray objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		[self appendObject:anObject];
	}
	return self;
}

- (NSString*) description {
	return [[self allObjects] description];
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder*)decoder {
	return [self initWithArray:[decoder decodeObjectForKey:@"objects"]];
}

- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:[[self objectEnumerator] allObjects] forKey:@"objects"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*)zone {
	CHDoublyLinkedList *newList = [[CHDoublyLinkedList allocWithZone:zone] init];
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in self)
#else
	NSEnumerator *e = [self objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		[newList appendObject:anObject];
	}
	return newList;
}

#pragma mark <NSFastEnumeration>

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHDoublyLinkedListNode *currentNode;
	// On the first call, start at head, otherwise start at last saved node
	if (state->state == 0) {
		currentNode = head->next;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		currentNode = (CHDoublyLinkedListNode*) state->state;
	}
	
	// Accumulate objects from the list until we reach the tail, or the maximum
    NSUInteger batchCount = 0;
    while (currentNode != tail && batchCount < len) {
        stackbuf[batchCount] = currentNode->object;
        currentNode = currentNode->next;
		batchCount++;
    }
	if (currentNode == tail)
		state->state = 1; // used as a termination flag
	else
		state->state = (unsigned long)currentNode;
    return batchCount;
}
#endif

#pragma mark Adding Objects

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:0];
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:count];
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHDoublyLinkedListNode *node = [self nodeAtIndex:index];
	CHDoublyLinkedListNode *newNode;
	newNode = NSAllocateCollectable(kCHDoublyLinkedListNodeSize, NSScannedOption);
	newNode->object = [anObject retain];
	newNode->next = node;          // point forward to displaced node
	newNode->prev = node->prev;    // point backward to preceding node
	newNode->prev->next = newNode; // point preceding node forward to new node
	node->prev = newNode;          // point displaced node backward to new node
	++count;
	++mutations;
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	if (MAX(idx1,idx2) > count)
		CHIndexOutOfRangeException([self class], _cmd, MAX(idx1,idx2), count);
	if (idx1 != idx2) {
		CHDoublyLinkedListNode *node1 = [self nodeAtIndex:idx1];
		CHDoublyLinkedListNode *node2 = [self nodeAtIndex:idx2];
		id tempObject = node1->object;
		node1->object = node2->object;
		node2->object = tempObject;
		++mutations;
	}
}

#pragma mark Querying Contents

- (NSArray*) allObjects {
	return [[self objectEnumerator] allObjects];
}

- (BOOL) containsObject:(id)anObject {
	return ([self indexOfObject:anObject] != CHNotFound);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([self indexOfObjectIdenticalTo:anObject] != CHNotFound);
}

- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	tail->object = nil;
	return head->next->object; // nil if there are no objects between head/tail
}

- (NSUInteger) hash {
	return hashOfCountAndObjects(count, [self firstObject], [self lastObject]);
}

- (BOOL) isEqualToLinkedList:(id<CHLinkedList>)otherLinkedList {
	return collectionsAreEqual(self, otherLinkedList);
}

- (id) lastObject {
	head->object = nil;
	return tail->prev->object; // nil if there are no objects between head/tail
}

- (NSUInteger) indexOfObject:(id)anObject {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (![current->object isEqual:anObject]) {
		current = current->next;
		++index;
	}
	return (current == tail) ? CHNotFound : index;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (current->object != anObject) {
		current = current->next;
		++index;
	}
	return (current == tail) ? CHNotFound : index;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	return [self nodeAtIndex:index]->object;
}

- (NSEnumerator*) objectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
	          initWithList:self
	             startNode:head->next
	               endNode:tail
	             direction:NSOrderedAscending
	       mutationPointer:&mutations] autorelease];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [[[CHDoublyLinkedListEnumerator alloc]
	          initWithList:self
	             startNode:tail->prev
	               endNode:head
	             direction:NSOrderedDescending
	       mutationPointer:&mutations] autorelease];
}

#pragma mark Removing Objects

- (void) removeFirstObject {
	if (count == 0)
		return;
	[self removeNode:head->next];
}

- (void) removeLastObject {
	if (count == 0)
		return;
	[self removeNode:tail->prev];
}

- (void) removeObject:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while (![node->object isEqual:anObject])
			node = node->next;
		if (node != tail) {
			temp = node->next;
			[self removeNode:node];
			node = temp;
		}
	} while (node != tail);
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while (node->object != anObject)
			node = node->next;
		if (node != tail) {
			temp = node->next;
			[self removeNode:node];
			node = temp;
		}
	} while (node != tail);
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	[self removeNode:[self nodeAtIndex:index]];
}

- (void) removeAllObjects {
	if (kCHGarbageCollectionNotEnabled && count > 0) {
		// Only bother with free() calls if garbage collection is NOT enabled.
		CHDoublyLinkedListNode *node = head->next, *temp;
		while (node != tail) {
			temp = node->next;
			[node->object release];
			free(node);
			node = temp;
		}
	}
	head->next = tail;
	tail->prev = head;
	count = 0;
	++mutations;
}

@end
