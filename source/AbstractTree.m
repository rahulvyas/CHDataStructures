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

//  Tree.m
//  DataStructuresFramework

#import "AbstractTree.h"
#import "LLStack.h"

@implementation AbstractTree

+ (id) exceptionForUnsupportedOperation:(SEL)operation {
	[NSException raise:NSInternalInconsistencyException
				format:@"+[%@ %s] -- Unsupported operation.",
					   [self class], sel_getName(operation)];
	return nil;
}

- (id) exceptionForUnsupportedOperation:(SEL)operation {
	[NSException raise:NSInternalInconsistencyException
				format:@"-[%@ %s] -- Unsupported operation.",
					   [self class], sel_getName(operation)];
	return nil;
}

- (id) exceptionForInvalidArgument:(SEL)operation {
	[NSException raise:NSInvalidArgumentException
				format:@"-[%@ %s] -- Invalid nil argument.",
					   [self class], sel_getName(operation)];
	return nil;
}


#pragma mark Default Implementations

- (void) addObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
}

/**
 Uses an NSEnumerator to add each object to the tree.
 */
- (void) addObjectsFromArray:(NSArray *)anArray {
	NSEnumerator *e = [anArray objectEnumerator];
	id object;
	while ((object = [e nextObject]) != nil) {
		[self addObject:object];
	}
}


- (BOOL) containsObject:(id)anObject {
	[self exceptionForUnsupportedOperation:_cmd];
	return NO;
}

- (NSUInteger) count {
	return count;
}

- (void) removeObject:(id)element {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (void) removeAllObjects {
	[self exceptionForUnsupportedOperation:_cmd];
}

- (id) findMin {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (id) findMax {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (id) findObject:(id)anObject {
	return [self exceptionForUnsupportedOperation:_cmd];
}

#pragma mark Convenience Constructors

+ (id<Tree>) treeWithEnumerator:(NSEnumerator*)enumerator {
	id<Tree> tree = [[self alloc] init];
	for (id object in enumerator) {
		[tree addObject:object];
	}
	return [tree autorelease];
}

+ (id<Tree>) treeWithFastEnumeration:(id<NSFastEnumeration>)collection {
	id<Tree> tree = [[self alloc] init];
	for (id object in collection) {
		[tree addObject:object];
	}
	return [tree autorelease];
}

#pragma mark Collection Conversions

- (NSSet *) contentsAsSet {
	NSMutableSet *set = [[NSMutableSet alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:CHTraversePreOrder]) {
		[set addObject:object];
	}
	return [set autorelease];
}

- (NSArray *) contentsAsArrayWithOrder:(CHTraversalOrder)order {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:order]) {
		[array addObject:object];
	}
	return [array autorelease];
	// Document that the returned object is mutable? Return immutable copy instead?
}

- (id <Stack>) contentsAsStackWithInsertionOrder:(CHTraversalOrder)order {
	id <Stack> stack = [[LLStack alloc] init];
	for (id object in [self objectEnumeratorWithTraversalOrder:order]) {
		[stack push:object];
	}
	return [stack autorelease];
}

#pragma mark Object Enumerators

/* Must be specified by concrete child classes. */
- (NSEnumerator *) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [self exceptionForUnsupportedOperation:_cmd];
}

- (NSEnumerator *) objectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseInOrder];
}

- (NSEnumerator *) reverseObjectEnumerator {
	return [self objectEnumeratorWithTraversalOrder:CHTraverseReverseOrder];
}

@end
