/*
 CHMutableArrayHeap.h
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

#import <Foundation/Foundation.h>
#import "CHHeap.h"
#import "CHAbstractMutableArrayCollection.h"

/**
 @file CHMutableArrayHeap.h
 A simple CHHeap implemented using an NSMutableArray.
 */

/**
 A simple CHHeap implemented using an NSMutableArray.
 */
@interface CHMutableArrayHeap : CHAbstractMutableArrayCollection <CHHeap>
{
	NSComparisonResult sortOrder;
	unsigned long mutations; /**< Used to track mutations for NSFastEnumeration. */
	NSSortDescriptor *sortDescriptor;
}

@end
