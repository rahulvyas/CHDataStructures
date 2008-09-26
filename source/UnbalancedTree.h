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

//  UnbalancedTree.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>
#import "AbstractTree.h"

/**
 Represents a node in an unbalanced binary tree, with 1 parent and 2 child links.
 */
typedef struct BinaryNode {
	id <Comparable> object;		/**< The object stored in a particular node. */
	struct BinaryNode *left;	/**< The left child node, if any. */
	struct BinaryNode *right;	/**< The right child node, if any. */
	struct BinaryNode *parent;	/**< The parent node, if not the root of the tree. */
} BinaryNode;

/** A simplification for malloc'ing tree nodes. */
#define bNODESIZE sizeof(struct BinaryNode)

#pragma mark -

/**
 A simple, unbalanced binary tree that <b>does not</b> guarantee O(log n) access.
 Even though the tree is never balanced when items are added or removed, access is
 <b>at worst</b> linear if the tree essentially degenerates into a linked list.
 This class is fast, and without stack risk because it works without recursion.
 In release 0.4.0, nodes objects were changed to C structs for enhanced performance.
 */
@interface UnbalancedTree : AbstractTree
{
	/** A pointer to the root of the tree, set to <code>NULL</code> if it is empty. */
	struct BinaryNode *root;
}

/**
 Create a new UnbalancedTree with no nodes or stored objects.
 */
- (id)init;

/**
 Create a new UnbalancedTree with a single root node that stores the given object.
 
 @param rootObject The node to treat as the root of the subtree to traverse.
 */
- (id)initWithObject:(id <Comparable>)rootObject;

#pragma mark Inherited Methods
- (void) addObject:(id <Comparable>)anObject;
- (id) findObject:(id <Comparable>)target;
- (id) findMin;
- (id) findMax;
- (BOOL)containsObject:(id <Comparable>)anObject;
- (void) removeObject:(id <Comparable>)anObject;
- (void)removeAllObjects;
- (NSEnumerator *)objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order;

@end

