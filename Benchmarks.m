//  Benchmarks.m
//  CHDataStructures.framework

#import <Foundation/Foundation.h>
#import <CHDataStructures/CHDataStructures.h>
#import <sys/time.h>

static NSUInteger limit = 100000;
struct timeval timeOfDay;
static double startTime;

/* Return the current time in seconds, using a double precision number. */
double timestamp() {
	gettimeofday(&timeOfDay, NULL);
	return ((double) timeOfDay.tv_sec + (double) timeOfDay.tv_usec * 1e-6);
}

void benchmarkDeque(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n* %@", testClass);
	
	id<CHDeque> deque;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	

	printf("\nprependObject:    ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque prependObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nappendObject:     ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveFirstObject: ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nremoveLastObject:  ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[deque removeLastObject];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}

	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[deque removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}

	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [deque objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		deque = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[deque appendObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in deque)
			;
		printf("\t%f", timestamp() - startTime);
		[deque release];
	}
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkQueue(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n* %@", testClass);
	
	id<CHQueue> queue;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\naddObject:         ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[queue addObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[queue removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[queue removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [queue objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		queue = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[queue addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in queue)
			;
		printf("\t%f", timestamp() - startTime);
		[queue release];
	}
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkStack(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n%@", testClass);
	
	id<CHStack> stack;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\npushObject:       ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\npopObject:        ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[stack popObject];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[stack removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [stack objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		stack = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[stack pushObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in stack)
			;
		printf("\t%f", timestamp() - startTime);
		[stack release];
	}
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkHeap(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n%@", testClass);

	id<CHHeap> heap;
	NSUInteger item, items;

	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\naddObject:         ");
	for (items = 1; items <= limit; items *= 10) {
		heap = [[testClass alloc] init];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:item]];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveFirstObject:  ");
	for (items = 1; items <= limit; items *= 10) {
		heap = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (item = 1; item <= items; item++)
			[heap removeFirstObject];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	printf("\nremoveAllObjects:  ");
	for (items = 1; items <= limit; items *= 10) {
		heap = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		[heap removeAllObjects];
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		heap = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [heap objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}

	printf("\nNSFastEnumeration  ");
	for (items = 1; items <= limit; items *= 10) {
		heap = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[heap addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		for (id object in heap)
			;
		printf("\t%f", timestamp() - startTime);
		[heap release];
	}
	
	QuietLog(@"");
	[pool drain];
}

void benchmarkTree(Class testClass) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	QuietLog(@"\n%@", testClass);
	
	id<CHTree> tree;
	NSUInteger item, items;
	
	printf("(Operation)         ");
	for (items = 1; items <= limit; items *= 10) {
		printf("\t%-8d", items);
	}	
	
	printf("\nNSEnumerator       ");
	for (items = 1; items <= limit; items *= 10) {
		tree = [[testClass alloc] init];
		for (item = 1; item <= items; item++)
			[tree addObject:[NSNumber numberWithUnsignedInteger:item]];
		startTime = timestamp();
		NSEnumerator *e = [tree objectEnumerator];
		id object;
		while ((object = [e nextObject]) != nil)
			;
		printf("\t%f", timestamp() - startTime);
		[tree release];
	}
	
	QuietLog(@"");
	[pool drain];
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	QuietLog(@"\n<Deque> Implemenations");
	benchmarkDeque([CHMutableArrayDeque class]);
	benchmarkDeque([CHListDeque class]);

	QuietLog(@"\n<Queue> Implemenations");
	benchmarkQueue([CHMutableArrayQueue class]);
	benchmarkQueue([CHListQueue class]);

	QuietLog(@"\n<Stack> Implemenations");
	benchmarkStack([CHMutableArrayStack class]);
	benchmarkStack([CHListStack class]);

	QuietLog(@"\n<Heap> Implemenations");
	benchmarkHeap([CHMutableArrayHeap class]);

//	QuietLog(@"\n<Tree> Implemenations");
//	benchmarkTree([CHUnbalancedTree class]);
//	benchmarkTree([CHAnderssonTree class]);
//	benchmarkTree([CHRedBlackTree class]);

	[pool drain];
	return 0;
}
