/*
 CHDataStructures.framework -- CHSortedDictionary.m
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHSortedDictionary.h"
#import "CHAVLTree.h"

@implementation CHSortedDictionary

- (id) initWithObjects:(id*)objects forKeys:(id*)keys count:(NSUInteger)count {
	// Create collection for ordering keys first, since super will add objects.
	sortedKeys = [[CHAVLTree alloc] init];
	if ((self = [super initWithObjects:objects
	                           forKeys:keys
	                             count:count]) == nil) return nil;
	return self;
}

/** @todo Check whether keys are equal on decode, fix if they aren't. */
- (id) initWithCoder:(NSCoder *)decoder {
	if ((self = [super initWithCoder:decoder]) == nil) return nil;
	sortedKeys = [[decoder decodeObjectForKey:@"sortedKeys"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeObject:sortedKeys forKey:@"sortedKeys"];
}

#pragma mark Adding Objects

- (void) setObject:(id)anObject forKey:(id)aKey {
	if (!CFDictionaryContainsKey(dictionary, aKey)) {
		id clonedKey = [[aKey copy] autorelease];
		[sortedKeys addObject:clonedKey];
		CFDictionarySetValue(dictionary, clonedKey, anObject);
	}
}

#pragma mark Querying Contents

- (NSUInteger) count {
	return CFDictionaryGetCount(dictionary);
}

- (NSEnumerator*) keyEnumerator {
	return [sortedKeys objectEnumerator];
}

- (id) firstKey {
	return [sortedKeys firstObject];
}

- (id) lastKey {
	return [sortedKeys lastObject];
}

#pragma mark Removing Objects

- (void) removeAllObjects {
	[sortedKeys removeAllObjects];
	[super removeAllObjects];
}

- (void) removeObjectForKey:(id)aKey {
	if (CFDictionaryContainsKey(dictionary, aKey)) {
		[sortedKeys removeObject:aKey];
		CFDictionaryRemoveValue(dictionary, aKey);
	}
}

- (void) removeObjectForFirstKey {
	[self removeObjectForKey:[sortedKeys firstObject]];
}

- (void) removeObjectForLastKey {
	[self removeObjectForKey:[sortedKeys lastObject]];
}

@end
