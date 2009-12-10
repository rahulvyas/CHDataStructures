/*
 CHDataStructures.framework -- iPhoneUnitTestingAppDelegate.m
 
 Copyright (c) 2009, Ole Begemann <http://oleb.net>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "iPhoneUnitTestingAppDelegate.h"

@implementation iPhoneUnitTestingAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	// Override point for customization after application launch
	[window makeKeyAndVisible];
}

- (void) dealloc {
	[window release];
	[super dealloc];
}

@end
