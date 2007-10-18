//
//  CCoreVideoMovieView.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 10/25/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCoreVideoMovieView.h"

#import <QTKit/QTKit.h>

#import "CCVStream.h"

// QTMovieView

@implementation CCoreVideoMovieView

- (void)dealloc
{
[self setMovie:NULL];
//
if (controller)
	{
	if (controller != NULL)
		{
		[self unbind:@"image"];
		[controller setContent:NULL];
		[controller release];
		controller = NULL;
		}
	
	[coreVideoStream release];
	coreVideoStream = NULL;
	}

//
[super dealloc];
}

#pragma mark -

- (QTMovie *)movie
{
QTMovie *theMovie = [(CCVStream *)[self coreVideoStream] movie];
return(theMovie);
}

- (void)setMovie:(QTMovie *)inMovie
{
[(CCVStream *)[self coreVideoStream] setMovie:inMovie];
}

#pragma mark -

- (CCVStream *)coreVideoStream
{
if (coreVideoStream == NULL)
	{
	CCVStream *theStream = [[[CCVStream alloc] init] autorelease];
	[theStream setView:self];
	//
	coreVideoStream = [theStream retain];

	controller = [[NSObjectController alloc] initWithContent:coreVideoStream];
	[self bind:@"image" toObject:controller withKeyPath:@"selection.image" options:NULL];
	}
return(coreVideoStream);
}

#pragma mark -

- (IBAction)play:(id)inSender
{
#pragma unused (inSender)

[[self movie] play];
}

- (IBAction)pause:(id)inSender
{
#pragma unused (inSender)

// TODO is this correct?
[[self movie] stop];
}

- (IBAction)gotoBeginning:(id)inSender
{
#pragma unused (inSender)

[[self movie] gotoBeginning];
}

- (IBAction)gotoEnd:(id)inSender
{
#pragma unused (inSender)

[[self movie] gotoEnd];
}

- (IBAction)gotoNextSelectionPoint:(id)inSender
{
#pragma unused (inSender)

[[self movie] gotoNextSelectionPoint];
}

- (IBAction)gotoPreviousSelectionPoint:(id)inSender
{
#pragma unused (inSender)

[[self movie] gotoPreviousSelectionPoint];
}

- (IBAction)gotoPosterFrame:(id)inSender
{
#pragma unused (inSender)

[[self movie] gotoPosterTime];
}

- (IBAction)stepForward:(id)inSender
{
#pragma unused (inSender)

[[self movie] stepForward];
}

- (IBAction)stepBackward:(id)inSender
{
#pragma unused (inSender)

[[self movie] stepBackward];
}

#pragma mark -

- (IBAction)chooseMovieFile:(id)inSender
{
#pragma unused (inSender)

NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel]; 
if ([theOpenPanel runModal] == NSOKButton)
	{
	NSError *theError = NULL;
	QTMovie *theMovie = [QTMovie movieWithFile:[theOpenPanel filename] error:&theError];
	[self setMovie:theMovie];
	}
}

@end
