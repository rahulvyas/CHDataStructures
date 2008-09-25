/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyright for this specific file as acknowledged herein.
 
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

//  Heap.h
//  DataStructuresFramework

//  Copyright (c) 2002 Gordon Worley redbird@rbisland.cx
//  Minor contributions by Phillip Morelock for purposes of library integration.
//  Many thanks to Gordon for the very first outside contribution to the library!

#import <Foundation/Foundation.h>
#import "Comparable.h"

/**
 A <a href="http://en.wikipedia.org/wiki/Heap_(data_structure)">heap</a> protocol,
 suitable for use with many variations of the heap structure.
 */
@protocol Heap <NSObject>

/**
 Insert a given object into the heap.

 @param anObject The object to add to the heap; must not be <code>nil</code>, or an
        <code>NSInvalidArgumentException</code> will be raised.
 */
- (void) addObject:(id <Comparable>)anObject;

/**
 Remove and return the first element in the heap. Rearranges the remaining elements.
 
 @return The first element in the heap, or <code>nil</code> if the heap is empty.
 */
- (id) removeRoot;

/**
 Remove and return the last element in the heap.
 
 @return The last element in the heap, or <code>nil</code> if the heap is empty.
 */
- (id) removeLast;

/**
 Returns the number of objects currently in the heap.
 
 @return The number of objects currently in the heap.
 */
- (unsigned int) count;

// NOTE: For a future release:

//- (void) addObjectsFromCollection:(id)collection

//- (void) addObjectsFromHeap:(id<Heap>)otherHeap;

//- (id) initWithSortOrder:(NSComparisonResult)sortOrder; // for min/max heaps

@end
