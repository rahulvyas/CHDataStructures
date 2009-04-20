/*
 CHDataStructures.framework -- CHDataStructures.h
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>

// Protocols
#import "CHDeque.h"
#import "CHHeap.h"
#import "CHLinkedList.h"
#import "CHQueue.h"
#import "CHSearchTree.h"
#import "CHStack.h"

// Concrete Implementations
#import "CHAnderssonTree.h"
#import "CHAVLTree.h"
#import "CHCircularBufferDeque.h"
#import "CHCircularBufferQueue.h"
#import "CHCircularBufferStack.h"
#import "CHDoublyLinkedList.h"
#import "CHListDeque.h"
#import "CHListQueue.h"
#import "CHListStack.h"
#import "CHLockable.h"
#import "CHMultiMap.h"
#import "CHMutableArrayDeque.h"
#import "CHMutableArrayHeap.h"
#import "CHMutableArrayQueue.h"
#import "CHMutableArrayStack.h"
#import "CHRedBlackTree.h"
#import "CHSinglyLinkedList.h"
#import "CHTreap.h"
#import "CHUnbalancedTree.h"

// Utilities
#import "Util.h"

/**
 @file CHDataStructures.h
 
 An umbrella header which imports all the public header files for the framework. Headers for individual classes have minimal dependencies, and they import any other header files they may require. For example, this header does not import any of the CHAbstract... header files (since only subclasses use them), but all such headers are still included with the framework. (The protocols for abstract data types are imported so clients can use protocol-typed variables if needed.)
 */

/**
 @mainpage Overview
 
 <strong>CHDataStructures.framework</strong> <http://cocoaheads.byu.edu/code/CHDataStructures> is an open-source library of standard data structures which can be used in any Objective-C program, for educational purposes or as a foundation for other data structures to build on. Data structures in this framework adopt Objective-C protocols that define the functionality of and API for interacting with any implementation thereof, regardless of its internals.
 
 Apple's extensive and flexible <a href="http://developer.apple.com/cocoa/">Cocoa frameworks</a> include several collections classes that are highly optimized and amenable to many situations. However, sometimes an honest-to-goodness stack, queue, linked list, tree, etc. can greatly improve the clarity and comprehensibility of code. This framework provides Objective-C implementations of common data structures which are currently beyond the purview of Cocoa.
 
 The currently supported abstract data type protocols include:
 - CHDeque
 - CHHeap
 - CHLinkedList
 - CHQueue
 - CHSearchTree
 - CHStack
 
 The code is written for <a href="http://www.apple.com/macosx/">Mac OS X</a> and does use some features of <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/ObjectiveC/">Objective-C 2.0</a> which shipped with Mac OS X 10.5 "Leopard". Most of the code could be  ported to other Objective-C environments (such as <a href="http://www.gnustep.org">GNUStep</a>) without too much trouble. However, such efforts would probably be better accomplished by forking this project rather than integrating with it, for several main reasons:
 
 <ol>
 <li>Supporting multiple environments increases code complexity, and consequently the effort required to test, maintain, and improve it.</li>
 <li>Libraries that have bigger and slower binaries to accommodate all possible platforms don't help the mainstream developer.</li>
 <li>Mac OS X is by far biggest user of Objective-C today, a trend which isn't likely to change soon.</li>
 </ol>
 
 While certain implementations utilize straight C for their internals, this framework is fairly high-level, and uses composition rather than inheritance in most cases. The framework was originally written as an exercise in writing Objective-C code and consisted mainly of ported Java code. In later revisions, performance has gained greater emphasis, but the primary motivation is to provide friendly, intuitive Objective-C interfaces for data structures, not to maximize speed at any cost, which sometimes happens with C++ and the STL. The algorithms should all be sound (i.e., you won't get O(n) performance where it should be O(log n) or O(1), etc.) and perform quite well in general. If your choice of data structure type and implementation are dependent on performance or memory usage, it would be wise to run the benchmarks from Xcode and choose based on the time and memory complexity for specific implementations.
 
 This framework is is licensed under a variant of the <a href="http://www.isc.org/software/license">ISC license</a>, an extremely simple and permissive free software license approved by the <a href="http://www.fsf.org/licensing/licenses#ISC">Free Software Foundation (FSF)</a> and <a href="http://opensource.org/licenses/isc-license.txt">Open Source Initiative (OSI)</a>. The license for this framework is included in every source file, and is repoduced in its entirety here:
 
 <div style="margin: 0 30px; text-align: justify;"><em>Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.<br><br>The software is provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.</em></div>
 
 This license is functionally equivalent to the MIT and two-clause BSD licenses, and replaces the previous use of the <a href="http://www.gnu.org/copyleft/lesser.html">GNU Lesser General Public License (LGPL)</a>, which is much more complex and frequently misunderstood. In addition, using GPL-style licenses (which are generally unfriendly towards commercial software) makes little sense for Mac developers, whether open-source or proprietary.
 
 If you would like to contribute to the library or let me know that you use it, please <a href="mailto:quinntaylor@mac.com?subject=CHDataStructures.framework">email me</a>. I am very receptive to help, criticism, flames, whatever.
 
   &mdash; <a href="http://homepage.mac.com/quinntaylor/">Quinn Taylor</a>
 */
