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

int main (int argc, const char * argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUInteger limit = 100000;
	NSMutableArray * objects = [[NSMutableArray alloc] init];
	
	//generate some test data
	for (NSUInteger size = 10; size <= limit; size *= 10) {
		NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:size+1];
		[temp addObjectsFromArray:[objects lastObject]];
		for (NSUInteger item = [temp count]+1; item <= size; item++)
			[temp addObject:[NSNumber numberWithUnsignedInteger:item]];
		[objects addObject:temp];
		[temp release];
	}
	
	//find all our Benchmark classes
	NSMutableArray * benchmarkClasses = [NSMutableArray array];
	int numClasses = 0;
	Class * classes = ch_copyClassList(&numClasses);
	if (numClasses > 0) {
		Protocol * benchmarkProtocol = objc_getProtocol("Benchmark");
		for (int i = 0; i < numClasses; ++i) {
			Class c = classes[i];
			if (class_conformsToProtocol(c, benchmarkProtocol)) {
				[benchmarkClasses addObject:c];
			}
		}
	}
	free(classes);
	
	//run each Benchmark
	for (Class benchmarkClass in benchmarkClasses) {
		id<Benchmark> benchmark = [[benchmarkClass alloc] init];
		
		CHQuietLog(@"");
		CHQuietLog(@"--------------------------------------------------------");
		CHQuietLog(@"Running benchmark: %@", NSStringFromClass(benchmarkClass));
		[benchmark runWithTestObjects:objects];
		CHQuietLog(@"");
		
		[benchmark release];
	}
	
	
	[objects release];
	
	
	[pool drain];
	return 0;
}
