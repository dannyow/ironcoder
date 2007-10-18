//
//  CCarbonGWorld.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 11/10/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCarbonGWorld.h"

#import <QuickTime/QuickTime.h>

@implementation CCarbonGWorld

- (id)initWithSize:(NSSize)inSize
{
if ((self = [super init]) != NULL)
	{
	Rect theBounds = { .top = 0, .left = 0, .bottom = inSize.height, .right = inSize.width };
	// Create a buffer for the channel to work in...
	GWorldPtr theGWorld = NULL;
	OSStatus theStatus = QTNewGWorld(&theGWorld, k32ARGBPixelFormat, &theBounds, NULL, NULL, 0L);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"QTNewGWorld() failed (%d).", theStatus];
	// Make sure the buffer is locked...
	if (!LockPixels(GetPortPixMap(theGWorld)))
		[NSException raise:NSGenericException format:@"LockPixels() failed."];

	gworld = theGWorld;
	}
return(self);
}

- (void)dealloc
{
if (gworld != NULL)
	{
	DisposeGWorld(gworld);
	gworld = NULL;
	}
//
[super dealloc];
}

- (GWorldPtr)gworld
{
return(gworld);
}

- (GDHandle)device
{
return(GetGWorldDevice([self gworld]));
}

@end
