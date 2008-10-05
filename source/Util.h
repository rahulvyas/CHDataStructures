/************************
 A Cocoa DataStructuresFramework
 Copyright (C) 2002  Phillip Morelock in the United States
 http://www.phillipmorelock.com
 Other copyrights for this specific file as acknowledged herein.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *******************************/

//  Util.h
//  DataStructuresFramework

/**
 Convenience function for raising an exception for an invalid range (index).
 
 @param theClass The class object for the originator of the exception. Callers should
        pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass
        <code>_cmd</code> for this parameter.
 @param index The offending index passed to the receiver.
 @param elements The number of elements present in the receiver.
 
 Currently, there is no support for calling this function from a C function.
 */
static void rangeException(Class theClass, SEL method,
						   NSUInteger index, NSUInteger elements) {
	[NSException raise:NSRangeException
                format:@"[%@ %s] -- Index (%d) out of range (0-%d).",
                       theClass, sel_getName(method), index, elements-1];
}

/**
 Convenience function for raising an exception for an invalid nil object argument.
 
 @param theClass The class object for the originator of the exception. Callers should
        pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass
        <code>_cmd</code> for this parameter.
 
 Currently, there is no support for calling this function from a C function.
 */
static void nilArgumentException(Class theClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
				format:@"[%@ %s] -- Invalid nil argument.",
					   theClass, sel_getName(method)];
}

static void mutatedCollectionException(Class theClass, SEL method) {
	[NSException raise:NSGenericException
                format:@"[%@ %s] -- Collection was mutated while being enumerated.",
                       theClass, sel_getName(method)];
}

/**
 Convenience function for raising an exception for un-implemented functionality.
 
 @param theClass The class object for the originator of the exception. Callers should
        pass the result of <code>[self class]</code> for this parameter.
 @param method The method selector where the problem originated. Callers should pass
        <code>_cmd</code> for this parameter. 

 Currently, there is no support for calling this function from a C function.
 */
static void unsupportedOperationException(Class theClass, SEL method) {
	[NSException raise:NSInternalInconsistencyException
				format:@"[%@ %s] -- Unsupported operation.",
					   theClass, sel_getName(method)];
}

static void QuietLog (NSString *format, ...) {
    // Get a reference to the arguments that follow the format paramter
    va_list argList;
    va_start(argList, format);
    // Perform format string argument substitution, reinstate %% escapes, then print
    NSString *s = [[[NSString alloc] initWithFormat:format arguments:argList] autorelease];
    printf("%s\n", [[s stringByReplacingOccurrencesOfString:@"%%"
                                                 withString:@"%%%%"] UTF8String]);
    va_end(argList);
}
