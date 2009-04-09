/*
 CHDataStructures.framework -- CHMutableArrayQueue.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 Copyright (c) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHMutableArrayQueue.h"

@implementation CHMutableArrayQueue

#pragma mark Queue Implementation

- (void) addObject: (id)anObject {
	if (anObject == nil)
		CHNilArgumentException([self class], _cmd);
	else
		[array addObject:anObject];
}

- (id) firstObject {
	@try {
		return [array objectAtIndex:0];
	}
	@catch (NSException *exception) {}
	return nil;
}

- (id) lastObject {
	return [array lastObject];
}

- (void) removeFirstObject {
	@try {
		[array removeObjectAtIndex:0];
	}
	@catch (NSException *exception) {}
}

@end
