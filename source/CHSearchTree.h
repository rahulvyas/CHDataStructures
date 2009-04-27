/*
 CHDataStructures.framework -- CHSearchTree.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import "Util.h"

/**
 @file CHSearchTree.h
 
 A protocol which specifes an interface for N-ary search trees.
 */

/**
 A set of constant values denoting the order in which to traverse a tree structure. For details, see: http://en.wikipedia.org/wiki/Tree_traversal#Traversal_methods
 */
typedef enum {
	CHTraverseAscending,   /**< Visit left subtree, node, then right subtree. */
	CHTraverseDescending,  /**< Visit right subtree, node, then left subtree. */
	CHTraversePreOrder,    /**< Visit node, left subtree, then right subtree. */
	CHTraversePostOrder,   /**< Visit left subtree, right subtree, then node. */
	CHTraverseLevelOrder   /**< Visit nodes from left-right, top-bottom. */
} CHTraversalOrder;

#define isValidTraversalOrder(o) (o>=CHTraverseAscending && o<=CHTraverseLevelOrder)

/**
 A protocol which specifes an interface for search trees, whether the customary <a href="http://en.wikipedia.org/wiki/Binary_search_tree">binary tree</a>, an N-ary tree structure, or any similary tree-like structure. The protocol defines methods that support insertion, removal, search, and object enumeration. Though any conforming class must implement all these methods, they may document that certain of them are unsupported, and/or raise exceptions when they are called.
 
 Objects are inserted according to their sorted order, so they must respond to the @c -compare: selector, which accepts another object and returns @c NSOrderedAscending, @c NSOrderedSame, or @c NSOrderedDescending (constants in <a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_DataTypes/Reference/reference.html#//apple_ref/c/tdef/NSComparisonResult">NSComparisonResult</a>) as the receiver is less than, equal to, or greater than the argument, respectively. (Several Cocoa classes already implement the @c -compare: method, including NSString, NSDate, NSNumber, NSDecimalNumber, and NSCell.) 
 
 There are several methods for visiting each node in a tree data structure, known as <a href="http://en.wikipedia.org/wiki/Tree_traversal">tree traversal</a> techniques. (Traversal applies to N-ary trees, not just binary trees.) Whereas linked lists and arrays have one or two logical means of stepping through the elements, because trees are branching structures, there are many different ways to choose how to visit all of the nodes. There are 5 most commonly-used tree traversal methods; of these, 4 are depth first and 1 is breadth-first. These methods are described below:
 
 <table align="center" width="100%" border="0" cellpadding="0">
 <tr>
 <td style="vertical-align: bottom">
 @image html tree-traversal.png "Figure 1 — A sample binary search tree."
 </td>
 <td style="vertical-align: bottom" align="center">
 
 <table style="border-collapse: collapse;">
 <tr style="background: #ddd;">
     <th>#</th> <th>Traversal</th>     <th>Visit Order</th> <th>Node Ordering</th>
 </tr>
 <tr><td>1</td> <td>In-order</td>      <td>L, node, R</td> <td>A B C D E F G H I</td></tr>
 <tr><td>2</td> <td>Reverse-order</td> <td>R, node, L</td> <td>I H G F E D C B A</td></tr>
 <tr><td>3</td> <td>Pre-order</td>     <td>node, L, R</td> <td>F B A D C E G I H</td></tr>
 <tr><td>4</td> <td>Post-order</td>    <td>L, R, node</td> <td>A C E D B H I G F</td></tr>
 <tr><td>5</td> <td>Level-order</td>   <td>L→R, T→B</td>   <td>F B G A D I C E H</td></tr>
 </table>
 <p><strong>Table 1 - Various tree traversals on Figure 1.</strong></p>
 
 </td></tr>
 </table>
 
 These orderings correspond to the following constants, respectively:
 
 <ol>
 <li>@c CHTraverseAscending
 <li>@c CHTraverseDescending
 <li>@c CHTraversePreOrder
 <li>@c CHTraversePostOrder
 <li>@c CHTraverseLevelOrder
 </ol>
 
 These constants are used primarily in connection with \link #objectEnumeratorWithTraversalOrder: -objectEnumeratorWithTraversalOrder:\endlink for enumerating over objects from a search tree in a specified order.
 
 @todo Modify protocol and subclasses to decide whether to allow duplicates. (This will allow trees to act either as sorted lists or sorted sets.)
 
 @todo Add -containsObjectIdenticalTo: and -removeObjectIdenticalTo: methods. (Obviously, this makes more sense once duplicates are optionally allowed.)
 */
@protocol CHSearchTree <NSObject, NSCoding, NSCopying, NSFastEnumeration>

/**
 Initialize a search tree with no objects.
 */
- (id) init;

/**
 Initialize a search tree with the contents of an array. Objects are added to the tree in the order they occur in the array.
 
 @param anArray An array containing object with which to populate a new tree.
 */
- (id) initWithArray:(NSArray*)anArray;

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Add an object to the tree. Ordering is based on an object's response to the @c -compare: message. Since no duplicates are allowed, if the tree already contains an object for which a @c -compare: message returns @c NSOrderedSame, that object is released and replaced by @a anObject.
 
 @param anObject The object to add to the search tree.
 @throw NSInvalidArgumentException If @a anObject is @c nil.
 */
- (void) addObject:(id)anObject;

/**
 Adds the objects in a given array to the tree. Ordering is based on an object's response to the @c -compare: message. Since no duplicates are allowed, if the tree already contains an object in the array for which a @c -compare: message returns @c NSOrderedSame, that object is released and replaced by the object from the array.
 
 @param anArray An array of objects to add to the tree.
 */
- (void) addObjectsFromArray:(NSArray*)anArray;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns an NSArray containing the objects in this tree in ascending order.
 
 @return An array containing the objects in this tree. If the tree is empty, the array is also empty.
 */
- (NSArray*) allObjects;

/**
 Returns an NSArray which contains the objects in this tree in a given ordering. The object traversed last will appear last in the array.
 
 @param order The traversal order to use for enumerating the given tree.
 @return An array containing the objects in this tree. If the tree is empty, the array is also empty.
 */
- (NSArray*) allObjectsWithTraversalOrder:(CHTraversalOrder)order;

/**
 Returns the number of objects currently in the tree.
 */
- (NSUInteger) count;

/**
 Returns an enumerator that accesses each object using a given traversal order.
 
 @param order The order in which an enumerator should traverse nodes in the tree. @return An enumerator that accesses each object in the tree in a given order. The enumerator returned is never @c nil; if the tree is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see \link #objectEnumerator -objectEnumerator\endlink
 @see \link #reverseObjectEnumerator -reverseObjectEnumerator\endlink
 */
- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order;

/**
 Determines if the tree contains a given object (or one identical to it). Matches are based on an object's response to the @c isEqual: message.
 
 @param anObject The object to test for membership in the search tree.
 @return @c YES if @a anObject is in the tree, @c NO if it is @c nil or not present.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Returns the maximum object in the tree.
 
 @return The maximum object in the tree, or @c nil if empty.
 */
- (id) findMax;

/**
 Returns the minimum object in the tree.
 
 @return The minimum object in the tree, or @c nil if empty.
 */
- (id) findMin;

/**
 Return object for which @c -compare: returns @c NSOrderedSame.
 
 @param anObject The object to be matched and located in the tree.
 @return The object which matches @a anObject, or @c nil if no match is found.
 */
- (id) findObject:(id)anObject;

/**
 Returns an enumerator that accesses each object in the tree in ascending order.
 
 @return An enumerator that accesses each object in the tree in ascending order. The enumerator returned is never @c nil; if the tree is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 
 @see \link #objectEnumeratorWithTraversalOrder: -objectEnumeratorWithTraversalOrder:\endlink
 */
- (NSEnumerator*) objectEnumerator;

/**
 Returns an enumerator that accesses each object in the tree in descending order.
 
 @return An enumerator that accesses each object in the tree in descending order. The enumerator returned is never @c nil; if the tree is empty, the enumerator will always return @c nil for \link NSEnumerator#nextObject -nextObject\endlink and an empty array for \link NSEnumerator#allObjects -allObjects\endlink.
 
 @attention The enumerator retains the collection. Once all objects in the enumerator have been consumed, the collection is released.
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.

 @see \link #objectEnumeratorWithTraversalOrder: -objectEnumeratorWithTraversalOrder:\endlink
 */
- (NSEnumerator*) reverseObjectEnumerator;

// @}
#pragma mark Removing Objects
/** @name Removing Objects */
// @{

/**
 Remove object for which @c -compare: returns @c NSOrderedSame. If no matching object exists, there is no effect.
 
 @param anObject The object to be removed from the tree.
 
 If the tree is empty, @a anObject is @c nil, or no object matching @a anObject is found, there is no effect, aside from the possible overhead of searching the contents.
 */
- (void) removeObject:(id)anObject;

/**
 Remove all objects from the tree; if it is already empty, there is no effect.
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
 
 @param state Context information used to track progress of an enumeration.
 @param stackbuf Pointer to a C array into which the receiver may copy objects for the sender to iterate over.
 @param len The maximum number of objects that may be stored in @a stackbuf.
 @return The number of objects in @c state->itemsPtr that may be iterated over, or @c 0 when the iteration is finished.
 
 @warning Modifying a collection while it is being enumerated is unsafe, and may cause a mutation exception to be raised.
 @see NSFastEnumeration protocol
 */
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len;

// @}
@end
