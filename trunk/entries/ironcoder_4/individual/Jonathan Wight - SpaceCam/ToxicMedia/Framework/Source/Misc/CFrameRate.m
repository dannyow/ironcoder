//
//  CFrameRate.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 10/29/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CFrameRate.h"

@implementation CFrameRate

- (id)init
{
if ((self = [super init]) != NULL)
	{
	[self reset];
	}
return(self);
}

- (void)updateFrameRate
{
[self updateFrameRate:[NSDate timeIntervalSinceReferenceDate]];
}

- (void)updateFrameRate:(NSTimeInterval)inTimeInterval
{
float theFPS = 0.0f;
if (isnan(firstFrameTime))
	{
	firstFrameTime = inTimeInterval;
	frameCount = 1;
	}
else
	{
	++frameCount;
	theFPS = frameCount / (inTimeInterval - firstFrameTime);
	}

if (theFPS != fps)
	{
	[self willChangeValueForKey:@"fps"];
	fps = theFPS;
	[self didChangeValueForKey:@"fps"];
	}
}

- (void)reset
{
firstFrameTime = NAN;
frameCount = 0;
fps = 0;
}

- (float)fps
{
return(fps);
}

@end
