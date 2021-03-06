/*
 CHDataStructures.framework -- CHAbstractBinarySearchTree_Internal.h
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHAbstractBinarySearchTree.h"

/**
 @file CHAbstractBinarySearchTree_Internal.h
 Contains \#defines for performing various traversals of binary search trees.
 
 This file is a private header that is only used by internal implementations, and is not included in the the compiled framework. The macros and variables are to be considered private and unsupported.
 
 Memory for stacks and queues is (re)allocated using NSScannedOption, since (if garbage collection is enabled) the nodes which may be placed in a stack or queue are known to the garbage collector. (If garbage collection is @b not enabled, the macros explicitly free the allocated memory.) We assume that a stack or queue will not outlive the nodes it contains, since they are only used in connection with an active tree (usually during insertion, removal or iteration). An enumerator may contain a stack or queue, but also retains the underlying collection, so correct retain-release calls will not leak.
 */

@interface CHAbstractBinarySearchTree ()

// NOTE: Subclasses should override the following methods to display any algorithm-specific information (such as the extra field used by self-balancing trees) in debugging output and generated DOT graphs.

// This method determines the appearance of nodes in the graph produced by -debugDescription, and may be overriden by subclasses. The default implementation returns the -description for the object in the node, surrounded by quote marks.
- (NSString*) debugDescriptionForNode:(CHBinaryTreeNode*)node;

// This method determines the appearance of nodes in the graph produced by -dotGraphString, and may be overriden by subclasses. The default implementation creates an oval containing the value returned by -description for the object in the node.
- (NSString*) dotGraphStringForNode:(CHBinaryTreeNode*)node;

@end

#pragma mark -

/**
 Convenience function for allocating a new CHBinaryTreeNode. This centralizes the allocation so all subclasses can be sure they're allocating nodes correctly. Explicitly sets the "extra" field used by self-balancing trees to zero.
 
 @param anObject The object to be stored in the @a object field of the struct; may be @c nil.
 @return An struct allocated with @c NSAllocateCollectable() and @c NSScannedOption  so the garbage collector (if enabled) will scan the object stored in the node, as well as the node's children (if any).
 */
HIDDEN CHBinaryTreeNode* CHCreateBinaryTreeNodeWithObject(id anObject);

// These are used by subclasses; marked as HIDDEN to reduce external visibility.
HIDDEN OBJC_EXPORT size_t kCHBinaryTreeNodeSize;

#import "CHBinaryTreeStack.h"
#import "CHBinaryTreeQueue.h"