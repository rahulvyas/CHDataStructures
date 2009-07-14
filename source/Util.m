/*
 CHDataStructures.framework -- Util.m
 
 Copyright (c) 2008-2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "Util.h"

BOOL kCHGarbageCollectionNotEnabled = YES; // A variable declared extern in Util.h
static BOOL initialized = NO;

void initializeGCStatus() {
	if (!initialized) {
		// Discover whether garbage collection is enabled (if running on 10.5+).
		// This bit of hackery avoids linking errors via indirect invocation.
		// (On previous version of OS X, NSGarbageCollector doesn't even exist.)
		Class gcClass = NSClassFromString(@"NSGarbageCollector");
		if (gcClass != nil) {
			id collector = objc_msgSend(gcClass, @selector(defaultCollector));
			kCHGarbageCollectionNotEnabled = (collector == nil);
		}
		initialized = YES;
	}
}

void CHIndexOutOfRangeException(Class aClass, SEL method,
                                NSUInteger index, NSUInteger elements) {
	[NSException raise:NSRangeException
	            format:@"[%@ %s] -- Index (%d) out of range (0-%d).",
	                   aClass, sel_getName(method), index, elements-1];
}

void CHInvalidArgumentException(Class aClass, SEL method, NSString *string) {
	[NSException raise:NSInvalidArgumentException
	            format:@"[%@ %s] -- %@",
	                   aClass, sel_getName(method), string];
}

void CHNilArgumentException(Class aClass, SEL method) {
	CHInvalidArgumentException(aClass, method, @"Invalid nil argument.");
}

void CHMutatedCollectionException(Class aClass, SEL method) {
	[NSException raise:NSGenericException
	            format:@"[%@ %s] -- Collection was mutated during enumeration.",
	                   aClass, sel_getName(method)];
}

void CHUnsupportedOperationException(Class aClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
	            format:@"[%@ %s] -- Unsupported operation.",
	                   aClass, sel_getName(method)];
}

void CHQuietLog(NSString *format, ...) {
	if (format == nil) {
		printf("(null)\n");
		return;
	}
	// Get a reference to the arguments that follow the format parameter
	va_list argList;
	va_start(argList, format);
	// Do format string argument substitution, reinstate %% escapes, then print
	NSMutableString *string = [[NSMutableString alloc] initWithFormat:format
	                                                        arguments:argList];
	NSRange range;
	range.location = 0;
	range.length = [string length];
	[string replaceOccurrencesOfString:@"%%" withString:@"%%%%" options:0 range:range];
	printf("%s\n", [string UTF8String]);
	[string release];
	va_end(argList);
}

#pragma mark -

BOOL collectionsAreEqual(id collection1, id collection2) {
	if ([collection1 count] != [collection2 count])
		return NO;
	NSEnumerator *otherObjects = [collection2 objectEnumerator];
#if MAC_OS_X_VERSION_10_5_AND_LATER
	for (id anObject in collection1)
#else
	NSEnumerator *objects = [collection1 objectEnumerator];
	id anObject;
	while (anObject = [objects nextObject])
#endif
		if (![anObject isEqual:[otherObjects nextObject]])
			return NO;
	return YES;	
}

NSUInteger hashOfCountAndObjects(NSUInteger count, id object1, id object2) {
	NSUInteger hash = 17 * count ^ (count << 16);
	return hash ^ (31*[object1 hash]) ^ ((31*[object2 hash]) << 4);
}
