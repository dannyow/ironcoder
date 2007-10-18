//
//  CSequenceGrabberChannel.m
//  SequenceGrabber
//
//  Created by Jonathan Wight on 08/06/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CSequenceGrabberChannel.h"

#import "CSequenceGrabber.h"

NSString *CSequenceGrabberChannelSettingsDidChangeNotification = @"CSequenceGrabberChannelSettingsDidChangeNotification";

@implementation CSequenceGrabberChannel

- (id)init
{
if ((self = [super init]) != NULL)
	{
	}
return(self);
}

- (id)initWithSequenceGrabber:(CSequenceGrabber *)inSequenceGrabber
{
NSAssert(inSequenceGrabber, @"inSequenceGrabber should not be NULL.");
if ((self = [self init]) != NULL)
	{
	sequenceGrabber = inSequenceGrabber; // Not retained!
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sequenceGrabberWillStart:) name:CSequenceGrabberWillStartNotification object:sequenceGrabber];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sequenceGrabberWillStop:) name:CSequenceGrabberWillStopNotification object:sequenceGrabber];
	}
return(self);
}

- (void)dealloc
{
[self invalidate];
//
[super dealloc];
}

#pragma mark -

- (void)invalidate;
{
[[NSNotificationCenter defaultCenter] removeObserver:self name:CSequenceGrabberWillStartNotification object:sequenceGrabber];
[[NSNotificationCenter defaultCenter] removeObserver:self name:CSequenceGrabberWillStopNotification object:sequenceGrabber];
//
[self setChannel:NULL];
sequenceGrabber = NULL;
}

#pragma mark -

- (CSequenceGrabber *)sequenceGrabber;
{
NSAssert(sequenceGrabber != NULL, @"sequenceGrabber should not be null.");
return(sequenceGrabber);
}

#pragma mark -

- (SGChannel)channel
{
return(channel);
}

- (void)setChannel:(SGChannel)inChannel
{
if (channel != inChannel)
	{
	if (channel != NULL)
		{
		OSStatus theStatus = SGSetChannelRefCon(channel, 0);
		if (theStatus != noErr)
			[NSException raise:NSGenericException format:@"SGSetChannelRefCon() failed (%d)", theStatus];
		
		theStatus = CloseComponent(channel);
		if (theStatus != noErr)
			[NSException raise:NSGenericException format:@"CloseComponent() failed (%d)", theStatus];
		}
	channel = inChannel;

	if (channel != NULL)
		{
		OSStatus theStatus = SGSetChannelRefCon(channel, (long)self);
		if (theStatus != noErr)
			[NSException raise:NSGenericException format:@"SGSetChannelRefCon() failed (%d)", theStatus];
		}

//	NSLog(@"%@", [self availableInputs]);
	}
}

#pragma mark -

- (NSArray *)availableInputs
{
NSMutableArray *theAvailableInputs = [NSMutableArray array];

SGDeviceList theDevices;
OSStatus theStatus = SGGetChannelDeviceList([self channel], sgDeviceListIncludeInputs, &theDevices);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGGetChannelDeviceList() failed (%d)", theStatus];
for (int theDeviceIndex = 0; theDeviceIndex != (*theDevices)->count; ++theDeviceIndex)
	{
	SGDeviceName theDeviceEntry = (*theDevices)->entry[theDeviceIndex];
	NSString *theDeviceName = [(NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, theDeviceEntry.name, kCFStringEncodingMacRoman) autorelease];
	SGDeviceInputList theInputs = theDeviceEntry.inputs;
	if (theInputs != NULL)
		{
		for (int theInputIndex = 0; theInputIndex != (*theInputs)->count; ++theInputIndex)
			{
			SGDeviceInputName theInput = (*theInputs)->entry[theInputIndex];
			NSString *theInputName = [(NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, theInput.name, kCFStringEncodingMacRoman) autorelease];

			NSDictionary *theDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
				theDeviceName, @"device",
				theInputName, @"input",
				NULL];
			[theAvailableInputs addObject:theDictionary];
			}
		}
	}
	
theStatus = SGDisposeDeviceList([[self sequenceGrabber] component], theDevices);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGDisposeDeviceList() failed (%d)", theStatus];
return(theAvailableInputs);
}

- (NSString *)deviceName
{
Str255 thePascalDeviceName;
Str255 thePascalInputName;
short theInputIndex;
OSStatus theStatus = SGGetChannelDeviceAndInputNames([self channel], thePascalDeviceName, thePascalInputName, &theInputIndex);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGGetChannelDeviceAndInputNames() failed (%d)", theStatus];
NSString *theDeviceName = [(NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, thePascalDeviceName, kCFStringEncodingMacRoman) autorelease];
//NSString *theInputName = [(NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, thePascalInputName, kCFStringEncodingMacRoman) autorelease];
return(theDeviceName);
}

- (void)setDeviceName:(NSString *)inDeviceName
{
/*
Str255 thePascalDeviceName;

BOOL theResult = CFStringGetPascalString((CFStringRef)inDeviceName, thePascalDeviceName, 256, kCFStringEncodingMacRoman);
if (theResult == NO)
	[NSException raise:NSGenericException format:@"CFStringGetPascalString() failed."];

OSStatus theStatus = SGSetChannelDevice([self channel], thePascalDeviceName);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGSetChannelDevice() failed (%d)", theStatus];
*/
}

- (NSString *)inputName
{
Str255 thePascalDeviceName;
Str255 thePascalInputName;
short theInputIndex;
OSStatus theStatus = SGGetChannelDeviceAndInputNames([self channel], thePascalDeviceName, thePascalInputName, &theInputIndex);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"SGGetChannelDeviceAndInputNames() failed (%d)", theStatus];
//NSString *theDeviceName = [(NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, thePascalDeviceName, kCFStringEncodingMacRoman) autorelease];
NSString *theInputName = [(NSString *)CFStringCreateWithPascalString(kCFAllocatorDefault, thePascalInputName, kCFStringEncodingMacRoman) autorelease];
return(theInputName);
}

#pragma mark -

- (IBAction)runSettingsDialog:(id)inSender
{
#pragma unused (inSender)

// Running a settings dialog on a sequence grabber that is already running isn't the best idea, so we pause it first...
BOOL theSequenceGrabberIsRunningFlag = NO;
if ([[self sequenceGrabber] isPaused] == NO)
	{
	theSequenceGrabberIsRunningFlag = YES;
	[[self sequenceGrabber] pause:self];
	}

OSStatus theStatus = SGSettingsDialog([[self sequenceGrabber] component], [self channel], 0, NULL, 0, NULL, 0);
if (theStatus == noErr)
	{
	[self sequenceGrabberWillChangeSettings];
	
	[self willChangeValueForKey:@"deviceName"];
	[self didChangeValueForKey:@"deviceName"];

	[self willChangeValueForKey:@"inputName"];
	[self didChangeValueForKey:@"inputName"];

	[self sequenceGrabberDidChangeSettings];
	}
else if (theStatus != userCanceledErr)
	{
	[NSException raise:NSGenericException format:@"SGSettingsDialog() failed (%d).", theStatus];
	}

if (theSequenceGrabberIsRunningFlag == YES)
	{
	[[self sequenceGrabber] resume:self];
	}
}

#pragma mark -

- (void)sequenceGrabberWillChangeSettings
{
}

- (void)sequenceGrabberDidChangeSettings
{
[[NSNotificationCenter defaultCenter] postNotificationName:CSequenceGrabberChannelSettingsDidChangeNotification object:self userInfo:NULL];
}

- (void)sequenceGrabberWillStart:(NSNotification *)inNotification
{
#pragma unused (inNotification)
}

- (void)sequenceGrabberWillStop:(NSNotification *)inNotification
{
#pragma unused (inNotification)
}

@end
