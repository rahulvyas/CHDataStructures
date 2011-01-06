/*
 CHDataStructures.framework -- Benchmarks.m
 
 Copyright (c) 2008-2010, Quinn Taylor <http://homepage.mac.com/quinntaylor>
 
 This source code is released under the ISC License. <http://www.opensource.org/licenses/isc-license>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import <Foundation/Foundation.h>
#import <CHDataStructures/CHDataStructures.h>
#import <objc/runtime.h>

#import "Benchmark.h"
#import "BenchmarkUtils.h"

static NSEnumerator *objectEnumerator, *arrayEnumerator;
static NSArray *array;
static NSMutableArray *objects;
static double startTime;



void benchmarkDeque(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHDeque> deque;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8lu", (unsigned long)[array count]);
	
	printf("\nprependObject:    ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[deque prependObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[deque appendObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[deque removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveLastObject:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[deque removeLastObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		[deque removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		objectEnumerator = [deque objectEnumerator];
		while ([objectEnumerator nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		deque = [[testClass alloc] init];
		for (id anObject in array)
			[deque appendObject:anObject];
		startTime = timestamp();
		for (id object in deque)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkQueue(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n* %@", testClass);
	
	id<CHQueue> queue;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8lu", (unsigned long)[array count]);
	
	printf("\naddObject:         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[queue addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveFirstObject:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[queue removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [queue objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		queue = [[testClass alloc] init];
		for (id anObject in array)
			[queue addObject:anObject];
		startTime = timestamp();
		for (id object in queue)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkStack(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHStack> stack;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8lu", (unsigned long)[array count]);
	
	printf("\npushObject:       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[stack pushObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[stack popObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [stack objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		stack = [[testClass alloc] init];
		for (id anObject in array)
			[stack pushObject:anObject];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkHeap(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHHeap> heap;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject])
		printf("\t%-8lu", (unsigned long)[array count]);
	
	printf("\naddObject:          ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[heap addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveFirstObject:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (NSUInteger item = 1; item <= [array count]; item++)
			[heap removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveAllObjects:  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		[heap removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [heap objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nNSFastEnumeration  ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		heap = [[testClass alloc] init];
		for (id anObject in array)
			[heap addObject:anObject];
		startTime = timestamp();
		for (id object in heap)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

void benchmarkTree(Class testClass) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CHQuietLog(@"\n%@", testClass);
	
	id<CHSearchTree> tree;
	
	printf("(Operation)         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		printf("\t%-8lu", (unsigned long)[array count]);
	}	
	
	printf("\naddObject:          ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] init];
		startTime = timestamp();
		for (id anObject in array)
			[tree addObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nmember:         ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] initWithArray:array];
		startTime = timestamp();
		for (id anObject in array)
			[tree member:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nremoveObject:       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] initWithArray:array];
		startTime = timestamp();
		for (id anObject in array)
			[tree removeObject:anObject];
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	printf("\nNSEnumerator       ");
	arrayEnumerator = [objects objectEnumerator];
	while (array = [arrayEnumerator nextObject]) {
		tree = [[testClass alloc] init];
		for (id anObject in array)
			[tree addObject:anObject];
		startTime = timestamp();
		NSEnumerator *e = [tree objectEnumerator];
		while ([e nextObject] != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	CHQuietLog(@"");
	[pool drain];
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUInteger limit = 100000;
	objects = [[NSMutableArray alloc] init];
	
	for (NSUInteger size = 10; size <= limit; size *= 10) {
		NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:size+1];
		[temp addObjectsFromArray:[objects lastObject]];
		for (NSUInteger item = [temp count]+1; item <= size; item++)
			[temp addObject:[NSNumber numberWithUnsignedInteger:item]];
		[objects addObject:temp];
		[temp release];
	}
	
	NSMutableArray * benchmarkClasses = [NSMutableArray array];
	int numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0) {
		Class * classes = malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		
		Protocol * benchmarkProtocol = objc_getProtocol("Benchmark");
		for (int i = 0; i < numClasses; ++i) {
			Class c = classes[i];
			if (class_conformsToProtocol(c, benchmarkProtocol)) {
				[benchmarkClasses addObject:c];
			}
		}
		free(classes);
	}
	
	for (Class benchmarkClass in benchmarkClasses) {
		id<Benchmark> benchmark = [[benchmarkClass alloc] init];
		
		[benchmark runWithTestObjects:objects];
		
		[benchmark release];
	}
	
	CHQuietLog(@"\n<CHDeque> Implemenations");
	benchmarkDeque([CHCircularBufferDeque class]);
	benchmarkDeque([CHListDeque class]);
	
	CHQuietLog(@"\n<CHQueue> Implemenations");
	benchmarkQueue([CHCircularBufferQueue class]);
	benchmarkQueue([CHListQueue class]);
	
	CHQuietLog(@"\n<CHStack> Implemenations");
	benchmarkStack([CHCircularBufferStack class]);
	benchmarkStack([CHListStack class]);
	
	CHQuietLog(@"\n<CHHeap> Implemenations");
	benchmarkHeap([CHMutableArrayHeap class]);
	benchmarkHeap([CHBinaryHeap class]);
	
	[objects release];
	
	
	// Create more disordered sets of values for testing heap and tree subclasses
	
	
	[pool drain];
	return 0;
}
