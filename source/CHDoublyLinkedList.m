/*
 CHDoublyLinkedList.m
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

#import "CHDoublyLinkedList.h"

static NSUInteger kCHDoublyLinkedListNodeSize = sizeof(CHDoublyLinkedListNode);

/**
 An NSEnumerator for traversing a CHDoublyLinkedList in forward or reverse order.
 */
@interface CHDoublyLinkedListEnumerator : NSEnumerator {
	CHDoublyLinkedList *collection; /**< The source of enumerated objects. */
	CHDoublyLinkedListNode *current; /**< The next node to be enumerated. */
	CHDoublyLinkedListNode *sentinel; /**< The node that signifies completion. */
	BOOL reverse; /**< Whether the enumerator is proceeding from back to front. */
	unsigned long mutationCount; /**< Stores the collection's initial mutation. */
	unsigned long *mutationPtr; /**< Pointer for checking changes in mutation. */
}

/**
 Create an enumerator which traverses a list in either forward or revers order.
 
 @param list The linked list collection being enumerated. This collection is to
        be retained while the enumerator has not exhausted all its objects.
 @param startNode The node at which to begin the enumeration.
 @param endNode The node which signifies that enumerations should terminate.
 @param direction The direction in which to enumerate. Should be either
        <code>NSOrderedAscending</code> or <code>NSOrderedDescending</code>.
 @param mutations A pointer to the collection's mutation count, for invalidation.
 
 The enumeration direction is inferred from the state of the provided start node.
 If <code>startNode->next</code> is <code>NULL</code>, enumeration proceeds from
 back to front; otherwise, enumeration proceeds from front to back. This works
 since the head and tail nodes always have NULL for their <code>prev</code> and
 <code>next</code> links, respectively. When there is only one node, order won't
 matter anyway.
 
 This enumerator doesn't support enumerating over a sub-list of nodes. (When a
 node from the middle is provided, enumeration will proceed towards the tail.)
 */
- (id) initWithList:(CHDoublyLinkedList*)list
          startNode:(CHDoublyLinkedListNode*)startNode
            endNode:(CHDoublyLinkedListNode*)endNode
          direction:(NSComparisonResult)direction
    mutationPointer:(unsigned long*)mutations;

/**
 Returns the next object in the collection being enumerated.
 
 @return The next object in the collection being enumerated, or <code>nil</code>
         when all objects have been enumerated.
 */
- (id) nextObject;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
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
	if ([super init] == nil) return nil;
	collection = ([list count] > 0) ? [list retain] : nil;
	current = startNode;
	sentinel = endNode;
	if (direction != NSOrderedAscending && direction != NSOrderedDescending) {
		[NSException raise:NSInternalInconsistencyException
		            format:@"[%@ %s] -- Invalid enumeration direction.",
		                   [self class], sel_getName(_cmd)];	
	}	
	reverse = (direction == NSOrderedDescending) ? YES : NO;
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

// Sets "node" to point to the node found at the given index
// Must declare "CHDoublyLinkedListNode *node" and "NSUInteger nodeIndex" before
#define findNodeAtIndex(i) \
	if (i > count || i < 0) \
		CHIndexOutOfRangeException([self class], _cmd, index, count); \
	if (i<count/2) {\
		node=head->next; nodeIndex=0; while(i>nodeIndex++) node=node->next;\
	} else {\
		node=tail; nodeIndex=count; while(i<nodeIndex--) node=node->prev;\
	}

// Remove the node with a matching object, patch prev/next links around it
#define removeNode(node) \
	{ \
		node->prev->next = node->next; node->next->prev = node->prev; \
		[node->object release]; free(node); --count; ++mutations; \
	}

@implementation CHDoublyLinkedList

- (void) dealloc {
	[self removeAllObjects];
	[super dealloc];
}

- (id) init {
	if ([super init] == nil) return nil;
	head = malloc(kCHDoublyLinkedListNodeSize);
	tail = malloc(kCHDoublyLinkedListNodeSize);
	head->object = nil;
	head->next = tail;
	head->prev = NULL;
	tail->object = nil;
	tail->next = NULL;
	tail->prev = head;
	count = 0;
	mutations = 0;
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil) return nil;
	for (id anObject in anArray)
		[self appendObject:anObject];
	return self;
}

- (NSString*) description {
	return [[self allObjects] description];
}

#pragma mark <NSCoding> methods

/**
 Returns an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([self init] == nil) return nil;
	for (id anObject in [decoder decodeObjectForKey:@"objects"])
		[self appendObject:anObject];
	return self;
}

/**
 Encodes the receiver using a given archiver.
 
 @param encoder An archiver object.
 */
- (void) encodeWithCoder:(NSCoder *)encoder {
	NSArray *array = [[self objectEnumerator] allObjects];
	[encoder encodeObject:array forKey:@"objects"];
}

#pragma mark <NSCopying> Methods

/**
 Returns a new instance that is a copy of the receiver.
 
 @param zone The zone identifies an area of memory from which to allocate the
        new instance. If zone is <code>NULL</code>, the instance is allocated
        from the default zone.
 
 The returned object is implicitly retained by the sender, who is responsible
 for releasing it. For this class and its children, all copies are mutable.
 */
- (id) copyWithZone:(NSZone *)zone {
	CHDoublyLinkedList *newList = [[CHDoublyLinkedList alloc] init];
	for (id anObject in self)
		[newList appendObject:anObject];
	return newList;
}

#pragma mark <NSFastEnumeration> Methods

/**
 Returns by reference a C array of objects over which the sender should iterate,
 and as the return value the number of objects in the array.
 
 @param state Context information that is used in the enumeration to ensure that
        the collection has not been mutated, in addition to other possibilities.
 @param stackbuf A C array of objects over which the sender is to iterate.
 @param len The maximum number of objects to return in stackbuf.
 @return The number of objects returned in stackbuf, or 0 when iteration is done.
 */
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
	if (currentNode == NULL)
		state->state = 1; // used as a termination flag
	else
		state->state = (unsigned long)currentNode;
    return batchCount;
}

#pragma mark Insertion

- (void) prependObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:0];
}

- (void) prependObjectsFromArray:(NSArray*)anArray {
	for (id anObject in [anArray reverseObjectEnumerator])
		[self insertObject:anObject atIndex:0];
}

- (void) appendObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[self insertObject:anObject atIndex:count];
}

- (void) appendObjectsFromArray:(NSArray*)anArray {
	for (id anObject in anArray)
		[self insertObject:anObject atIndex:count];
}

- (void) insertObject:(id)anObject atIndex:(NSUInteger)index {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	
	CHDoublyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);
	
	CHDoublyLinkedListNode *newNode;
	newNode = malloc(kCHDoublyLinkedListNodeSize);
	newNode->object = [anObject retain];
	newNode->next = node;          // point forward to displaced node
	newNode->prev = node->prev;    // point backward to preceding node
	newNode->prev->next = newNode; // point preceding node forward to new node
	node->prev = newNode;          // point displaced node backward to new node
	++count;
	++mutations;
}

#pragma mark Access

- (NSUInteger) count {
	return count;
}

- (id) firstObject {
	tail->object = nil;
	return head->next->object; // nil if there are no objects between head/tail
}

- (id) lastObject {
	head->object = nil;
	return tail->prev->object; // nil if there are no objects between head/tail
}

- (NSArray*) allObjects {
	return [[self objectEnumerator] allObjects];
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

#pragma mark Search

- (BOOL) containsObject:(id)anObject {
	return ([self indexOfObject:anObject] != NSNotFound);
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([self indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (NSUInteger) indexOfObject:(id)anObject {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (![current->object isEqual:anObject]) {
		current = current->next;
		++index;
	}
	return (current == tail) ? NSNotFound : index;
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	NSUInteger index = 0;
	tail->object = anObject;
	CHDoublyLinkedListNode *current = head->next;
	while (current->object != anObject) {
		current = current->next;
		++index;
	}
	return (current == tail) ? NSNotFound : index;
}

- (id) objectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	
	CHDoublyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);
	return node->object;
}

#pragma mark Removal

- (void) removeFirstObject {
	if (count == 0)
		return;
	CHDoublyLinkedListNode *node = head->next;
	removeNode(node); // don't use head->next directly; macro treats as L-value
}

- (void) removeLastObject {
	if (count == 0)
		return;
	CHDoublyLinkedListNode *node = tail->prev;
	removeNode(node); // don't use tail->prev directly; macro treats as L-value
}

- (void) removeObject:(id)anObject {
	if (count == 0)
		return;
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while ([node->object compare:anObject] != NSOrderedSame)
			node = node->next;
		if (node != tail) {
			temp = node->next;
			removeNode(node);
			node = temp;
		}
	} while (node != tail);
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (count == 0)
		return;
	tail->object = anObject;
	CHDoublyLinkedListNode *node = head->next, *temp;
	do {
		while (node->object != anObject)
			node = node->next;
		if (node != tail) {
			temp = node->next;
			removeNode(node);
			node = temp;
		}
	} while (node != tail);
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	if (index >= count)
		CHIndexOutOfRangeException([self class], _cmd, index, count);
	
	CHDoublyLinkedListNode *node;
	NSUInteger nodeIndex;
	findNodeAtIndex(index);
	removeNode(node);
}

- (void) removeAllObjects {
	CHDoublyLinkedListNode *node = head->next, *temp;
	while (node != tail) {
		temp = node->next;
		[node->object release];
		free(node);
		node = temp;
	}
	head->next = tail;
	tail->prev = head;
	count = 0;
	++mutations;
}

@end
