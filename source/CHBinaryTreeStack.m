//
//  CHBinaryTreeStack.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CHBinaryTreeStack.h"
#import "CHAbstractBinarySearchTree_Internal.h"

@implementation CHBinaryTreeStack

- (id) init {
	self = [super init];
	if (self) {
		stackCapacity = 32;
		stack = NSAllocateCollectable(kCHBinaryTreeNodeSize*stackCapacity, NSScannedOption); \
		stackSize = 0;
	}
	return self;
}

- (void) _cleanup {
	if (stack != NULL && kCHGarbageCollectionNotEnabled) {
		free(stack);
	}
	stack = NULL;
}

- (void) dealloc {
	[self _cleanup];
	[super dealloc];
}

- (void) finalize {
	[self _cleanup];
	[super finalize];
}

#pragma mark -

- (void) push:(CHBinaryTreeNode *)node {
	stack[stackSize++] = node;
	if (stackSize >= stackCapacity) {
		stackCapacity *= 2;
		stack = NSReallocateCollectable(stack, kCHPointerSize*stackCapacity, NSScannedOption);
	}
}

- (CHBinaryTreeNode *) pop {
	return ((stackSize > 0) ? stack[--stackSize] : NULL);
}

- (CHBinaryTreeNode *) top {
	return ((stackSize > 0) ? stack[stackSize-1] : NULL);
}

@end
