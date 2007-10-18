//
//  CSequenceGrabberWindowController.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/24/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CSequenceGrabberWindowController.h"

@implementation CSequenceGrabberWindowController

- (id)init
{
if ((self = [super init]) != NULL)
	{
	[NSBundle loadNibNamed:@"SequenceGrabberWindow" owner:self];
	}
return(self);
}

- (NSArray *)deviceResolutions
{
if (deviceResolutions == NULL)
	{
	deviceResolutions = [[NSArray alloc] initWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"80 x 60", @"title",
			[NSValue valueWithSize:NSMakeSize(80.0f, 60.0f)], @"value",
			NULL],
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"160 x 120", @"title",
			[NSValue valueWithSize:NSMakeSize(160.0f, 120.0f)], @"value",
			NULL],
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"320 x 240", @"title",
			[NSValue valueWithSize:NSMakeSize(320.0f, 240.0f)], @"value",
			NULL],
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"640 x 480", @"title",
			[NSValue valueWithSize:NSMakeSize(640.0f, 480.0f)], @"value",
			NULL],
		[NSDictionary dictionaryWithObjectsAndKeys:
			@"1600 x 1200", @"title",
			[NSValue valueWithSize:NSMakeSize(1600.0f, 1200.0f)], @"value",
			NULL],
		NULL];
	}
return(deviceResolutions);
}

@end
