//
//  CMyController.m
//  MotionDetector
//
//  Created by Jonathan Wight on 10/19/2004.
//  Copyright 2004 Toxic Software. All rights reserved.
//

#import "CMyController.h"

#import <ToxicMedia/ToxicMedia.h>

#import "CMotionDetector.h"

@implementation CMyController

- (id)init
{
if ((self = [super init]) != NULL)
	{
	sequenceGrabber = [[CSequenceGrabber alloc] init];
	[sequenceGrabber addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:0L];
	motionDetector = [[CMotionDetector alloc] init];
	}
return(self);
}

- (void)dealloc
{
[sequenceGrabber stop:self];
[sequenceGrabber release];
sequenceGrabber = NULL;

[motionDetector release];
motionDetector = NULL;

[super dealloc];
}

- (void)awakeFromNib
{
[sequenceGrabber start:self];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
CIImage *theFrame = [change objectForKey:@"new"];
[motionDetector setCurrentImage:theFrame];
}

@end
