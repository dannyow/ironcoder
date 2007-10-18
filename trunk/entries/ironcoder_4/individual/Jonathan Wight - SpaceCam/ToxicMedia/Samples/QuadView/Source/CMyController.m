//
//  CMyController.m
//  SequenceGrabber
//
//  Created by Jonathan Wight on 10/19/2004.
//  Copyright 2004 Toxic Software. All rights reserved.
//

#import "CMyController.h"

#import <ToxicMedia/ToxicMedia.h>

@implementation CMyController

- (id)init
{
if ((self = [super init]) != NULL)
	{
	sequenceGrabber = [[CSequenceGrabber alloc] init];
	}
return(self);
}

- (void)dealloc
{
[sequenceGrabber release];
//
[super dealloc];
}

#pragma mark -

- (void)awakeFromNib
{
CIFilter *theFilter = [CIFilter filterWithName:@"CIEdgeWork"];
[theFilter setDefaults];
[image2 setFilter:theFilter];

theFilter = [CIFilter filterWithName:@"CIBloom"];
[theFilter setDefaults];
[image3 setFilter:theFilter];

theFilter = [CIFilter filterWithName:@"CIColorInvert"];
[theFilter setDefaults];
[image4 setFilter:theFilter];

theFilter = [CIFilter filterWithName:@"CIColorPosterize"];
[theFilter setDefaults];
[image5 setFilter:theFilter];
}

- (void)applicationWillTerminateHandler:(NSNotification *)inNotification
{
[sequenceGrabber stop:self];
[sequenceGrabber release];
sequenceGrabber = NULL;
}

#pragma mark -

- (IBAction)actionStart:(id)inSender
{
[sequenceGrabber start:self];
}

- (IBAction)actionStop:(id)inSender
{
[sequenceGrabber stop:self];
}

- (IBAction)actionConfigure:(id)inSender
{
[[sequenceGrabber videoChannel] runSettingsDialog:self];
[[sequenceGrabber soundChannel] runSettingsDialog:self];
}

@end
