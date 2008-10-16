//  CHAbstractMutableArrayCollection.h
//  CHDataStructures.framework

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

#import <Foundation/Foundation.h>

/**
 An abstract class which implements many common behaviors of array-based collections.
 This class has a single instance variable on which all the implemented methods act,
 and also conforms to several protocols:
 
 - NSCoding
 - NSCopying
 - NSMutableCopying
 - NSFastEnumeration
 
 This class also contains concrete implementations for the following methods:
 
 <pre><code>
 -(NSUInteger) count
 -(NSString*) description
 -(NSEnumerator*) objectEnumerator
 -(NSEnumerator*) reverseObjectEnumerator
 -(NSArray*) allObjects
 -(void) removeAllObjects
 
 -(BOOL) containsObject:
 -(BOOL) containsObjectIdenticalTo:
 -(NSUInteger) indexOfObject:
 -(NSUInteger) indexOfObjectIdenticalTo:
 -(id) objectAtIndex:
 </code></pre>

 Rather than enforcing that this class be abstract, the contract is implied. In any
 case, instances of this class will be useless since there is no way to add objects.
 */
@interface CHAbstractMutableArrayCollection : NSObject
	<NSCoding, NSCopying, NSMutableCopying, NSFastEnumeration>
{
	/** The array used for storing the contents of the data collection. */
	NSMutableArray *array;
}

/**
 Create a new collection with the contents of the given array.
 */
- (id) initWithArray:(NSArray*)anArray;

/**
 Create a new collection starting with an NSMutableArray of the specified capacity.
 */
- (id) initWithCapacity:(NSUInteger)capacity;

// These methods are undocumented here so they don't cause duplicated documentation.
// For details, see the subclasses of this class, or CHDeque, CHQueue, and CHStack.

- (NSUInteger) count;
- (NSEnumerator*) objectEnumerator;
- (NSEnumerator*) reverseObjectEnumerator;
- (NSArray*) allObjects;
- (void) removeAllObjects;

- (BOOL) containsObject:(id)anObject;
- (BOOL) containsObjectIdenticalTo:(id)anObject;
- (NSUInteger) indexOfObject:(id)anObject;
- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject;
- (id) objectAtIndex:(NSUInteger)index;


@end
