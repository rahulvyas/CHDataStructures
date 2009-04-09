/*
 CHDataStructures.framework -- CHHeap.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHHeap.h
 
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol, suitable for use with many variations of the heap structure.
 */

/**
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol, suitable for use with many variations of the heap structure.
 
 Since objects in a Heap are inserted according to their sorted order, all objects must respond to the <code>compare:</code> selector, which accepts another object and returns NSOrderedAscending, NSOrderedSame, or NSOrderedDescending as the receiver is less than, equal to, or greater than the argument, respectively. (See NSComparisonResult in NSObjCRuntime.h for details.) 
 */
@protocol CHHeap <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a heap with ascending ordering and no objects.
 */
- (id) init;

/**
 Initialize a heap with the contents of an array. Objects are added to the heap as they occur in the array, then sorted using <code>NSOrderedAscending</code>.
 
 @param anArray An array containing object with which to populate a new heap.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Initialize a heap with a given sort ordering and no objects.
 
 @param order The sort order to use, either <code>NSOrderedAscending</code> or <code>NSOrderedDescending</code>. The root element of the heap will be the smallest or largest (according to <code>-compare:</code>), respectively. For any other value, an <code>NSInvalidArgumentException</code> is raised.
 */
- (id) initWithOrdering:(NSComparisonResult)order;

/**
 Initialize a heap with a given sort ordering and objects from the given array.
 
 @param order The sort order to use, either <code>NSOrderedAscending</code> or <code>NSOrderedDescending</code>. The root element of the heap will be the smallest or largest (according to <code>-compare:</code>), respectively. For any other value, an <code>NSInvalidArgumentException</code> is raised.
 @param anArray An array containing objects to be added to this heap.
 */
- (id) initWithOrdering:(NSComparisonResult)order array:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Insert a given object into the heap.
 
 @param anObject The object to add to the heap.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 */
- (void) addObject:(id)anObject;

/**
 Adds the objects in a given array to this heap, then re-establish the heap property. After all the objects have been inserted, objects are percolated down the heap as necessary, starting from @c count/2 and decrementing to @c 0.
 
 @param anArray An array of objects to add to the heap.
 */
- (void) addObjectsFromArray:(NSArray*)anArray;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an array containing the objects in this heap in their current order. This order is almost certainly not sorted (since only the heap property need be satisfied) but this is the quickest way to retrieve all the elements in a heap.
 
 @return An array containing the objects in this heap in their current order. If the heap is empty, the array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns an array containing the objects in this heap in sorted order.
 
 <div class="warning">
 @b Warning: Since a heap structure is only "sorted" as elements are removed, this incurs extra costs for sorting and storing the duplicate array. However, it does not affect the order of elements in the heap itself.
 </div>
 
 @return An array containing the objects in this heap in sorted order. If the heap is empty, the array is also empty.
 */
- (NSArray*) allObjectsInSortedOrder;

/**
 Determines if a heap contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the heap.
 @return @c YES if @a anObject is in the heap, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a heap contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the heap.
 @return @c YES if @a anObject is in the heap, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the number of objects currently in the heap.
 
 @return The number of objects currently in the heap.
 */
- (NSUInteger) count;

/**
 Examine the first object in the heap without removing it.
 
 @return The first object in the heap, or @c nil if the heap is empty.
 */
- (id) firstObject;

/**
 Returns an enumerator that accesses each object in the heap in sorted order.
 
 @return An enumerator that accesses each object in the heap in sorted order. The enumerator returned is never @c nil; if the heap is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 <div class="warning">
 @b Warning: Requesting objects from an enumerator whose underlying collection has been modified is unsafe, and may cause a mutation exception to be raised.
 </div>
 
 This enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 
 Uses an NSArray returned by #allObjects, so all the same caveats apply.
 
 @see #allObjects
 */
- (NSEnumerator*) objectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove the front object in the heap; if it is already empty, there is no effect.
 */
- (void) removeFirstObject;

/**
 Remove all occurrences of a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to be removed from the heap.
 
 If the heap does not contain @a anObject, there is no effect, although it does incur the overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to be removed from the heap.
 
 If the heap does not contain @a anObject, there is no effect, although it does incur the overhead of searching the contents.
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Remove all objects from the heap; if it is already empty, there is no effect.
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
 Returns a new instance that is a mutable copy of the receiver. The copy is implicitly retained by the sender, who is responsible for releasing it.
 
 @param zone Identifies an area of memory from which to allocate the new instance. If zone is @c nil, the default zone is used. (The \link NSObject#copy -copy\endlink method in NSObject invokes this method with a @c nil argument.)
 
 @see NSCopying protocol
 */
- (id) copyWithZone:(NSZone *)zone;

// @}
#pragma mark <NSFastEnumeration>
/** @name <NSFastEnumeration> */
// @{

/**
 Called within <code>@b for (type variable @b in collection)</code> constructs. Returns by reference a C array of objects over which the sender should iterate, and as the return value the number of objects in the array.
 
 <div class="warning">
 @b Warning: Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 </div>
 
 @param state Context information used to track progress of an enumeration..
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @see NSFastEnumeration protocol
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
@end
