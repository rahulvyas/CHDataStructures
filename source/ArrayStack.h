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

//  ArrayStack.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "Stack.h"

/**
 A fairly basic Stack implemented using an NSMutableArray.
 See the protocol definition for Stack to understand the programming contract.
 */
@interface ArrayStack : NSObject <Stack>
{
	/** The array used for storing the contents of the stack. */
	NSMutableArray *array;
}

/**
 Create a new stack starting with an NSMutableArray of the specified capacity.
 */
- (id) initWithCapacity:(NSUInteger)capacity;

/**
 Returns an enumerator that accesses each object in the stack from bottom to top.
 
 NOTE: When you use an enumerator, you must not modify the stack during enumeration.
 */
- (NSEnumerator*) reverseObjectEnumerator;

#pragma mark Method Implementations

- (id) init;
- (void) pushObject:(id)anObject;
- (id) popObject;
- (id) topObject;
- (NSArray*) allObjects;
- (NSUInteger) count;
- (void) removeAllObjects;
- (NSEnumerator*) objectEnumerator;

@end
