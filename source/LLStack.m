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
//
//  LLStack.m
//  DataStructuresFramework

/////SEE LICENSE FILE FOR LICENSE INFORMATION///////

#import "StandardLinkedList.h"
#import "LLStack.h"

@implementation LLStack
/********

@interface LLStack : NSObject <Stack>
{
    StandardLinkedList *list;
}
***********/

-(id) init
{
    [super init];
    list = [[StandardLinkedList alloc] init];
    return self;
}

-(void) dealloc
{
    [list release];
    [super dealloc];
}

-(BOOL) push:(id)pushedObj
{
    if (!pushedObj)
        return NO;
    
    return [list addFirst:pushedObj];
}

-(id) pop
{
    id retval;
    retval = [[list first] retain];
    [list removeFirst];
    return [retval autorelease];
}

-(BOOL) isEmpty
{
    return ([list count] < 1);
}

-(NSEnumerator *)objectEnumerator
{
    return [list objectEnumerator];
}

+(LLStack *)stackWithArray:(NSArray *)array 
                    ofOrder:(BOOL)direction
{
    LLStack *s;
    int i,sz;
    
    s = [[LLStack alloc] init];
    sz = [array count];
    i = 0;
    
    if (!array || !sz)
    {}//nada
    else if (!direction)//so the order to pop will be from 0...n
    {
        while (i < sz)
            [s push: [array objectAtIndex: i++]];
    }
    else //order to pop will be n...0
    {
        while (sz > i)
            [s push: [array objectAtIndex: --sz]];
    }

    return [s autorelease];
}

@end
