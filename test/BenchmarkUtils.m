//
//  BenchmarkUtils.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkUtils.h"
#import <sys/time.h>
#import <objc/runtime.h>

/* Return the current time in seconds, using a double precision number. */
double timestamp() {
	struct timeval timeOfDay;
	gettimeofday(&timeOfDay, NULL);
	return ((double) timeOfDay.tv_sec + (double) timeOfDay.tv_usec * 1e-6);
}

Class* ch_copyClassList(int * classCount) {
	if (classCount == NULL) { return NULL; }
	
	int numClasses = objc_getClassList(NULL, 0);
	Class * classes = malloc(sizeof(Class) * numClasses);
	numClasses = objc_getClassList(classes, numClasses);
	
	*classCount = numClasses;
	return classes;
}