/*
 CHDataStructures.framework -- CHSinglyLinkedList.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHSinglyLinkedList.h"

static size_t kCHSinglyLinkedListNodeSize = sizeof(CHSinglyLinkedListNode);

/**
 An NSEnumerator for traversing a CHSinglyLinkedList from front to back.
 */
@interface CHSinglyLinkedListEnumerator : NSEnumerator {
	CHSinglyLinkedList *collection; /**< The source of enumerated objects. */
	__strong CHSinglyLinkedListNode *current; /**< The next node to be enumerated. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */
}

/**
 Create an enumerator which traverses a singly-linked list from front to back.
 
 @param list The linked list collection being enumerated. This collection is to be retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param mutations A pointer to the collection's mutation count, for invalidation.
 */
- (id) initWithList:(CHSinglyLinkedList*)list
          startNode:(CHSinglyLinkedListNode*)startNode
    mutationPointer:(unsigned long*)mutations;

/**
 Returns the next object in the collection being enumerated.
 
 @return The next object in the collection being enumerated, or @c nil when all objects have been enumerated.
 */
- (id) nextObject;

/**
 Returns an array of objects the receiver has yet to enumerate. Invoking this method exhausts the remainder of the objects, such that subsequent invocations of #nextObject return @c nil.
 
 @return An array of objects the receiver has yet to enumerate.
 */
- (NSArray*) allObjects;

@end

#pragma mark -

@implementation CHSinglyLinkedListEnumerator

- (id) initWithList:(CHSinglyLinkedList*)list
          startNode:(CHSinglyLinkedListNode*)startNode
    mutationPointer:(unsigned long*)mutations;
{
	if ((self = [super init]) == nil) return nil;
	collection = (startNode != NULL) ? collection = [list retain] : nil;
	current = startNode; // If startNode == endNode, will always return nil.
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
	if (current == NULL) {
		[collection release];
		collection = nil;
		return nil;
	}
	id object = current->object;
	current = current->next;
	return object;
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	while (current != NULL) {
		[array addObject:current->object];
		current = current->next;
	}
	[collection release];
	collection = nil;
	return [array autorelease];
}

@end

#pragma mark -

// Remove the node with a matching object, steal its 'next' link for my own
static inline void removeNodeAfterNode(CHSinglyLinkedListNode *node) {
	CHSinglyLinkedListNode *old = node->next;
	node->next = old->next;
	if (kCHGarbageCollectionNotEnabled) {
		[old->object release];
		free(old);
	}
}

@implementation CHSinglyLinkedList

- (void) dealloc {
	[self removeAllObjects];
	free(head);
	[super dealloc];
}

- (id) init {
	return [self initWithArray:nil];
}

// This is the designated initializer for CHSinglyLinkedList
- (id) initWithArray:(NSArray*)anArray {
	if ((self = [super init]) == nil) return nil;
	head = NSAllocateCollectable(kCHSinglyLinkedListNodeSize, NSScannedOption);
	head->next = NULL;
	tail = head;
	count = 0;
	mutations = 0;
#if OBJC_API_2
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
	NSArray *array = [[self objectEnumerator] allObjects];
	[encoder encodeObject:array forKey:@"objects"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone*)zone {
	CHSinglyLinkedList *newList = [[CHSinglyLinkedList allocWithZone:zone] init];
#if OBJC_API_2
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

#if OBJC_API_2
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHSinglyLinkedListNode *currentNode;
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
		currentNode = (CHSinglyLinkedListNode*) state->state;
	}
	
	// Accumulate objects from the list until we reach the tail, or the maximum
	NSUInteger batchCount = 0;
	while (currentNode != NULL && batchCount < len) {
		stackbuf[batchCount++] = currentNode->object;
		currentNode = currentNode->next;
	}
	if (currentNode == NULL)
		state->state = 1; // used as a termination flag
	else
		state->state = (unsigned long)currentNode;
	return batchCount;
}
#endif

#pragma mark Querying Contents

- (NSArray*) allObjects {
	return [[self objectEnumerator] allObjects];
}

- (BOOL) containsObject:(id)anObject {
	return ([self indexOfObject:anObject] != NSNotFound);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([self indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	return (count == 0) ? nil : head->next->object;
}

- (NSUInteger) hash {
	return hashOfCountAndObjects(count, [self firstObject], [self lastObject]);
}

- (BOOL) isEqual:(id)otherObject {
	if ([otherObject conformsToProtocol:@protocol(CHLinkedList)])
		return [self isEqualToLinkedList:otherObject];
	else
		return NO;
}

- (BOOL) isEqualToLinkedList:(id<CHLinkedList>)otherLinkedList {
	return collectionsAreEqual(self, otherLinkedList);
}

- (id) lastObject {
	return (count == 0) ? nil : tail->object;
}

- (NSUInteger) indexOfObject:(id)anObject {
	CHSinglyLinkedListNode *current = head->next;
	NSUInteger index = 0;
	while (current && ![current->object isEqual:anObject]) {
		current = current->next;
		++index;
	}
	return (current == NULL) ? NSNotFound : index;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	CHSinglyLinkedListNode *current = head->next;
	NSUInteger index = 0;
	while (current && (current->object != anObject)) {
		current = current->next;
		++index;
	}
	return (current == NULL) ? NSNotFound : index;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	if (index == count - 1)
		return tail->object;
	else {
		CHSinglyLinkedListNode *node = head->next;
		for (NSUInteger nodeIndex = 0; nodeIndex < index; nodeIndex++)
			node = node->next;
		return node->object;
	}
}

- (NSEnumerator*) objectEnumerator {
	return [[[CHSinglyLinkedListEnumerator alloc]
              initWithList:self
                 startNode:head->next
           mutationPointer:&mutations] autorelease];
}

#pragma mark Modifying Contents

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	CHSinglyLinkedListNode *new;
	new = NSAllocateCollectable(kCHSinglyLinkedListNodeSize, NSScannedOption);
	new->object = [anObject retain];
	new->next = NULL;
	tail->next = new;
	tail = tail->next;
	
	++count;
	++mutations;
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	NSUInteger firstIndex = MIN(idx1, idx2), secondIndex = MAX(idx1,idx2);
	if (secondIndex > count)
		CHIndexOutOfRangeException([self class], _cmd, secondIndex, count);
	if (idx1 != idx2) {
		NSUInteger nodeIndex = 0;
		CHSinglyLinkedListNode *node1 = head->next;
		while (nodeIndex++ < firstIndex)
			node1 = node1->next;
		CHSinglyLinkedListNode *node2 = node1->next;
		while (nodeIndex++ < secondIndex)
			node2 = node2->next;
		id tempObject = node1->object;
		node1->object = node2->object;
		node2->object = tempObject;
		++mutations;
	}
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (index > count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	
	CHSinglyLinkedListNode *new = NSAllocateCollectable(kCHSinglyLinkedListNodeSize, NSScannedOption);
	new->object = [anObject retain];
	if (index == count) {
		new->next = NULL;
		tail->next = new;
		tail = tail->next;
	}
	else {
		CHSinglyLinkedListNode *node = head; // So the index lands at prior node
		for (NSUInteger nodeIndex = 0; nodeIndex < index; nodeIndex++)
			node = node->next;
		new->next = node->next;
		node->next = new;
	}
	++count;
	++mutations;
}

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	CHSinglyLinkedListNode *new;
	new = NSAllocateCollectable(kCHSinglyLinkedListNodeSize, NSScannedOption);
	new->object = [anObject retain];
	new->next = head->next;
	head->next = new;
	if (tail == head)
		tail = new;
	++count;
	++mutations;
}

- (void) removeAllObjects {
	if (kCHGarbageCollectionNotEnabled && count > 0) {
		CHSinglyLinkedListNode *node;
		// Use tail pointer to iterate through all nodes, then reset it to head
		tail = head->next;
		while (tail != NULL) {
			node = tail;
			tail = tail->next;
			[node->object release];
			free(node);
		}
	}
	head->next = NULL;
	tail = head;
	count = 0;
	++mutations;
}

- (void) removeFirstObject {
	if (count > 0)
		[self removeObjectAtIndex:0];
}

/**
 Remove the last item in the receiver.
 
 @attention This operation is expensive for singly-linked lists since there are no reverse links to facilitate finding the penultimate node.
 
 @see lastObject
 @see removeFirstObject
 */
- (void) removeLastObject {
	if (count > 0)
		[self removeObjectAtIndex:(count-1)];
}

- (void) removeObject:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	CHSinglyLinkedListNode *node = head;
	do {
		while (node->next != NULL && ![node->next->object isEqual:anObject])
			node = node->next;
		if (node->next != NULL) {
			removeNodeAfterNode(node);
			--count;
		}
	} while (node->next != NULL);
	tail = node;
	++mutations;
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);

	CHSinglyLinkedListNode *node = head; // So the index lands at prior node
	for (NSUInteger nodeIndex = 0; nodeIndex < index; nodeIndex++)
		node = node->next;
	removeNodeAfterNode(node);
	--count;
	++mutations;
	if (node->next == NULL)
		tail = node;
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (count == 0 || anObject == nil)
		return;
	CHSinglyLinkedListNode *node = head;
	do {
		while (node->next != NULL && node->next->object != anObject)
			node = node->next;
		if (node->next != NULL) {
			removeNodeAfterNode(node);
			--count;
		}
	} while (node->next != NULL);
	tail = node;
	++mutations;
}

- (void) replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	CHSinglyLinkedListNode *node;
	if (index == count - 1)
		node = tail;
	else {
		node = head->next;
		for (NSUInteger nodeIndex = 0; nodeIndex < index; nodeIndex++)
			node = node->next;
	}	
	[node->object autorelease];
	node->object = [anObject retain];
}

@end
