//
//  CDecompressionSession.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/20/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CDecompressionSession.h"

#import "CCarbonHandle.h"

static void MyICMDecompressionTrackingCallback(void *inDecompressionTrackingRefCon, OSStatus inResult, ICMDecompressionTrackingFlags inDecompressionTrackingFlags, CVPixelBufferRef inPixelBuffer, TimeValue64 inDisplayTime, TimeValue64 inDisplayDuration, ICMValidTimeFlags inValidTimeFlags, void *inReserved, void *inSourceFrameRefCon);

@implementation CDecompressionSession

- (id)init
{
if ((self = [super init]) != NULL)
	{
	}
return(self);
}

- (void)dealloc
{
if (sessionRef != NULL)
	{
	ICMDecompressionSessionRelease(sessionRef);
	sessionRef = NULL;
	}

[imageDescription release];
imageDescription = NULL;

[desiredPixelBufferAttributes release];
desiredPixelBufferAttributes = NULL;

[self setDelegate:NULL];
//
[super dealloc];
}

#pragma mark -

- (NSDictionary *)desiredPixelBufferAttributes
{
if (desiredPixelBufferAttributes == NULL)
	{
	NSMutableDictionary *thePixelBufferAttributes = [NSMutableDictionary dictionary];
	/*	
	// Don't pass width and height.  Let the codec make a best guess as to the appropriate width and height for the given quality.  It might choose to do a quarter frame decode, for instance.
	[thePixelBufferAttributes setObject:[NSNumber numberWithFloat:imageRect.size.width] forKey:(id)kCVPixelBufferWidthKey];
	[thePixelBufferAttributes setObject:[NSNumber numberWithFloat:imageRect.size.height] forKey:(id)kCVPixelBufferHeightKey];
	*/
	[thePixelBufferAttributes setObject:[NSNumber numberWithBool:YES] forKey:(id)kCVPixelBufferOpenGLCompatibilityKey];
	//
	desiredPixelBufferAttributes = [thePixelBufferAttributes retain];
	}

return(desiredPixelBufferAttributes); 
}

- (void)setDesiredPixelBufferAttributes:(NSDictionary *)inDesiredPixelBufferAttributes
{
if (desiredPixelBufferAttributes != inDesiredPixelBufferAttributes)
	{
	[desiredPixelBufferAttributes autorelease];
	desiredPixelBufferAttributes = [inDesiredPixelBufferAttributes retain];
    }
}

#pragma mark -

- (id)delegate
{
return(delegate);
}

- (void)setDelegate:(id)inDelegate
{
delegate = inDelegate;
}

-(ICMDecompressionSessionRef)sessionRef
{
if (sessionRef == NULL)
	{
	// We also need to create a ICMDecompressionSessionOptionsRef to fill in codec quality...
	ICMDecompressionSessionOptionsRef theSessionOptions = NULL;
	OSStatus theStatus = ICMDecompressionSessionOptionsCreate(NULL, &theSessionOptions);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"ICMImageDescriptionGetProperty() failed (%d).", theStatus];

	CodecQ thePreviewQuality = codecNormalQuality; // JIW TODO
	theStatus = ICMDecompressionSessionOptionsSetProperty(theSessionOptions, kQTPropertyClass_ICMDecompressionSessionOptions, kICMDecompressionSessionOptionsPropertyID_Accuracy, sizeof(CodecQ), &thePreviewQuality);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"ICMDecompressionSessionOptionsSetProperty() failed (%d).", theStatus];

	// Assign a tracking callback...
	ICMDecompressionTrackingCallbackRecord theTrackingCallbackRecord = {
		.decompressionTrackingCallback = MyICMDecompressionTrackingCallback,
		.decompressionTrackingRefCon = self };

	// Now make a new decompression session to decode source video frames to pixel buffers...
	ICMDecompressionSessionRef theSessionRef;
	theStatus = ICMDecompressionSessionCreate(NULL, (ImageDescriptionHandle)[imageDescription handle], theSessionOptions, (CFDictionaryRef)[self desiredPixelBufferAttributes], &theTrackingCallbackRecord, &theSessionRef);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"ICMDecompressionSessionCreate() failed (%d).", theStatus];

	ICMDecompressionSessionOptionsRelease(theSessionOptions);
	
	sessionRef = theSessionRef;
	}
return(sessionRef);
}

#pragma mark -

- (void)decodeFrame:(Ptr)inPointer dataLength:(long)inLength time:(TimeValue)inTime
{
ICMFrameTimeRecord theFrameTime = {
	.recordSize = sizeof(ICMFrameTimeRecord),
	.value = inTime,
	.scale = timeScale,
	.rate = fixed1,
    .frameNumber = 0, // JIW TODO ++mFrameCount,
	.flags = icmFrameTimeIsNonScheduledDisplayTime,
	};

//    *(TimeValue64*)&frameTime.value = timeValue;
    
OSStatus theStatus = ICMDecompressionSessionDecodeFrame([self sessionRef], (UInt8 *)inPointer, inLength, NULL, &theFrameTime, self);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"ICMDecompressionSessionDecodeFrame() failed (%d).", theStatus];
    
theStatus = ICMDecompressionSessionSetNonScheduledDisplayTime([self sessionRef], inTime, timeScale, 0);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"ICMDecompressionSessionSetNonScheduledDisplayTime() failed (%d).", theStatus];
}

- (void)didDecodeImageBuffer:(CVImageBufferRef)inImageBuffer
{
id theDelegate = [self delegate];
if (theDelegate && [theDelegate respondsToSelector:@selector(decompressionSession:didDecodeImageBuffer:)])
	{
	[theDelegate decompressionSession:self didDecodeImageBuffer:inImageBuffer];
	}
}

@end

#pragma mark -

@implementation CDecompressionSession (CDecompressionSession_Extensions)

- (id)initWithSGChannel:(SGChannel)inChannel
{
if ((self = [super init]) != NULL)
	{
	ImageDescriptionHandle theImageDescription = (ImageDescriptionHandle)NewHandle(0); // TODO this leaks if exception thrown!
	OSStatus theStatus = SGGetChannelSampleDescription(inChannel, (Handle)theImageDescription);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGGetChannelSampleDescription() failed (%d).", theStatus];

	// Get the display width and height (the clean aperture width and height suitable for display on a square pixel display like a computer monitor)
	SInt32 theDisplayWidth;
	theStatus = ICMImageDescriptionGetProperty(theImageDescription, kQTPropertyClass_ImageDescription, kICMImageDescriptionPropertyID_DisplayWidth, sizeof(theDisplayWidth), &theDisplayWidth, NULL);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"ICMImageDescriptionGetProperty() failed (%d).", theStatus];
	theDisplayWidth = (*theImageDescription)->width;

	SInt32 theDisplayHeight;
	theStatus = ICMImageDescriptionGetProperty(theImageDescription, kQTPropertyClass_ImageDescription, kICMImageDescriptionPropertyID_DisplayHeight, sizeof(theDisplayHeight), &theDisplayHeight, NULL);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"ICMImageDescriptionGetProperty() failed (%d).", theStatus];
	theDisplayHeight = (*theImageDescription)->height;

	//	[self setPreviewBounds:NSMakeRect(0.0, 0.0, theDisplayWidth, displayHeight)]; // JIW TODO

	// The view to which we will be drawing accepts CIImage's.  As of QuickTime 7.0, the CIImage * class does not apply gamma correction information present in the ImageDescription unless there is also NCLCColorInfo to go with it. We'll check here for the presence of this extension, and add a default if we don't find one (we'll restrict this slam to 2vuy pixel format).
	if ((*theImageDescription)->cType == '2vuy')
		{
		NCLCColorInfoImageDescriptionExtension theColorInfo;
		theStatus = ICMImageDescriptionGetProperty(theImageDescription, kQTPropertyClass_ImageDescription, kICMImageDescriptionPropertyID_NCLCColorInfo, sizeof(theColorInfo), &theColorInfo, NULL);
		if (theStatus != noErr)
			{
			// Assume NTSC
			theColorInfo.colorParamType = kVideoColorInfoImageDescriptionExtensionType;
			theColorInfo.primaries = kQTPrimaries_SMPTE_C;
			theColorInfo.transferFunction = kQTTransferFunction_ITU_R709_2;
			theColorInfo.matrix = kQTMatrix_ITU_R_601_4;
			ICMImageDescriptionSetProperty(theImageDescription, kQTPropertyClass_ImageDescription, kICMImageDescriptionPropertyID_NCLCColorInfo, sizeof(theColorInfo), &theColorInfo);
			}
		}

	[imageDescription release];
	imageDescription = [[CCarbonHandle carbonHandleWithHandle:(Handle)theImageDescription] retain];
	
	// ### Get the timescale (we'll be needing this to decode frames)...
	theStatus = SGGetChannelTimeScale(inChannel, &timeScale);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGGetChannelTimeScale() failed (%d).", theStatus];

	}
return(self);
}

@end

#pragma mark -

static void MyICMDecompressionTrackingCallback(void *inDecompressionTrackingRefCon, OSStatus inResult, ICMDecompressionTrackingFlags inDecompressionTrackingFlags, CVPixelBufferRef inPixelBuffer, TimeValue64 inDisplayTime, TimeValue64 inDisplayDuration, ICMValidTimeFlags inValidTimeFlags, void *inReserved, void *inSourceFrameRefCon)
{
#pragma unused (inResult, inDisplayTime, inDisplayDuration, inValidTimeFlags, inReserved, inSourceFrameRefCon)

if (inDecompressionTrackingFlags & kICMDecompressionTracking_EmittingFrame && inPixelBuffer)
	{
	CDecompressionSession *theDecompressionSession = (CDecompressionSession *)inDecompressionTrackingRefCon;
	[theDecompressionSession didDecodeImageBuffer:inPixelBuffer];
	}
}
