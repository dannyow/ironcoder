//
//  CSequenceGrabberView.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/12/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CSequenceGrabberView.h"

#import "CSequenceGrabber.h"
#import "CSequenceGrabberSoundChannel.h"
#import "CSequenceGrabberVideoChannel.h"
#import "NSError_MoreExtensions.h"
#import "NSException_Extensions.h"
#import "CExceptionHandler.h"
#import "Geometry.h"

@implementation CSequenceGrabberView

- (id)initWithFrame:(NSRect)frameRect
{
if ((self = [super initWithFrame:frameRect]) != NULL)
	{
	}
return(self);
}

- (void)dealloc
{
if (controller)
	{
	[self unbind:@"image"];
	[controller setContent:NULL];
	[controller release];
	controller = NULL;
	
	[outletSequenceGrabber release];
	outletSequenceGrabber = NULL;
	}

[super dealloc];
}

#pragma mark -

- (CSequenceGrabber *)sequenceGrabber
{
if (outletSequenceGrabber == NULL)
	{
	@try
		{
		// Create a sequence grabber object...
		CSequenceGrabber *theSequenceGrabber = [[[CSequenceGrabber alloc] init] autorelease];
		[theSequenceGrabber setOutputPath:[@"~/Desktop/SimpleSequenceGrabber.mov" stringByExpandingTildeInPath]];
		// Why do I need this controller?
		controller = [[NSObjectController alloc] initWithContent:theSequenceGrabber];
		[self bind:@"image" toObject:controller withKeyPath:@"selection.image" options:NULL];

		outletSequenceGrabber = [theSequenceGrabber retain];
		}
	@catch (NSException *localException)
		{
		[[CExceptionHandler sharedExceptionHandler] handleException:localException];
		}
	@finally
		{
		}
	}
return(outletSequenceGrabber);
}

#pragma mark -

- (IBAction)start:(id)inSender
{
#pragma unused (inSender)
@try
	{
	[[self sequenceGrabber] start:self];
	}
@catch (NSException *localException)
	{
	[[CExceptionHandler sharedExceptionHandler] handleException:localException];
	}
@finally
	{
	}
}

- (IBAction)stop:(id)inSender
{
#pragma unused (inSender)

@try
	{
	[[self sequenceGrabber] stop:self];
	}
@catch (NSException *localException)
	{
	[[CExceptionHandler sharedExceptionHandler] handleException:localException];
	}
@finally
	{
	}
}

- (IBAction)pause:(id)inSender
{
#pragma unused (inSender)

[[self sequenceGrabber] pause:self];
}

- (IBAction)resume:(id)inSender
{
#pragma unused (inSender)

[[self sequenceGrabber] resume:self];
}

#pragma mark -

- (IBAction)runVideoChannelSettingsDialog:(id)inSender
{
#pragma unused (inSender)
[[[self sequenceGrabber] videoChannel] runSettingsDialog:self];
}

- (IBAction)runSoundChannelSettingsDialog:(id)inSender
{
#pragma unused (inSender)
[[[self sequenceGrabber] soundChannel] runSettingsDialog:self];
}

- (IBAction)saveSettings:(id)inSender
{
#pragma unused (inSender)
NSSavePanel *theSavePanel = [NSSavePanel savePanel];
if ([theSavePanel runModal] == NSOKButton)
	{
	NSData *theSettings = [[self sequenceGrabber] settings];
	[theSettings writeToFile:[theSavePanel filename] atomically:YES];
	}
}

- (IBAction)loadSettings:(id)inSender
{
#pragma unused (inSender)
NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel]; 
if ([theOpenPanel runModal] == NSOKButton)
	{
	NSData *theSettings = [NSData dataWithContentsOfFile:[theOpenPanel filename]];
	[[self sequenceGrabber] setSettings:theSettings];
	}
}

@end
