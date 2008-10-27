/*
 Util.h
 CHDataStructures.framework -- Objective-C versions of common data structures.
 Copyright (C) 2008, Quinn Taylor for BYU CocoaHeads <http://cocoaheads.byu.edu>
 Copyright (C) 2002, Phillip Morelock <http://www.phillipmorelock.com>
 
 This library is free software: you can redistribute it and/or modify it under
 the terms of the GNU Lesser General Public License as published by the Free
 Software Foundation, either under version 3 of the License, or (at your option)
 any later version.
 
 This library is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this library.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */

/**
 @file Util.h
 
 A group of utility C functions for simplifying common exceptions and logging.
 */

/**
 Convenience function for raising an exception for an invalid range (index).
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 @param index The offending index passed to the receiver.
 @param elements The number of elements present in the receiver.
 
 Currently, there is no support for calling this function from a C function.
 */
static void CHIndexOutOfRangeException(Class theClass, SEL method,
                                       NSUInteger index, NSUInteger elements) {
	[NSException raise:NSRangeException
                format:@"[%@ %s] -- Index (%d) out of range (0-%d).",
                       theClass, sel_getName(method), index, elements-1];
}

/**
 Convenience function for raising an exception on an invalid nil object argument.
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
static void CHNilArgumentException(Class theClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
				format:@"[%@ %s] -- Invalid nil argument.",
					   theClass, sel_getName(method)];
}

/**
 Convenience function for raising an exception when a collection is mutated.
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
static void CHMutatedCollectionException(Class theClass, SEL method) {
	[NSException raise:NSGenericException
                format:@"[%@ %s] -- Collection was mutated while being enumerated.",
                       theClass, sel_getName(method)];
}

/**
 Convenience function for raising an exception for un-implemented functionality.
 
 @param theClass The class object for the originator of the exception. Callers
        should pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should
        pass <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
static int CHUnsupportedOperationException(Class theClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
				format:@"[%@ %s] -- Unsupported operation.",
					   theClass, sel_getName(method)];
	return 0;
}

static void CHQuietLog(NSString *format, ...) {
    // Get a reference to the arguments that follow the format paramter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSString *s = [[[NSString alloc] initWithFormat:format arguments:argList] autorelease];
    printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%"
                                                 withString:@"%%%%"] UTF8String]);
    va_end(argList);
}
