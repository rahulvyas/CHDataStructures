/*
 CHDataStructures.framework -- CHBidirectionalDictionary.m
 
 Copyright (c) 2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHBidirectionalDictionary.h"

@implementation CHBidirectionalDictionary

- (void) dealloc {
	if (inverse != nil)
		inverse->inverse = nil; // Unlink from inverse dictionary if one exists.
	if (reversed != NULL)
		CFRelease(reversed);
	[super dealloc];
}

- (id) initWithCapacity:(NSUInteger)numItems {
	if ((self = [super initWithCapacity:numItems]) == nil) return nil;
	createCollectableCFMutableDictionary(&reversed, numItems);
	return self;
}

- (id) initWithDictionary:(NSDictionary*)otherDictionary {
	return (self = [super initWithDictionary:otherDictionary]);
}

#pragma mark Querying Contents

- (CHBidirectionalDictionary*) inverseDictionary {
	if (inverse == nil) {
		inverse = [[CHBidirectionalDictionary alloc] init];
		if (kCHGarbageCollectionNotEnabled)
			CFRelease(inverse->dictionary);
		CFRetain(inverse->dictionary = reversed);
		CFRetain(inverse->reversed = dictionary);
		inverse->inverse = self;
	}
	return inverse;
}

- (id) keyForObject:(id)anObject {
	return (id)CFDictionaryGetValue(reversed, anObject);
}

- (NSEnumerator*) objectEnumerator {
	return [(id)reversed keyEnumerator];
}

#pragma mark Modifying Contents

- (void) addEntriesFromDictionary:(NSDictionary*)otherDictionary {
	[super addEntriesFromDictionary:otherDictionary];
}

- (void) removeAllObjects {
	[super removeAllObjects];
	CFDictionaryRemoveAllValues(reversed);
}

- (void) removeKeyForObject:(id)anObject {
	[super removeObjectForKey:[self keyForObject:anObject]];
	CFDictionaryRemoveValue(reversed, anObject);
}

- (void) removeObjectForKey:(id)aKey {
	CFDictionaryRemoveValue(reversed, [self objectForKey:aKey]);
	[super removeObjectForKey:aKey];
}

- (void) setObject:(id)anObject forKey:(id)aKey {
	if (anObject == nil || aKey == nil)
		CHNilArgumentException([self class], _cmd);
	// Remove existing key -> ?  and value -> ? mappings if they currently exist.
	CFDictionaryRemoveValue(dictionary, CFDictionaryGetValue(reversed, anObject));
	CFDictionaryRemoveValue(reversed, CFDictionaryGetValue(dictionary, aKey));
	id key = [[aKey copy] autorelease];
	id value = [[anObject copy] autorelease];
	CFDictionarySetValue(dictionary, key, value); // May replace key-value pair
	CFDictionarySetValue(reversed, value, key); // May replace value-key pair
}

@end
