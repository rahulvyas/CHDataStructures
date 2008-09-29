//  DataStructures.h
//  DataStructuresFramework

#import <Foundation/Foundation.h>

#pragma mark Framework Protocols

#import "Deque.h"
#import "Heap.h"
#import "LinkedList.h"
#import "Queue.h"
#import "Stack.h"
#import "Tree.h"

#pragma mark Framework Classes

#import "AbstractQueue.h"
#import "AbstractStack.h"
#import "AbstractTree.h"
#import "ArrayHeap.h"
#import "ArrayQueue.h"
#import "ArrayStack.h"
#import "Comparable.h"
#import "DoublyLinkedList.h"
#import "LLQueue.h"
#import "LLStack.h"
#import "RedBlackTree.h"
#import "UnbalancedTree.h"

/**
 @mainpage Overview
 
 This framework provides Objective-C interfaces and implementations of several data
 structures, a piece which many people have felt is a glaring omission from Apple's
 <a href="http://developer.apple.com/cocoa/">Cocoa frameworks</a>. Apple's stance is
 that the very flexible and optimized NSArray / NSDictionary / NSSet and children are
 enough, and usually they are sufficient, but sometimes an honest-to-goodness stack,
 queue, deque, linked list, tree, heap, etc. is what you really need or want.
 
 This project is an attempt to create a library of standard data structures which can
 be reliably used in any Objective-C program. It is currently distributed under the
 <a href="http://www.gnu.org/copyleft/lesser.html">GNU LGPL</a> and the source is
 available at <a href="http://www.phillipmorelock.com/examples/cocoadata/">this web
 page</a>. Data structures in this framework conform to Objective-C <i>protocols</i>
 (the predecessor of Java <i>interfaces</i>) that define the functionality and API
 for interacting with any implementation thereof, regardless of its internals.
 
 <!-- LGPL v.2 @ http://www.gnu.org/licenses/old-licenses/gpl-2.0.html -->
 
 Although we specifically target <a href="http://www.apple.com/macosx/">Mac OS X</a>,
 most of the code could be easily ported to other Objective-C environments, such as
 <a href="http://www.gnustep.org">GNUStep</a>. However, in the interest of code
 cleanliness and maintainability, such efforts would probably best be accomplished by
 forking this project's codebase, rather than integrating the two. (This is partially
 because OS X is by far the most prevalent Objective-C environment currently in use.)
  
 If you would like to contribute to the library or let me know that you use it, please 
 <a href="mailto:me@phillipmorelock.com?subject=DataStructuresFramework">email me</a>.  
 I am very receptive to help, criticism, flames, whatever.
 
         &mdash; <a href="http://www.phillipmorelock.com/">Phillip Morelock</a>, 2002

 
 
 @todo Add support for invalidating enumerators when the underlying data is mutated.
 
 @todo Consider adding <code>-makeObjectsPerform:</code> and
       <code>-makeObjectsPerform:with:</code>
 
 @todo Consider adding <code>-replaceObject:withObject:</code>
 */
