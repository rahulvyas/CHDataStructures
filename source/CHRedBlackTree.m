/*
 CHRedBlackTree.m
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

#import "CHRedBlackTree.h"

static NSUInteger kCHBalancedTreeNodeSize = sizeof(CHBalancedTreeNode);
static NSUInteger kCHTREE_SIZE = sizeof(CHTREE_NODE);

/**
 An NSEnumerator for traversing a CHRedBlackTree in a specified order.
 
 NOTE: Tree enumerators are tricky to do without recursion.
 Consider using a stack to store path so far?
 */
@interface CHRedBlackTreeEnumerator : NSEnumerator
{
	CHTraversalOrder traversalOrder;
	@private
	id<CHTree> collection;
	CHBalancedTreeNode *currentNode;
	CHBalancedTreeNode *sentinelNode;
	id tempObject;         /**< Temporary variable, holds the object to be returned.*/
	CHTREE_NODE *stack;     /**< Pointer to the top of a stack for most traversals. */
	CHTREE_NODE *queue;     /**< Pointer to the head of a queue for level-order. */
	CHTREE_NODE *queueTail; /**< Pointer to the tail of a queue for level-order. */
	CHTREE_NODE *tmp;       /**< Temporary variable for stack and queue operations. */
	unsigned long mutationCount;
	unsigned long *mutationPtr;
}

/**
 Create an enumerator which traverses a given (sub)tree in the specified order.
 
 @param tree The tree collection that is being enumerated. This collection is to be
             retained while the enumerator has not exhausted all its objects.
 @param root The root node of the (sub)tree whose elements are to be enumerated.
 @param sentinel The sentinel value used at the leaves of this Red-Black tree.
 @param order The traversal order to use for enumerating the given (sub)tree.
 @param mutations A pointer to the collection's count of mutations, for invalidation.
 */
- (id) initWithTree:(id<CHTree>)tree
               root:(CHBalancedTreeNode*)root
           sentinel:(CHBalancedTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations;

/**
 Returns an array of objects the receiver has yet to enumerate.
 
 @return An array of objects the receiver has yet to enumerate.
 
 Invoking this method exhausts the remainder of the objects, such that subsequent
 invocations of #nextObject return <code>nil</code>.
 */
- (NSArray*) allObjects;

/**
 Returns the next object from the collection being enumerated.
 
 @return The next object from the collection being enumerated, or <code>nil</code>
 when all objects have been enumerated.
 */
- (id) nextObject;

@end

#pragma mark -

@implementation CHRedBlackTreeEnumerator

- (id) initWithTree:(id<CHTree>)tree
               root:(CHBalancedTreeNode*)root
           sentinel:(CHBalancedTreeNode*)sentinel
     traversalOrder:(CHTraversalOrder)order
    mutationPointer:(unsigned long*)mutations
{
	if ([super init] == nil || !isValidTraversalOrder(order)) return nil;
	stack = NULL;
	traversalOrder = order;
	collection = (root != sentinel) ? collection = [tree retain] : nil;
	if (traversalOrder == CHTraverseLevelOrder) {
		queue = NULL;
		CHTREE_ENQUEUE(root);
	} else if (traversalOrder == CHTraversePreOrder) {
		CHTREE_PUSH(root);
	} else {
		currentNode = root;
	}
	sentinel->object = nil;
	sentinelNode = sentinel;
	mutationCount = *mutations;
	mutationPtr = mutations;
	return self;
}

- (void) dealloc {
	[collection release];
	[super dealloc];
}

- (NSArray*) allObjects {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object;
	while ((object = [self nextObject]))
		[array addObject:object];
	[collection release];
	collection = nil;
	return [array autorelease];
}

/**
 @see UnbalancedTreeEnumerator#nextObject
 */
- (id) nextObject {
	if (mutationCount != *mutationPtr)
		CHMutatedCollectionException([self class], _cmd);

	switch (traversalOrder) {
		case CHTraverseAscending:
			if (stack == NULL && currentNode == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (currentNode != sentinelNode) {
				CHTREE_PUSH(currentNode);
				currentNode = currentNode->left;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = CHTREE_TOP; // Save top node for return value
			CHTREE_POP();
			tempObject = currentNode->object;
			currentNode = currentNode->right;
			return tempObject;
			
		case CHTraverseDescending:
			if (stack == NULL && currentNode == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (currentNode != sentinelNode) {
				CHTREE_PUSH(currentNode);
				currentNode = currentNode->right;
				// TODO: How to not push/pop leaf nodes unnecessarily?
			}
			currentNode = CHTREE_TOP; // Save top node for return value
			CHTREE_POP();
			tempObject = currentNode->object;
			currentNode = currentNode->left;
			return tempObject;
			
		case CHTraversePreOrder:
			currentNode = CHTREE_TOP;
			CHTREE_POP();
			if (currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			if (currentNode->right != sentinelNode)
				CHTREE_PUSH(currentNode->right);
			if (currentNode->left != sentinelNode)
				CHTREE_PUSH(currentNode->left);
			return currentNode->object;
			
		case CHTraversePostOrder:
			// This algorithm from: http://www.johny.ca/blog/archives/05/03/04/
			if (stack == NULL && currentNode == sentinelNode) {
				[collection release];
				collection = nil;
				return nil;
			}
			while (1) {
				while (currentNode != sentinelNode) {
					CHTREE_PUSH(currentNode);
					currentNode = currentNode->left;
				}
				// A null entry indicates that we've traversed the right subtree
				if (CHTREE_TOP != NULL) {
					currentNode = CHTREE_TOP->right;
					CHTREE_PUSH(NULL);
					// TODO: explore how to not use null pad for leaf nodes
				}
				else {
					CHTREE_POP(); // ignore the null pad
					tempObject = CHTREE_TOP->object;
					CHTREE_POP();
					return tempObject;
				}				
			}
			
		case CHTraverseLevelOrder:
			currentNode = CHTREE_FRONT;
			if (currentNode == NULL) {
				[collection release];
				collection = nil;
				return nil;
			}
			CHTREE_DEQUEUE();
			if (currentNode->left != sentinelNode)
				CHTREE_ENQUEUE(currentNode->left);
			if (currentNode->right != sentinelNode)
				CHTREE_ENQUEUE(currentNode->right);
			return currentNode->object;
	}
	return nil;
}

@end

#pragma mark -

// C Functions for Optimized Operations

CHBalancedTreeNode * _rotateNodeWithLeftChild(CHBalancedTreeNode *node) {
	CHBalancedTreeNode *leftChild = node->left;
	node->left = leftChild->right;
	leftChild->right = node;
	node->color = kRED;
	leftChild->color = kBLACK;
	return leftChild;
}

CHBalancedTreeNode * _rotateNodeWithRightChild(CHBalancedTreeNode *node) {
	CHBalancedTreeNode *rightChild = node->right;
	node->right = rightChild->left;
	rightChild->left = node;
	node->color = kRED;
	rightChild->color = kBLACK;
	return rightChild;
}

CHBalancedTreeNode* _rotateObjectOnAncestor(id anObject, CHBalancedTreeNode *ancestor) {
	if ([ancestor->object compare:anObject] == NSOrderedDescending) {
		return ancestor->left =
			([ancestor->left->object compare:anObject] == NSOrderedDescending)
				? _rotateNodeWithLeftChild(ancestor->left)
				: _rotateNodeWithRightChild(ancestor->left);
	}
	else {
		return ancestor->right =
			([ancestor->right->object compare:anObject] == NSOrderedDescending)
				? _rotateNodeWithLeftChild(ancestor->right)
				: _rotateNodeWithRightChild(ancestor->right);
	}
}

CHBalancedTreeNode* singleRotate(CHBalancedTreeNode *node, BOOL goingRight) {
	CHBalancedTreeNode *save = node->link[!goingRight];
	node->link[!goingRight] = save->link[goingRight];
	save->link[goingRight] = node;
	node->color = kRED;
	save->color = kBLACK;
	return save;
}

CHBalancedTreeNode* doubleRotate(CHBalancedTreeNode *node, BOOL goingRight) {
	node->link[!goingRight] = singleRotate(node->link[!goingRight], !goingRight);
	return singleRotate(node, goingRight);	
}

#pragma mark -

@implementation CHRedBlackTree

#pragma mark - Private Methods

- (void) _reorient:(id)anObject {
	// Color flip
	current->color = kRED;
	current->left->color = kBLACK;
	current->right->color = kBLACK;
	// Fix red violation
	if (parent->color == kRED) 	{
		grandparent->color = kRED;
		if ([grandparent->object compare:anObject] != [parent->object compare:anObject])
			parent = _rotateObjectOnAncestor(anObject, grandparent);
		current = _rotateObjectOnAncestor(anObject, greatgrandparent);
		current->color = kBLACK;
	}
	header->right->color = kBLACK;  // Always reset root to black
}

#pragma mark - Public Methods

- (id) init {
	if ([super init] == nil) return nil;
	sentinel = malloc(kCHBalancedTreeNodeSize);
	sentinel->object = nil;
	sentinel->color = kBLACK;
	sentinel->right = sentinel;
	sentinel->left = sentinel;
	
	header = malloc(kCHBalancedTreeNodeSize);
	header->object = [CHAbstractTreeHeaderObject headerObject];
	header->color = kBLACK;
	header->left = sentinel;
	header->right = sentinel;
	return self;
}

- (void) dealloc {
	[self removeAllObjects];
	free(header);
	free(sentinel);
	[super dealloc];
}

/*
 Basically, as you walk down the tree to insert, if the present node has two
 red children, you color it red and change the two children to black. If its
 parent is red, the tree must be rotated. (Just change the root's color back
 to black if you changed it). Returns without incrementing the count if the
 object already exists in the tree.
 */
- (void) addObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);

	++mutations;
	grandparent = parent = current = header;
	sentinel->object = anObject;
	
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) {
		greatgrandparent = grandparent, grandparent = parent, parent = current;
		current = current->link[comparison == NSOrderedAscending];
		
		// Check for the bad case of red parent and red sibling of parent
		if (current->left->color == kRED && current->right->color == kRED) {
			// Simple red violation: resolve with color flip
			current->color = kRED;
			current->left->color = kBLACK;
			current->right->color = kBLACK;
			
			// Hard red violation: rotations necessary
			if (parent->color == kRED) {
//				BOOL lastWentRight = (grandparent->right == parent);
//				greatgrandparent->link[greatgrandparent->right == grandparent]
//					= (parent->link[lastWentRight])
//						? singleRotate(grandparent, !lastWentRight)
//						: doubleRotate(grandparent, !lastWentRight);
				grandparent->color = kRED;
				if ([grandparent->object compare:anObject] != [parent->object compare:anObject])
					parent = _rotateObjectOnAncestor(anObject, grandparent);
				current = _rotateObjectOnAncestor(anObject, greatgrandparent);
				current->color = kBLACK;
			}
		}
	}
	
	// If we didn't end up at a sentinel, replace the existing value and return.
	if (current != sentinel) {
		[anObject retain];
		[current->object release];
		current->object = anObject;
		return;
	}
	
	++count;
	current = malloc(kCHBalancedTreeNodeSize);
	current->object = [anObject retain];
	current->left = sentinel;
	current->right = sentinel;
	
	parent->link[([parent->object compare:anObject] == NSOrderedAscending)] = current;
	
	// one last reorientation check...
	[self _reorient:anObject];
}

- (BOOL) containsObject:(id)anObject {
	if (anObject == nil)
		return NO;
	sentinel->object = anObject; // Make sure the target value is always "found"
	current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel);
}

- (id) findMax {
	sentinel->object = nil;
	current = header->right;
	while (current->right != sentinel)
		current = current->right;
	return current->object;
}

- (id) findMin {
	sentinel->object = nil;
	current = header->right;
	while (current->left != sentinel)
		current = current->left;
	return current->object;
}

- (id) findObject:(id)anObject {
	if (anObject == nil)
		return nil;
	sentinel->object = anObject; // Make sure the target value is always "found"
	current = header->right;
	NSComparisonResult comparison;
	while (comparison = [current->object compare:anObject]) // while not equal
		current = current->link[comparison == NSOrderedAscending]; // R on YES
	return (current != sentinel) ? current->object : nil;
}

- (void) removeObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	if (header->right == sentinel)
		return;
	
	++mutations;
	grandparent = parent = current = header;
	sentinel->object = anObject;
	CHBalancedTreeNode *found = NULL, *sibling;
	NSComparisonResult comparison;
	BOOL isGoingRight = YES, prevWentRight = YES;
	while (current->link[isGoingRight] != sentinel) {
		grandparent = parent;
		parent = current;
		current = current->link[isGoingRight];
		comparison = [current->object compare:anObject];
		prevWentRight = isGoingRight;
		isGoingRight = (comparison != NSOrderedDescending);
		if (comparison == NSOrderedSame)
			found = current; // Save a pointer; removal happens outside the loop
		
		// There are only potential violations when removing a black node.
		// If so, push the child red node down using rotations and color flips.
		if (current->color != kRED && current->link[isGoingRight]->color != kRED) {
			if (current->link[!isGoingRight]->color == kRED)
				parent = parent->link[prevWentRight] = singleRotate(current, isGoingRight);
			else {
				sibling = parent->link[prevWentRight];
				if (sibling != sentinel) {
					if (sibling->left->color == kBLACK && sibling->right->color == kBLACK) {
						// If sibling's children are both black, do a color flip
						parent->color = kBLACK;
						sibling->color = kRED;
						current->color = kRED;
					}
					else {
						CHBalancedTreeNode *tempNode =
							grandparent->link[(grandparent->right == parent)];
						if (sibling->link[prevWentRight]->color == kRED)
							tempNode = doubleRotate(parent, prevWentRight);
						else if (sibling->link[!prevWentRight]->color == kRED)
							tempNode = singleRotate(parent, prevWentRight);
						/* Ensure correct coloring */
						current->color = tempNode->color = kRED;
						tempNode->left->color = kBLACK;
						tempNode->right->color = kBLACK;
					}
				} // if (sibling != sentinel)
			}
		}
	}
	
	// Transfer replacement value up to outgoing node, remove the "donor" node.
    if (found != NULL) {
		[found->object release];
		found->object = current->object;
		parent->link[(parent->right == current)]
			= current->link[(current->left == sentinel)];
		free(current);
		--count;
    }
	header->right->color = kBLACK; // Make the root black for simplified logic
}

- (void) removeAllObjects {
	CHBalancedTreeNode *currentNode;
	CHTREE_NODE *queue = NULL;
	CHTREE_NODE *queueTail = NULL;
	CHTREE_NODE *tmp;
	
	CHTREE_ENQUEUE(header->right);
	while (currentNode = CHTREE_FRONT) {
		CHTREE_DEQUEUE();
		if (currentNode->left != sentinel)
			CHTREE_ENQUEUE(currentNode->left);
		if (currentNode->right != sentinel)
			CHTREE_ENQUEUE(currentNode->right);
		[currentNode->object release];
		free(currentNode);
	}
	header->right = sentinel;
	count = 0;
	++mutations;
}

- (NSEnumerator*) objectEnumeratorWithTraversalOrder:(CHTraversalOrder)order {
	return [[[CHRedBlackTreeEnumerator alloc] initWithTree:self
                                                      root:header->right
                                                  sentinel:sentinel
                                            traversalOrder:order
                                           mutationPointer:&mutations] autorelease];
}

#pragma mark <NSFastEnumeration> Methods

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	CHBalancedTreeNode *currentNode;
	CHTREE_NODE *stack, *tmp; 
	
	// For the first call, start at root node, otherwise start at last saved node
	if (state->state == 0) {
		currentNode = header->right;
		state->itemsPtr = stackbuf;
		state->mutationsPtr = &mutations;
		stack = NULL;
	}
	else if (state->state == 1) {
		return 0;		
	}
	else {
		currentNode = (CHBalancedTreeNode*) state->state;
		stack = (CHTREE_NODE*) state->extra[0];
	}
	
	// Accumulate objects from the tree until we reach all nodes or the maximum limit
	NSUInteger batchCount = 0;
	while ( (currentNode != sentinel || stack != NULL) && batchCount < len) {
		while (currentNode != sentinel) {
			CHTREE_PUSH(currentNode);
			currentNode = currentNode->left;
			// TODO: How to not push/pop leaf nodes unnecessarily?
		}
		currentNode = CHTREE_TOP; // Save top node for return value
		CHTREE_POP();
		stackbuf[batchCount] = currentNode->object;
		currentNode = currentNode->right;
		batchCount++;
	}
	
	if (currentNode == sentinel && stack == NULL)
		state->state = 1; // used as a termination flag
	else {
		state->state = (unsigned long) currentNode;
		state->extra[0] = (unsigned long) stack;
	}
	return batchCount;
}

- (NSString*) debugDescription {
	NSMutableString *description = [NSMutableString stringWithFormat:
									@"<%@: 0x%x> = {\n", [self class], self];
	CHBalancedTreeNode *currentNode;
	CHTREE_NODE *queue = NULL, *queueTail = NULL, *tmp;
	CHTREE_ENQUEUE(header->right);
	
	sentinel->object = nil;
	while (currentNode != sentinel && queue != NULL) {
		currentNode = CHTREE_FRONT;
		CHTREE_DEQUEUE();
		if (currentNode->left != sentinel)
			CHTREE_ENQUEUE(currentNode->left);
		if (currentNode->right != sentinel)
			CHTREE_ENQUEUE(currentNode->right);
		// Append entry for the current node, including color and children
		[description appendFormat:@"\t%@ : %@ -> %@ and %@\n",
		 ((currentNode->color == kRED) ? @"RED  " : @"BLACK"),
		 currentNode->object, currentNode->left->object, currentNode->right->object];
	}
	[description appendString:@"}"];
	return description;
}

@end
