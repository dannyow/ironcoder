//
//  NoTimeSprite.m
//  NoTime
//
//  Created by Duncan Wilcox on 7/23/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import "NoTimeSprite.h"
#import "NoTimeLayer.h"

@implementation NoTimeSprite

- (id)initWithFiles:(NSArray *)names
{
	unsigned count = [names count];
	unsigned i;
	images = [[NSMutableArray alloc] init];
	for(i = 0; i < count; i++)
	{
		NoTimeLayer *l = [[[NoTimeLayer alloc] initWithFile:[names objectAtIndex:i]] autorelease];
		size = [l size];
		[images addObject:l];
	}
	return self;
}

- (void)dealloc
{
	[images release];
	[super dealloc];
}

- (void)drawAtPoint:(CGPoint)p
{
	NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
	NoTimeLayer *sprite = [images objectAtIndex:state];
	[sprite drawAtPoint:p];
	if(time - last > .1)
	{
		last = time;
		state++;
		if(state == [images count])
			state = 0;
	}
}

@end
