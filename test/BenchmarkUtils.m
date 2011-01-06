//
//  BenchmarkUtils.m
//  CHDataStructures
//
//  Created by Dave DeLong on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BenchmarkUtils.h"
#import <sys/time.h>

/* Return the current time in seconds, using a double precision number. */
double timestamp() {
	struct timeval timeOfDay;
	gettimeofday(&timeOfDay, NULL);
	return ((double) timeOfDay.tv_sec + (double) timeOfDay.tv_usec * 1e-6);
}