//
//  CSequenceGrabberVideoChannel.m
//  SequenceGrabber
//
//  Created by Jonathan Wight on 08/06/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CSequenceGrabberVideoChannel.h"

#import "CSequenceGrabber.h"
#import "Geometry.h"
#import "NSException_Extensions.h"
#import "CDecompressionSession.h"
#import "CCarbonGWorld.h"

NSString *kSequenceGrabberVideoChannelDidReceiveImageBufferNotification = @"kSequenceGrabberVideoChannelDidReceiveImageBufferNotification";

static pascal OSErr MySGDataProc(SGChannel inChannel, Ptr inPointer, long inLength, long *inOffset, long inChannelRefCon, TimeValue inTime, short inWriteType, long inRefCon);

@interface CSequenceGrabberVideoChannel (CSequenceGrabberVideoChannel_Private)

- (void)receiveFrame:(CVImageBufferRef)inFrame atTimeInterval:(NSTimeInterval)inTimeInterval;
- (void)decompressionSession:(CDecompressionSession *)inDecompressionSession didDecodeImageBuffer:(CVImageBufferRef)inFrame;

@end

#pragma mark -

@implementation CSequenceGrabberVideoChannel

- (id)initWithSequenceGrabber:(CSequenceGrabber *)inSequenceGrabber
{
if ((self = [super initWithSequenceGrabber:inSequenceGrabber]) != NULL)
	{
	}
return(self);
}

- (void)dealloc
{
if (offscreenGWorld != NULL)
	{
	[offscreenGWorld release];
	offscreenGWorld = NULL;
	}
//
[decompressionSession release];
decompressionSession = NULL;
//
if (imageBuffer != NULL)
	{
	CVBufferRelease(imageBuffer);
	imageBuffer = NULL;
	}
//
[super dealloc];
}

#pragma mark -

- (SGChannel)channel
{
if ([super channel] == NULL)
	{
	// Create a new channel...
	SGChannel theVideoChannel = NULL;
	OSStatus theStatus = SGNewChannel([[self sequenceGrabber] component], VideoMediaType, &theVideoChannel);
	if (theStatus != noErr)
		[NSException raiseOSStatus:theStatus format:@"SGNewChannel() failed."];
	[self setChannel:theVideoChannel];

	// Set the channel's callback (so we can process data for preview)...
	theStatus = SGSetDataProc([[self sequenceGrabber] component], &MySGDataProc, (long)self);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGSetDataProc() failed (%d).", theStatus];

	// Set the usage of the channel (this will change)...
	theStatus = SGSetChannelUsage([self channel], seqGrabRecord);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGSetChannelUsage() failed (%d).", theStatus];

	// Get the source video bounds (by default this always seems to be 1600x1200 - which is wrong)...
	Rect theVideoBounds;
	theStatus = SGGetSrcVideoBounds([self channel], &theVideoBounds);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGGetSrcVideoBounds() failed (%d).", theStatus];

	[self setSize:NSMakeSize(640.0f, 480.0f)];

	// Create a buffer for the channel to work in...
	CCarbonGWorld *theOffscreenGWorld = [[[CCarbonGWorld alloc] initWithSize:[self size]] autorelease];
	theStatus = SGSetGWorld([[self sequenceGrabber] component], [offscreenGWorld gworld], [offscreenGWorld device]);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGSetGWorld() failed (%d).", theStatus];

	offscreenGWorld = [theOffscreenGWorld retain];

	[self setChannel:theVideoChannel];
	}
return([super channel]);
}

#pragma mark -

- (void)sequenceGrabberWillStart:(NSNotification *)inNotification
{
[super sequenceGrabberWillStart:inNotification];
//
// This is how we initialize the channel (which we need to do because there will be a callback later).
[self channel];
}

- (void)sequenceGrabberWillStop:(NSNotification *)inNotification
{
[super sequenceGrabberWillStop:inNotification];
}

#pragma mark -

- (float)frameRate
{
Fixed theFrameRate;
OSStatus theStatus = SGGetFrameRate([self channel], &theFrameRate);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGGetFrameRate() failed (%d).", theStatus];
return(FixedToFloat(theFrameRate));
}

- (void)setFrameRate:(float)inFrameRate
{
Fixed theFrameRate = FloatToFixed(inFrameRate);
OSStatus theStatus = SGSetFrameRate([self channel], theFrameRate);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGSetFrameRate() failed (%d).", theStatus];
}

- (NSSize)size
{
Rect theVideoBounds;
OSStatus theStatus = SGGetChannelBounds([self channel], &theVideoBounds);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGSetChannelBounds() failed (%d).", theStatus];
NSAssert(theVideoBounds.top == 0 && theVideoBounds.left == 0, @"Video bounds should have a top and left of 0.");
NSSize theSize = { .width = theVideoBounds.right, .height = theVideoBounds.bottom };
return(theSize);
}

- (void)setSize:(NSSize)inSize
{
Rect theVideoBounds = { .top = 0, .left = 0, .bottom = inSize.height, .right = inSize.width };
OSStatus theStatus = SGSetChannelBounds([self channel], &theVideoBounds);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGSetChannelBounds() failed (%d).", theStatus];
}

- (CVImageBufferRef)imageBuffer
{
return(imageBuffer);
}

#pragma mark -

- (CDecompressionSession *)decompressionSession
{
if (decompressionSession == NULL)
	{
	CDecompressionSession *theDecompressionSession = [[[CDecompressionSession alloc] initWithSGChannel:[self channel]] autorelease];
	[theDecompressionSession setDelegate:self];
	
	decompressionSession = [theDecompressionSession retain];
	}
return(decompressionSession);
}

@end

#pragma mark -

@implementation CSequenceGrabberVideoChannel (CSequenceGrabberVideoChannel_Private)

- (void)receiveFrame:(CVImageBufferRef)inFrame atTimeInterval:(NSTimeInterval)inTimeInterval
{
#pragma unused (inTimeInterval)

if (imageBuffer != NULL)
	{
	CVBufferRelease(imageBuffer);
	imageBuffer = NULL;
	}

if (inFrame != NULL)
	{
	imageBuffer = inFrame;
	CVBufferRetain(imageBuffer);
	}

[[NSNotificationCenter defaultCenter] postNotificationName:kSequenceGrabberVideoChannelDidReceiveImageBufferNotification object:self userInfo:NULL];
}

- (void)decompressionSession:(CDecompressionSession *)inDecompressionSession didDecodeImageBuffer:(CVImageBufferRef)inFrame
{
#pragma unused (inDecompressionSession)

[self receiveFrame:inFrame atTimeInterval:[NSDate timeIntervalSinceReferenceDate]];
}

- (void)sequenceGrabberDidChangeSettings
{
[decompressionSession autorelease];
decompressionSession = NULL;

[super sequenceGrabberDidChangeSettings];
}

@end

#pragma mark -

static pascal OSErr MySGDataProc(SGChannel inChannel, Ptr inPointer, long inLength, long *inOffset, long inChannelRefCon, TimeValue inTime, short inWriteType, long inRefCon)
{
#pragma unused (inOffset, inChannelRefCon, inWriteType, inRefCon)

CSequenceGrabberVideoChannel *theChannel = NULL;

OSStatus theStatus = SGGetChannelRefCon(inChannel, (long *)&theChannel);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGGetChannelRefCon() failed (%d).", theStatus];

// TODO Why this message sometimes get sent to Sound Channels I don't know. There must be a bug in my code...
if ([theChannel isMemberOfClass:[CSequenceGrabberVideoChannel class]])
	{
	[[theChannel decompressionSession] decodeFrame:inPointer dataLength:inLength time:inTime];
	}

return(noErr);
}
