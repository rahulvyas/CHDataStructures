/*
 CHDataStructures.framework -- CHSortedDictionary.h
 
 Copyright (c) 2009, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "CHLockableDictionary.h"
#import "CHSortedSet.h"

/**
 A dictionary which enumerates keys according to their natural sorted order. The following additional operations are provided to take advantage of the ordering:
   - \link #firstKey -firstKey\endlink
   - \link #lastKey -lastKey\endlink
   - \link #subsetFromKey:toKey: -subsetFromKey:toKey:\endlink
 
 Key-value entries are inserted just as in a normal dictionary, including replacement of values for existing keys, as detailed in \link #setObject:forKey: -setObject:forKey:\endlink. However, an additional CHSortedSet structure is used in parallel to sort the keys, and keys are enumerated in that order.
 
 Implementations of sorted maps include to Java's <a href="http://java.sun.com/javase/6/docs/api/java/util/SortedMap.html">SortedMap</a> interface and concrete <a href="http://java.sun.com/javase/6/docs/api/java/util/TreeMap.html">TreeMap</a>.
 
 @note Any method inherited from NSDictionary or NSMutableDictionary is supported, but only overridden methods are listed here.
 
 @todo Document CHSortedDictionary
 */
@interface CHSortedDictionary : CHLockableDictionary {
	id<CHSortedSet> sortedKeys;
}

#pragma mark Adding Objects
/** @name Adding Objects */
// @{

/**
 Adds a given key-value pair to the receiver.
 
 @param anObject The value for @a key. The object receives a @c -retain message before being added to the receiver. This value must not be @c nil.
 @param aKey The key for @a value. The key is copied (using @c -copyWithZone: — keys must conform to the NSCopying protocol). The key must not be @c nil.
 @throw NSInvalidArgumentException If @a aKey or @a anObject is @c nil. If you need to represent a @c nil value in the dictionary, use NSNull.
 
 @see objectForKey:
 @see removeObjectForKey:
 */
- (void) setObject:(id)anObject forKey:(id)aKey;

// @}
#pragma mark Querying Contents
/** @name Querying Contents */
// @{

/**
 Returns the minimum key in the receiver, according to natural sorted order.
 
 @return The minimum key in the receiver, or @c nil if the receiver is empty.
 
 @see lastKey
 @see removeObjectForFirstKey
 */
- (id) firstKey;

/**
 Returns the maximum key in the receiver, according to natural sorted order.
 
 @return The maximum key in the receiver, or @c nil if the receiver is empty.
 
 @see firstKey
 @see removeObjectForLastKey
 */
- (id) lastKey;

/**
 Returns a new dictionary containing the entries for keys delineated by two given objects. The subset is a shallow copy (new memory is allocated for the structure, but the copy points to the same objects) so any changes to the objects in the subset affect the receiver as well. The subset is an instance of the same class as the receiver.
 
 @param start Low endpoint of the subset to be returned; need not be a key in receiver.
 @param end High endpoint of the subset to be returned; need not be a key in receiver.
 @return A new sorted map containing the key-value entries delineated by @a start and @a end. The contents of the returned subset depend on the input parameters as follows:
 - If both @a start and @a end are @c nil, all keys in the receiver are included. (Equivalent to calling @c -copy.)
 - If only @a start is @c nil, keys that match or follow @a start are included.
 - If only @a end is @c nil, keys that match or preceed @a start are included.
 - If @a start comes before @a end in an ordered set, keys between @a start and @a end (or which match either object) are included.
 - Otherwise, all keys @b except those that fall between @a start and @a end are included.
 */
- (NSMutableDictionary*) subsetFromKey:(id)start toKey:(id)end;

// @}
@end
