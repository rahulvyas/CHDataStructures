/*
 CHDataStructures.framework -- CHAbstractMutableArrayCollection.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHAbstractMutableArrayCollection.h"

@implementation CHAbstractMutableArrayCollection

- (void) dealloc {
	[array release];
	[super dealloc];
}

// This is the designated initializer for CHAbstractMutableArrayCollection.
- (id) init {
	if ([super init] == nil) return nil;
	array = [[NSMutableArray alloc] init];
	return self;
}

- (id) initWithArray:(NSArray*)anArray {
	if ([self init] == nil) return nil;
	[array addObjectsFromArray:anArray];
	return self;
}

#pragma mark <NSCoding>

- (id) initWithCoder:(NSCoder*)decoder {
	if ([super init] == nil) return nil;
	array = [[decoder decodeObjectForKey:@"array"] retain];
	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:array forKey:@"array"];
}

#pragma mark <NSCopying>

- (id) copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithArray:array];
}

#pragma mark <NSFastEnumeration>

#if MAC_OS_X_VERSION_10_5_AND_LATER
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState*)state
                                   objects:(id*)stackbuf
                                     count:(NSUInteger)len
{
	return [array countByEnumeratingWithState:state objects:stackbuf count:len];
}
#endif

#pragma mark -

- (NSUInteger) count {
	return [array count];
}

- (BOOL) containsObject:(id)anObject {
	return [array containsObject:anObject];
}

- (BOOL) containsObjectIdenticalTo:(id)anObject {
	return ([array indexOfObjectIdenticalTo:anObject] != NSNotFound);
}

- (void) exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
	[array exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (NSUInteger) indexOfObject:(id)anObject {
	return [array indexOfObject:anObject];
}

- (NSUInteger) indexOfObjectIdenticalTo:(id)anObject {
	return [array indexOfObjectIdenticalTo:anObject];
}

- (id) objectAtIndex:(NSUInteger)index {
	return [array objectAtIndex:index];
}

- (void) removeObject:(id)anObject {
	if (anObject == nil || [array count] == 0)
		return;
	[array removeObject:anObject];
}

- (void) removeObjectIdenticalTo:(id)anObject {
	if (anObject == nil || [array count] == 0)
		return;
	[array removeObjectIdenticalTo:anObject];
}

- (void) removeObjectAtIndex:(NSUInteger)index {
	[array removeObjectAtIndex:index];
}

- (void) removeAllObjects {
	[array removeAllObjects];
}

- (NSArray*) allObjects {
	return [[array copy] autorelease];
}

- (NSEnumerator*) objectEnumerator {
	return [array objectEnumerator];
}

- (NSEnumerator*) reverseObjectEnumerator {
	return [array reverseObjectEnumerator];
}

- (NSString*) description {
	return [array description];
}

@end
