//
//  CMyController.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/26/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CMyController.h"

#import <QTKit/QTKit.h>

#import <ToxicMedia/ToxicMedia.h>

#import "CMyView.h"


@implementation CMyController

- (id)init
{
if ((self = [super init]) != NULL)
	{
	}
return(self);
}

- (void)awakeFromNib
{
movieStream = [[CCVStream alloc] init];
CGDirectDisplayID theDisplayID = (CGDirectDisplayID)[[[[[outletMovieView window] screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
[movieStream setDisplayID:theDisplayID];
[movieStream setOpenGLContext:[[outletMovieView openGLHelper] openGLContext]];
NSError *theError = NULL;
//QTMovie *theMovie = [QTMovie movieWithFile:@"/Volumes/Home/Users/Shared/Movies/ipod.itunes_082004_480.mov" error:&theError];
QTMovie *theMovie = [QTMovie movieWithURL:[NSURL URLWithString:@"rtsp://quicktime.tc.columbia.edu/users/lrf10/movies/sixties.mov"] error:&theError];
[movieStream setMovie:theMovie];
//
sequenceGrabber = [[CSequenceGrabber alloc] init];
@try
	{
	[sequenceGrabber start:self];
	}
@catch (NSException *localException)
	{
	}
//
[self willChangeValueForKey:@"imageSources"];
imageSources = [NSArray arrayWithObjects:
	movieStream,
	sequenceGrabber,
	NULL];
[self didChangeValueForKey:@"imageSources"];

[self setSelectedImageSource:[imageSources objectAtIndex:0]];
}

#pragma mark -

- (NSMutableArray *)macros
{
if (macros == NULL)
	{
	NSMutableArray *theMacros = [NSMutableArray array];

	NSString *theDirectoryPath = [NSString pathWithComponents:[NSArray arrayWithObjects:[[NSBundle mainBundle] bundlePath], @"Contents/Library/CoreImageMacros", NULL]];
	NSArray *theDirectoryContents = [[NSFileManager defaultManager] directoryContentsAtPath:theDirectoryPath];
	
	NSEnumerator *theEnumerator = [theDirectoryContents objectEnumerator];
	NSString *theFilename = NULL;
	while ((theFilename = [theEnumerator nextObject]) != NULL)
		{
		if ([[theFilename pathExtension] isEqual:@"cimacro"])
			{
			[theMacros addObject:[NSString pathWithComponents:[NSArray arrayWithObjects:theDirectoryPath, theFilename, NULL]]];
			}
		}
	
	macros = [theMacros retain];
	}
return(macros);
}

- (NSString *)selectedMacro
{
return(selectedMacro);
}

- (void)setSelectedMacro:(NSString *)inSelectedMacro
{
if (selectedMacro != inSelectedMacro)
	{
	[selectedMacro autorelease];
	selectedMacro = [inSelectedMacro retain];

	CCIMacro *theMacro = [[[CCIMacro alloc] initWithFile:selectedMacro] autorelease];
	
	[outletMovieView setFilter:theMacro];
	}
}

#pragma mark -

- (id)selectedImageSource
{
return(selectedImageSource);
}

- (void)setSelectedImageSource:(id)inImageSource
{
if (selectedImageSource != inImageSource)
	{
	[selectedImageSource autorelease];
	selectedImageSource = [inImageSource retain];

//	[outletMovieView setImageSource:selectedImageSource];

	if (selectedMacro != NULL)
		{
		CCIMacro *theMacro = [[[CCIMacro alloc] initWithFile:selectedMacro] autorelease];
		[outletMovieView setFilter:theMacro];
		}
	}
}

#pragma mark -

- (QTMovie *)movie
{
return([movieStream movie]);
}

#pragma mark -

- (IBAction)actionOpenMovie:(id)inSender
{
NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel]; 
[theOpenPanel setDirectory:[@"~/Movies" stringByExpandingTildeInPath]];
if ([theOpenPanel runModal] == NSOKButton)
	{
	NSError *theError;
	QTMovie *theMovie = [QTMovie movieWithFile:[theOpenPanel filename] error:&theError];
	[movieStream setMovie:theMovie];
	}
}

- (IBAction)actionOpenMovieURL:(id)inSender;
{
}

- (IBAction)actionOpenMacro:(id)inSender;
{
/*
NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel]; 

NSString *theDefaultPath = @"/Users/schwa/Documents/WorkingDirectories/public/trunk/Samples/CoreVideoFunHouse/Samples/";
[theOpenPanel setDirectory:[theDefaultPath stringByExpandingTildeInPath]];
if ([theOpenPanel runModal] == NSOKButton)
	{
	CCIMacro *theMacro = [[[CCIMacro alloc] initWithFile:[theOpenPanel filename]] autorelease];
	[outletMovieView setMacro:theMacro];
	}
*/
}

#pragma mark -

- (IBAction)actionPlay:(id)inSender
{
[[self movie] play];
}

- (IBAction)actionStop:(id)inSender
{
[[self movie] stop];
}

//- (IBAction)actionsetCurrentTime:(QTTime)time:(id)inSender
//{
//[[self movie] setCurrentTime:(QTTime)time];
//}

- (IBAction)actionGotoBeginning:(id)inSender
{
[[self movie] gotoBeginning];
}

- (IBAction)actionGotoEnd:(id)inSender
{
[[self movie] gotoEnd];
}

- (IBAction)actionGotoNextSelectionPoint:(id)inSender
{
[[self movie] gotoNextSelectionPoint];
}

- (IBAction)actionGotoPreviousSelectionPoint:(id)inSender
{
[[self movie] gotoPreviousSelectionPoint];
}

- (IBAction)actionGotoPosterTime:(id)inSender
{
[[self movie] gotoPosterTime];
}

- (IBAction)actionStepForward:(id)inSender
{
[[self movie] stepForward];
}

- (IBAction)actionStepBackward:(id)inSender
{
[[self movie] stepBackward];
}

@end
