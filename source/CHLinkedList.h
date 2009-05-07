/*
 CHDataStructures.framework -- CHLinkedList.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

/**
 @file CHLinkedList.h
 
 A <a href="http://en.wikipedia.org/wiki/Linked_list">linked list</a> protocol with methods that work for singly- or doubly-linked lists.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Linked_list">linked list</a> protocol with methods that work for singly- or doubly-linked lists.
 
 This type of data structure is useful for storing sparse data that will be traversed often. (Linked lists are very memory efficient when dealing with sparse data, unlike hashing and some array schemes.) Insertion and removal at either end of a list is extremely fast, but if fast random access (whether insertion, search, or removal) is desired, a linked list will generally incur a substantial performance penalty.
 
 Linked lists maintain references to both the start and end of the list, but there is no externally-visibly notion of state, such as a "current node". Implementations may choose to add indexing or hashing schemes to improve index-based or object-relative random access; several optional methods are included to allow such flexibility if desired. However, bear in mind that any such additions will increase memory cost and diminish the comparative advantages over classes such as NSMutableArray.
 
 Index-based operations are included in this protocol, but users should be aware that unless a subclass chooses to use a special indexing scheme, all index-based methods in a linked list are O(n). If indexed operations are used frequently, it is likely that a better alternative is to use an NSMutableArray.
 */ 
@protocol CHLinkedList <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a linked list with no objects.
 
 @see initWithArray:
 */
- (id) init;

/**
 Initialize a linked list with the contents of an array. Objects are appended in the order they occur in the array.
 
 @param anArray An array containing object with which to populate a new linked list.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Add an object to the front of the list.
 
 @param anObject The object to add to the list.

 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see appendObject:
 @see firstObject
 */
- (void) prependObject:(id)anObject;

/**
 Add an object to the back of the list.
 
 @param anObject The object to add to the list.
 
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 
 @see lastObject
 @see prependObject:
 */
- (void) appendObject:(id)anObject;

/**
 Inserts a given object at a given index. If @a index is already occupied, then objects at @a index and beyond are shifted one spot toward the end of the list.
 
 @param anObject The object to add to the list.
 @param index The index at which to insert @a anObject.
 
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 @throw NSRangeException If @a index is greater than the list size.
 
 @warning Inserting in the middle of a linked list is a somewhat inefficient operation; although values aren't shifted by one like in arrays, the list must be traversed to find the specified index.
 */
- (void) insertObject:(id)anObject atIndex:(NSUInteger)index;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array with the objects in this linked list, ordered front to back.
 
 @return An array with the objects in this linked list. If the list is empty,
 the array is also empty.
 
 @see count
 @see countByEnumeratingWithState:objects:count:
 @see objectEnumerator
 @see removeAllObjects
 */
- (NSArray*) allObjects;

/**
 Determines if a list contains a given object, matched using \link NSObject#isEqual: -isEqual:\endlink.
 
 @param anObject The object to check for membership in the receiver.
 @return @c YES if the receiver contains @a anObject (as determined by \link NSObject#isEqual: -isEqual:\endlink), @c NO if @a anObject is @c nil or not present.
 
 @see containsObjectIdenticalTo:
 @see removeObject:
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a list contains a given object, matched using the == operator.
 
 @param anObject The object to check for membership in the receiver.
 @return @c YES if the receiver contains @a anObject (as determined by the == operator), @c NO if @a anObject is @c nil or not present.
 
 @see containsObject:
 @see removeObjectIdenticalTo:
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the number of objects currently in the list.
 
 @return The number of objects currently in the list.
 
 @see allObjects
 */
- (NSUInteger) count;

/**
 Access the object at the head of the list.
 
 @return The object at the head of the list, or @c nil if the list is empty.
 
 @see lastObject
 @see removeFirstObject
 */
- (id) firstObject;

/**
 Access the object at the tail of the list.
 
 @return The object at the tail of the list, or @c nil if the list is empty.
 
 @see firstObject
 @see removeLastObject
 */
- (id) lastObject;

/**
 Returns the lowest indexof a given object, matched using @c isEqual:.
 
 @param anObject The object to be matched and located in the tree.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the list match @a anObject, returns @c CHNotFound.
 */
- (NSUInteger) indexOfObject:(id)anObject;

/**
 Returns the lowest indexof a given object, matched using the == operator.
 
 @param anObject The object to be matched and located in the tree.
 @return The index of the first object which is equal to @a anObject. If none of the objects in the list match @a anObject, returns @c CHNotFound.
 */
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;

/**
 Returns the object located at @a index.
 
 @param index An index from which to retrieve an object.
 @throw NSRangeException If @a index is greater than or equal to the list size.
 @return The object located at index.
 
 @see indexOfObject:
 @see indexOfObjectIdenticalTo:
 */
- (id) objectAtIndex:(NSUInteger)index;

/**
 Returns an enumerator that accesses each object in the list from front to back.
 
 @return An enumerator that accesses each object in the list from front to back. The enumerator returned is never @c nil; if the list is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see allObjects
 @see countByEnumeratingWithState:objects:count:
 */
- (NSEnumerator*) objectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the item at the head of the list.
 
 @see firstObject
 @see removeLastObject
 */
- (void) removeFirstObject;

/**
 Remove the item at the tail of the list.
 
 @see lastObject
 @see removeFirstObject
 */
- (void) removeLastObject;

/**
 Remove @b all occurrences of @a anObject, matched using @c isEqual:.
 
 @param anObject The object to remove from the list.
 
 If the list is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @note Use #indexOfObject: and #removeObjectAtIndex: to search for and remove only a specific match.
 
 @see containsObject:
 @see removeObjectIdenticalTo:
 */
- (void) removeObject:(id)anObject;

/**
 Remove @b all occurrences of @a anObject, matched using the == operator.
 
 @param anObject The object to remove from the list.
 
 If the list is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 
 @note Use #indexOfObjectIdenticalTo: and #removeObjectAtIndex: to search for and remove only a specific match.
 
 @see containsObjectIdenticalTo:
 @see removeObject:
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Removes the object at @a index. To fill the gap, elements beyond @a index have 1 subtracted from their index.
 
 @param index The index from which to remove the object.
 @throw NSRangeException If @a index is greater than or equal to the list size. 
 */
- (void) removeObjectAtIndex:(NSUInteger)index;

/**
 Remove all objects from the list; no effect if the list is already empty.
 
 @see removeFirstObject
 @see removeLastObject
 @see removeObject:
 @see removeObjectIdenticalTo:
 */
- (void) removeAllObjects;

// @}
#pragma mark <NSCoding>
/** @name <NSCoding> */
// @{

/**
 Initialize the receiver using data from a given keyed unarchiver.
 
 @param decoder A keyed unarchiver object.
 
 @see NSCoding protocol
 */
- (id) initWithCoder:(NSCoder *)decoder;

/**
 Encodes data from the receiver using a given keyed archiver.
 
 @param encoder A keyed archiver object.
 
 @see NSCoding protocol
 */
- (void) encodeWithCoder:(NSCoder *)encoder;

// @}
#pragma mark <NSCopying>
/** @name <NSCopying> */
// @{

/**
 Returns a new instance that is a mutable copy of the receiver. If garbage collection is @b not enabled, the copy is retained before being returned, but the sender is responsible for releasing it.
 
 @param zone An area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. 
 
 @note \link NSObject#copy -[NSObject copy]\endlink invokes this method with a @c nil argument.
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see NSFastEnumeration protocol
 @see allObjects
 @see objectEnumerator
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
@end
