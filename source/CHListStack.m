/*
 CHDataStructures.framework -- CHListStack.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHListStack.h"
#import "CHSinglyLinkedList.h"

/**
 This implementation uses a CHSinglyLinkedList, since it's slightly faster than using a CHDoublyLinkedList, and requires a little less memory. Also, since it's a stack, it's unlikely that there is any need to enumerate over the object from bottom to top.
 */
@implementation CHListStack

- (id) init {
	if ([super init] == nil) return nil;
	list = [[CHSinglyLinkedList alloc] init];
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil) return nil;
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in anArray)
#else
	NSEnumerator *e = [anArray objectEnumerator];
	id anObject;
	while (anObject = [e nextObject])
#endif
	{
		[list prependObject:anObject];
	}
	return self;
}

- (void) pushObject:(id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	[list prependObject:anObject];
}

- (id) topObject {
	return [list firstObject];
}

- (void) popObject {
	[list removeFirstObject];
}

@end
