//
//  NoTimeGuy.m
//  NoTime
//
//  Created by Duncan Wilcox on 7/23/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import "NoTimeGuy.h"
#import "NoTimeLayer.h"

@implementation NoTimeGuy

- (id)init
{
	NoTimeLayer *guy1 = [[[NoTimeLayer alloc] initWithFile:@"guy-1.png"] autorelease];
	NoTimeLayer *guy2 = [[[NoTimeLayer alloc] initWithFile:@"guy-2.png"] autorelease];
	NoTimeLayer *guy3 = [[[NoTimeLayer alloc] initWithFile:@"guy-3.png"] autorelease];
	NoTimeLayer *guy4 = [[[NoTimeLayer alloc] initWithFile:@"guy-4.png"] autorelease];
	NoTimeLayer *guy5 = [[[NoTimeLayer alloc] initWithFile:@"guy-5.png"] autorelease];
	NoTimeLayer *guy6 = [[[NoTimeLayer alloc] initWithFile:@"guy-6.png"] autorelease];
	NoTimeLayer *guy7 = [[[NoTimeLayer alloc] initWithFile:@"guy-7.png"] autorelease];
	NoTimeLayer *guy8 = [[[NoTimeLayer alloc] initWithFile:@"guy-8.png"] autorelease];
	NoTimeLayer *guy9 = [[[NoTimeLayer alloc] initWithFile:@"guy-9.png"] autorelease];
	NoTimeLayer *guy10 = [[[NoTimeLayer alloc] initWithFile:@"guy-10.png"] autorelease];
	NoTimeLayer *guy11 = [[[NoTimeLayer alloc] initWithFile:@"guy-11.png"] autorelease];
	NoTimeLayer *guy12 = [[[NoTimeLayer alloc] initWithFile:@"guy-12.png"] autorelease];
	NoTimeLayer *guy13 = [[[NoTimeLayer alloc] initWithFile:@"guy-13.png"] autorelease];
	NoTimeLayer *guy14 = [[[NoTimeLayer alloc] initWithFile:@"guy-14.png"] autorelease];
	NoTimeLayer *guy15 = [[[NoTimeLayer alloc] initWithFile:@"guy-15.png"] autorelease];
	NoTimeLayer *guy16 = [[[NoTimeLayer alloc] initWithFile:@"guy-16.png"] autorelease];
	NoTimeLayer *guy17 = [[[NoTimeLayer alloc] initWithFile:@"guy-17.png"] autorelease];
	NoTimeLayer *guy18 = [[[NoTimeLayer alloc] initWithFile:@"guy-18.png"] autorelease];
	NoTimeLayer *guy19 = [[[NoTimeLayer alloc] initWithFile:@"guy-19.png"] autorelease];
	NoTimeLayer *guy20 = [[[NoTimeLayer alloc] initWithFile:@"guy-20.png"] autorelease];
	size = [guy1 size];
	images = [[NSArray alloc] initWithObjects:guy1, guy2, guy3, guy4, guy5, guy6, guy7, guy8, guy9, guy10, guy11, guy12, guy13, guy14, guy15, guy16, guy17, guy18, guy19, guy20, nil];
	return self;
}

- (void)dealloc
{
	[images release];
	[super dealloc];
}

- (int)currentMotion
{
	return currentMotion;
}

- (void)setMotion:(int)newMotion
{
	if(currentMotion != newMotion)
	{
		if(currentMotion != 2 && currentMotion != -2)
		{
			currentMotion = newMotion;
			skip = .1;
			if(currentMotion == 1)
				state = 1;
			else if(currentMotion == -1)
				state = 4;
			else if(currentMotion == 3)
				state = 7;
			else if(currentMotion == -3)
				state = 10;
			else if(currentMotion == 2)
			{
				skip = .2;
				state = 13;
			}
			else if(currentMotion == -2)
			{
				skip = .2;
				state = 16;
			}
			else if(currentMotion == 5)
				state = 19;
			else
				state = 0;
		}
	}
}

- (void)drawAtPoint:(CGPoint)p
{
	NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
	NoTimeLayer *guy = [images objectAtIndex:state];
	if(state == 13 || state == 15 || state == 16 || state == 18)
		p.y += 20;
	if(state == 14 || state == 17)
		p.y += 40;
	[guy drawAtPoint:p];
	if(state != 0 && time - last > skip)
	{
		last = time;
		state++;
		if(state == 4)
			state = 1;
		if(state == 7)
			state = 4;
		if(state == 10)
			state = 7;
		if(state == 13)
			state = 10;
		if(state == 16)
		{
			state = 1;
			skip = .1;
			currentMotion = 1;
		}
		if(state == 19)
		{
			state = 4;
			skip = .1;
			currentMotion = -1;
		}
		if(state == 20)
			state = 19;
	}
}

- (CGSize)size
{
	return size;
}

@end
