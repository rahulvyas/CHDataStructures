//
//  CHBinaryTreeQueue.h
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHAbstractBinarySearchTree.h"

@interface CHBinaryTreeQueue : NSObject {
	__strong CHBinaryTreeNode** queue;
	NSUInteger queueCapacity;
	NSUInteger queueHead;
	NSUInteger queueTail;
}

- (id) init;

- (void) enqueue:(CHBinaryTreeNode *)node;
- (void) dequeue;
- (CHBinaryTreeNode *) front;

@end
