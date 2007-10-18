//
//  CSequenceGrabber.m
//  SequenceGrabber
//
//  Created by Jonathan Wight on 10/19/2004.
//  Copyright 2004 Toxic Software. All rights reserved.
//

#import "CSequenceGrabber.h"

#import <QuickTime/QuickTime.h>

#import "CCarbonComponent.h"
#import "CCarbonComponentInstance.h"
#import "CSequenceGrabberSoundChannel.h"
#import "CSequenceGrabberVideoChannel.h"
#import "NSError_MoreExtensions.h"
#import "NSException_Extensions.h"
#import "CExceptionHandler.h"
#import "CCarbonHandle.h"

NSString *CSequenceGrabberImageAvailableNotification = @"CSequenceGrabberImageAvailableNotification";
NSString *CSequenceGrabberWillStartNotification = @"CSequenceGrabberWillStartNotification";
NSString *CSequenceGrabberDidStartNotification = @"CSequenceGrabberDidStartNotification";
NSString *CSequenceGrabberWillStopNotification = @"CSequenceGrabberWillStopNotification";
NSString *CSequenceGrabberDidStopNotification = @"CSequenceGrabberDidStopNotification";

@interface CSequenceGrabber (CSequenceGrabber_Private)
- (void)startTimer;
- (void)stopTimer;
+ (void)idleTimer:(NSTimer *)inTimer;
@end

#pragma mark -

@implementation CSequenceGrabber

- (id)init
{
if ((self = ([super init])) != NULL)
	{
	writeToFile = NO;
	}
return(self);
}

- (void)dealloc
{
[self stop:self];
//
[self setVideoChannel:NULL];
[self setSoundChannel:NULL];

[sequenceGrabber autorelease];
sequenceGrabber = NULL;
//
[super dealloc];
}

#pragma mark -

- (void)encodeWithCoder:(NSCoder *)aCoder
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
if ((self = [self init]) != NULL)
	{
	}
return(self);
}

#pragma mark -

- (void)imageAvailable
{
[[NSNotificationCenter defaultCenter] postNotificationName:CSequenceGrabberImageAvailableNotification object:self userInfo:NULL];
}

- (CIImage *)image
{
CIImage *theImage = [CIImage imageWithCVImageBuffer:[[self videoChannel] imageBuffer]];
return(theImage);
}

#pragma mark -

- (BOOL)writeToFile
{
return(writeToFile);
}

- (void)setWriteToFile:(BOOL)inWriteToFile;
{
writeToFile = inWriteToFile;
}

- (NSString *)outputPath
{
return(outputPath);
}

- (void)setOutputPath:(NSString *)inOutputPath
{
NSAssert(isStarted == NO, @"Cannot set output path after grabber has started.");

if ([[inOutputPath lastPathComponent] length] >= 30)
	[NSException raiseErrorDomain:@"CSequenceGrabberErrorDomain" code:-100 format:@"QTNewDataReferenceFromFullPathCFString() doesn't seem to work with filenames with more than 32 characters."];

if (outputPath != inOutputPath)
	{
	[outputPath autorelease];
	outputPath = [inOutputPath retain];
	}
}

#pragma mark -

- (SeqGrabComponent)component
{
if (!sequenceGrabber)
	{
	OSStatus theStatus = EnterMovies();
	if (theStatus != noErr)
		[NSException raiseOSStatus:theStatus format:@"EnterMovies() failed."];

	// ### Find and open a sequence grabber component instance
	sequenceGrabber = [[CCarbonComponentInstance alloc] init];
	[sequenceGrabber openDefaultComponentType:SeqGrabComponentType subType:0L];

	// ### Initialize the sequence grabber...
	theStatus = SGInitialize([sequenceGrabber componentInstance]);
	if (theStatus != noErr)
		[NSException raiseOSStatus:theStatus format:@"SGInitialize() failed."];
	}
return([sequenceGrabber componentInstance]);
}

#pragma mark -

- (CSequenceGrabberVideoChannel *)videoChannel
{
if (videoChannel == NULL)
	{
	[self setVideoChannel:[[[CSequenceGrabberVideoChannel alloc] initWithSequenceGrabber:self] autorelease]];
	}
return(videoChannel);
}

- (void)setVideoChannel:(CSequenceGrabberVideoChannel *)inVideoChannel
{
if (videoChannel != inVideoChannel)
	{
	if (videoChannel != NULL)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kSequenceGrabberVideoChannelDidReceiveImageBufferNotification object:videoChannel];
	
	[videoChannel invalidate];
	[videoChannel autorelease];
	videoChannel = [inVideoChannel retain];
	
	if (videoChannel != NULL)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sequenceGrabberVideoChannelDidReceiveFrameNotification:) name:kSequenceGrabberVideoChannelDidReceiveImageBufferNotification object:[self videoChannel]];
	}
}

- (CSequenceGrabberSoundChannel *)soundChannel
{
if (soundChannel == NULL)
	{
	[self setSoundChannel:[[[CSequenceGrabberSoundChannel alloc] initWithSequenceGrabber:self] autorelease]];
	}
return(soundChannel);
}

- (void)setSoundChannel:(CSequenceGrabberSoundChannel *)inSoundChannel
{
if (soundChannel != inSoundChannel)
	{
	[soundChannel invalidate];
	[soundChannel autorelease];
	soundChannel = [inSoundChannel retain];
	}
}

#pragma mark -

- (NSData *)settings
{
// We need to make sure the channels exist (otherwise the settings are empty) so we 'touch' them...
[self videoChannel];
[self soundChannel];

UserData theUserData;
OSStatus theStatus = SGGetSettings([self component], &theUserData, 0);
if (theStatus) [NSException raise:NSGenericException format:@"SGGetSettings failed (%d)", theStatus];

CCarbonHandle *theUserDataHandle = [CCarbonHandle carbonHandleWithEmptyHandle];
theStatus = PutUserDataIntoHandle(theUserData, [theUserDataHandle handle]);
if (theStatus) [NSException raise:NSGenericException format:@"PutUserDataIntoHandle failed (%d)", theStatus];

return([theUserDataHandle data]);
}

- (void)setSettings:(NSData *)inSettings
{
BOOL theSequenceGrabberIsRunningFlag = NO;
if ([self isStarted])
	{
	theSequenceGrabberIsRunningFlag = YES;
	[self stop:self];
	}

[self setVideoChannel:NULL];
[self setSoundChannel:NULL];

CCarbonHandle *theUserDataHandle = [CCarbonHandle carbonHandleWithData:inSettings];

UserData theUserData;
OSStatus theStatus = NewUserDataFromHandle([theUserDataHandle handle], &theUserData);
if (theStatus) [NSException raise:NSGenericException format:@"NewUserDataFromHandle failed (%d)", theStatus];

theStatus = SGSetSettings([self component], theUserData, 0);
if (theStatus) [NSException raise:NSGenericException format:@"SGSetSettings failed (%d)", theStatus];

if (theSequenceGrabberIsRunningFlag == YES)
	{
	[self start:self];
	}
}

#pragma mark -

- (BOOL)isStarted
{
return(isStarted);
}

- (IBAction)start:(id)inSender
{
#pragma unused (inSender)

@try
	{
	if (isStarted == YES)
		return;

	// ### 'Touch' the video and sound channels...
	[self videoChannel];
	[self soundChannel];

	// ### Tell the world we're starting...
	[[NSNotificationCenter defaultCenter] postNotificationName:CSequenceGrabberWillStartNotification object:self userInfo:NULL];

	if ([self writeToFile] == YES)
		{
		Handle theDataRef = NULL;
		OSType theDataRefType = 0;
		OSStatus theStatus = QTNewDataReferenceFromFullPathCFString((CFStringRef)[self outputPath], kQTNativeDefaultPathStyle, 0, &theDataRef, &theDataRefType);
		if (theStatus != noErr)
			[NSException raiseOSStatus:theStatus format:@"QTNewDataReferenceFromFullPathCFString() failed."];

		theStatus = SGSetDataRef([self component], theDataRef, theDataRefType, seqGrabToDisk | seqGrabDataProcIsInterruptSafe);
		if (theStatus != noErr)
			[NSException raiseOSStatus:theStatus format:@"SGSetDataRef() failed."];
		}
	else
		{
		OSStatus theStatus = SGSetDataRef([self component], NULL, 0, seqGrabDontMakeMovie | seqGrabDataProcIsInterruptSafe);
		// TODO handle -9402 errors
		if (theStatus != noErr)
			[NSException raiseOSStatus:theStatus format:@"SGSetDataRef() failed."];
		}

	// ### Start recording...
	OSStatus theStatus = SGStartRecord([self component]);
	if (theStatus != noErr)
		[NSException raiseOSStatus:theStatus format:@"SGStartRecord() failed."];

	// ### Start the idle loop...
	[self startTimer];

	[self willChangeValueForKey:@"started"];
	isStarted = YES;
	[self didChangeValueForKey:@"started"];


	[[NSNotificationCenter defaultCenter] postNotificationName:CSequenceGrabberDidStartNotification object:self userInfo:NULL];
	}
@catch (NSException *localException)
	{
	[localException raise];
	}
@finally
	{
	}
}

- (IBAction)stop:(id)inSender
{
#pragma unused (inSender)

if (isStarted == NO)
	return;

[[NSNotificationCenter defaultCenter] postNotificationName:CSequenceGrabberWillStopNotification object:self userInfo:NULL];

[self stopTimer];

[self willChangeValueForKey:@"started"];
isStarted = NO;
[self didChangeValueForKey:@"started"];

OSStatus theStatus = SGStop([self component]);
if (theStatus != noErr)
	[NSException raiseOSStatus:theStatus format:@"SGStop() failed."];
[[NSNotificationCenter defaultCenter] postNotificationName:CSequenceGrabberDidStopNotification object:self userInfo:NULL];
}

#pragma mark -

- (BOOL)isPaused
{
return(pauseCount > 0);
}

- (IBAction)pause:(id)inSender
{
#pragma unused (inSender)

[self willChangeValueForKey:@"paused"];
if (pauseCount++ == 0)
	{
	if ([self isStarted])
		{
		[self stopTimer];
		}
	
	OSStatus theStatus = SGPause([self component], seqGrabPause);
	if (theStatus != noErr)
		[NSException raiseOSStatus:theStatus format:@"SGPause() failed."];
	}
[self didChangeValueForKey:@"paused"];
}

- (IBAction)resume:(id)inSender
{
#pragma unused (inSender)

[self willChangeValueForKey:@"paused"];
if (--pauseCount == 0)
	{
	OSStatus theStatus = SGPause([self component], seqGrabUnpause);
	if (theStatus != noErr)
		[NSException raiseOSStatus:theStatus format:@"SGPause() failed."];

	if ([self isStarted])
		{
		[self startTimer];
		}
	}
[self didChangeValueForKey:@"paused"];
}

@end

#pragma mark -

@implementation CSequenceGrabber (CSequenceGrabber_Private)

- (void)handleErrorWhileGrabbing:(NSError *)inError
{
[self stop:self];
//
[videoChannel release];
videoChannel = NULL;

[soundChannel release];
soundChannel = NULL;

[[CExceptionHandler sharedExceptionHandler] handleError:inError];
}

- (void)startTimer
{
NSAssert(timer == NULL, @"There is already an active timer!");
timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 target:[self class] selector:@selector(idleTimer:) userInfo:sequenceGrabber repeats:YES] retain];
}

- (void)stopTimer
{
NSAssert(timer != NULL, @"There is already an active timer!");
[timer invalidate];
[timer release];
timer = NULL;
}

+ (void)idleTimer:(NSTimer *)inTimer
{
#pragma unused (inTimer)

CCarbonComponentInstance *theSequenceGrabberComponent = [inTimer userInfo]; 

OSStatus theStatus = SGIdle([theSequenceGrabberComponent componentInstance]);
if (theStatus != noErr)
	{
	NSLog(@"SGIdle returned %d", theStatus);
//	[NSException raise:NSGenericException format:@"SGIdle returned %d", theStatus];
	theStatus = SGStop([theSequenceGrabberComponent componentInstance]);
	NSLog(@"SGStop returned %d", theStatus);
	theStatus = SGStartRecord([theSequenceGrabberComponent componentInstance]);
	NSLog(@"SGStartRecord returned %d", theStatus);
	}
}

- (void)sequenceGrabberVideoChannelDidReceiveFrameNotification:(NSNotification *)inNotification
{
[self willChangeValueForKey:@"image"];
[self didChangeValueForKey:@"image"];
[self imageAvailable];
}

@end
