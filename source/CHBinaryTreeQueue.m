//
//  CHBinaryTreeQueue.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CHBinaryTreeQueue.h"


@implementation CHBinaryTreeQueue

- (id) init {
	self = [super init];
	if (self) {
		queueCapacity = 128;
		queue = NSAllocateCollectable(kCHPointerSize*queueCapacity, NSScannedOption);
		queueHead = 0;
		queueTail = 0;
	}
	return self;
}

- (void) _cleanup {
	if (queue != NULL && kCHGarbageCollectionNotEnabled) {
		free(queue);
	}
	queue = NULL;
}

- (void) dealloc {
	[self _cleanup];
	[super dealloc];
}

- (void) finalize {
	[self _cleanup];
	[super finalize];
}

#pragma mark Queue

- (void) enqueue:(CHBinaryTreeNode *)node {
	queue[queueTail++] = node;
	queueTail %= queueCapacity;
	if (queueHead == queueTail) {
		queue = NSReallocateCollectable(queue, kCHPointerSize*queueCapacity*2, NSScannedOption);
		/* Copy wrapped-around portion to end of queue and move tail index */
		objc_memmove_collectable(queue+queueCapacity, queue, kCHPointerSize*queueTail);
		/* Zeroing out shifted memory can simplify debugging queue problems */
		/*bzero(queue, kCHPointerSize*queueTail);*/
		queueTail += queueCapacity;
		queueCapacity *= 2;
	}
}

- (CHBinaryTreeNode *) front {
	return ((queueHead != queueTail) ? queue[queueHead] : NULL);
}

- (void) dequeue {
	if (queueHead != queueTail) {
		queueHead = (queueHead + 1) % queueCapacity;
	}
}

@end
