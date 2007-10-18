//
//  CSequenceGrabberSoundChannel.m
//  SequenceGrabber
//
//  Created by Jonathan Wight on 08/06/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CSequenceGrabberSoundChannel.h"

#import "CSequenceGrabber.h"

@implementation CSequenceGrabberSoundChannel

- (SGChannel)channel;
{
if ([super channel] == NULL)
	{
	SGChannel theSoundChannel = NULL;
	OSStatus theStatus = SGNewChannel([[self sequenceGrabber] component], SoundMediaType, &theSoundChannel);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGNewChannel() failed (%d).", theStatus];

	// ### Set the usage for the sound channel...
	theStatus = SGSetChannelUsage(theSoundChannel, seqGrabPreview | seqGrabRecord);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@"SGSetChannelUsage() failed (%d).", theStatus];

	[self setChannel:theSoundChannel];
	}
return([super channel]);
}

- (void)sequenceGrabberWillStart:(NSNotification *)inNotification
{
[super sequenceGrabberWillStart:inNotification];
//
// This is how we initialize the channel (which we need to do because there will be a callback later).
[self channel];
}

@end
