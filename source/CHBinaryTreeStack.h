//
//  CHBinaryTreeStack.h
//  CHDataStructures
//
//  Created by Dave DeLong on 1/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHAbstractBinarySearchTree.h"

@interface CHBinaryTreeStack : NSObject {
	__strong CHBinaryTreeNode** stack;
	NSUInteger stackCapacity;
	NSUInteger stackSize;
}

- (id) init;

- (void) push:(CHBinaryTreeNode *)node;
- (CHBinaryTreeNode *) pop;
- (CHBinaryTreeNode *) top;

- (NSUInteger) stackSize;

@end
