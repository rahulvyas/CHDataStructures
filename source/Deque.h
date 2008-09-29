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

//  Deque.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

/**
 A <a href="http://en.wikipedia.org/wiki/Deque">deque</a> protocol with methods for
 insertion and removal on both ends of a queue.
 
 @todo Add support for methods in NSCoding, NSMutableCopying, and NSFastEnumeration.
 */
@protocol Deque <NSObject>

/**
 Add an object to the front of the deque.
 
 @param anObject The object to add to the deque; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObjectToFront:(id)anObject;

/**
 Add an object to the back of the deque.
 
 @param anObject The object to add to the deque; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObjectToBack:(id)anObject;

/**
 Examine the first object in the deque without removing it.
 
 @return The first object in the deque, or <code>nil</code> if the deque is empty.
 */
- (id) firstObject;

/**
 Examine the last object in the deque without removing it.
 
 @return The last object in the deque, or <code>nil</code> if the deque is empty.
 */
- (id) lastObject;

/**
 Remove and return the first object in the deque.
 
 @return The first object in the deque, or <code>nil</code> if the deque is empty.
 */
- (id) removeFirstObject;

/**
 Remove and return the last object in the deque.
 
 @return The last object in the deque, or <code>nil</code> if the deque is empty.
 */
- (id) removeLastObject;

/**
 Determines if a deque contains a given object, matched using <code>isEqual:</code>.
 
 @param anObject The object to test for membership in the deque.
 */
- (BOOL) containsObject:(id)anObject;

/**
 Determines if a deque contains a given object, matched using the == operator.
 
 @param anObject The object to test for membership in the deque.
 */
- (BOOL) containsObjectIdenticalTo:(id)anObject;

/**
 Returns the number of objects currently in the deque.
 
 @return The number of objects currently in the deque.
 */
- (NSUInteger) count;

/**
 Create an autoreleased Deque with the contents of the array in the specified order.
 
 @param array An array of objects to add to the queue.
 @param direction The order in which to enqueue objects from the array. YES means the 
        natural index order (0...n), NO means reverse index order (n...0).
 */
+ (id) dequeWithArray:(NSArray *)array ofOrder:(BOOL)direction;

@end
