/************************
A Cocoa DataStructuresFramework
Copyright (C) 2002  Phillip Morelock in the United States
http://www.phillipmorelock.com
Other copyrights for this specific file as acknowledged herein.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*******************************/

//  LinkedList.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

/**
 A basic linked list interface.
 I am trying to remove methods from the protocols to be more "bare bones."
 I received some very good criticism that I was making a hack job of these protocols.
 */ 
@protocol LinkedList <NSObject>

/**
 Returns the number of objects currently in the list.
 
 @return The number of objects currently in the list.
 */
- (unsigned int) count;

/**
 Determines if a list contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the list.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a list contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the list.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Inserts a given object at a given index. If index is already occupied, the objects
 at index and beyond are shifted by adding 1 to their indices to make room.
 
 @param anObject The object to add to the list. This value must not be <code>nil</code>.
 @param index The index in the receiver at which to insert anObject. This value must
        not be greater than the count of elements in the array.
 */
- (void) insertObject:(id)anObject atIndex:(unsigned int)index;

/**
 Returns the object located at <i>index</i>.
 
 @param index An index within the bounds of the receiver.
 @return The object located at index.
 */
- (id) objectAtIndex:(unsigned int)index;

/**
 Add an object at the head of the list.
 
 @param anObject The object to add to the list (must not be <code>nil</code>).
 */
- (void) addFirst:(id)anObject;

/**
 Add an object at the tail of the list.
 
 @param anObject The object to add to the list (must not be <code>nil</code>).
 */
- (void) addLast:(id)anObject;

/**
 Access the object at the head of the list.

 @return The object with the lowest index, or <code>nil</code> if the list is empty.
 */
- (id) first;

/**
 Access the object at the tail of the list.
 
 @return The object with the highest index, or <code>nil</code> if the list is empty.
 */
- (id) last;

/**
 Remove the item at the head of the list.
 */
- (void) removeFirst;

/**
 Remove the item at the tail of the list.
 */
- (void) removeLast;

/**
 Remove all occurrences of a given object , matched using <code>isEqual:</code>.
 
 @param anObject The object to remove from the list.

 If the list does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 */
- (void) removeObject:(id)anObject;

/**
 Remove all occurrences of a given object, matched using the == operator.
 
 @param anObject The object to remove from the list.
 
 If the list does not contain <i>anObject</i>, the method has no effect (although it
 does incur the overhead of searching the contents).
 */
- (void) removeObjectIdenticalTo:(id)anObject;

/**
 Removes the object at <i>index</i>.
 
 @param index The index from which to remove the object. The value must not exceed
        the bounds of the receiver. To fill the gap, all elements beyond <i>index</i>
        are moved by subtracting 1 from their index.
 */
- (void) removeObjectAtIndex:(unsigned int)index;

/**
 Remove all objects from the list. If the list is already empty, there is no effect.
 */
- (void) removeAllObjects;

/**
 Returns an enumerator object that provides access to each object in the receiver.
 
 @return An enumerator object that lets you access each object in the receiver, from
         the element at the lowest index upwards.
 */
- (NSEnumerator *) objectEnumerator;

/**
 Create an autoreleased LinkedList with the contents of the array in the given order.
 YES means that the linked list will be indexed (0...n) like your array, whereas NO
 means that the list will be ordered (n...0).
 */
+ (id <LinkedList>) listFromArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
