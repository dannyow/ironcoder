//
//  PixureTestController.m
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PixureTestController.h"
#import "PixureSystem.h"
#import "PixureTestView.h"
#import "NSImage (ThumbnailCreation).h"
#import "OJW_PixureSaverDefaults.h"

@implementation PixureTestController

- (void)awakeFromNib
{
	[pixureImageView setController:self];
	
	lastUpdateTime = [[NSDate date] timeIntervalSinceReferenceDate];
}


#pragma mark -
#pragma mark Accessors

- (PixureSystem*)system;
{
	if (nil == system)
		system = [[PixureSystem alloc] initWithImage:nil];

	return system;
}

- (BOOL)isEvolving;
{
	return evolving;
}

- (void)setIsEvolving:(BOOL)inEvolving;
{
	if ([self isEvolving] == inEvolving)
		return;

	evolving = inEvolving;
}


#pragma mark -
#pragma mark Actions

- (IBAction)showPreferencesWindow:(id)sender;
{
	[NSApp beginSheet:[[OJW_PixureSaverDefaults OJW_PixureSaverDefaults] preferencesWindow] modalForWindow:[sender window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)chooseSourceImage:(id)sender;
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel beginSheetForDirectory:[@"~/Pictures" stringByStandardizingPath] file:@""
		types:[NSImage imageFileTypes]
		modalForWindow:[sender window] modalDelegate:self
		didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
		contextInfo:NULL];

}

- (void)openPanelDidEnd:(NSOpenPanel *)openPanel
	returnCode:(int)returnCode
	contextInfo:(void *)contextInfo
{
	if (returnCode != NSOKButton) 
		return;

	NSString* fileToOpen = [openPanel filename];
	if (![fileToOpen length])
		return;
		
	[self willChangeValueForKey:@"rows"];
	[self willChangeValueForKey:@"columns"];
	[self willChangeValueForKey:@"numberOfPixures"];
	[self willChangeValueForKey:@"tolerance"];

//	NSImage* newImage = [[NSImage alloc] initWithContentsOfFile:fileToOpen];
	NSImage* newImage = [NSImage thumbnalImageForIconAtPath:fileToOpen withSize:800];
	[[self system] setImage:newImage];
	
	[sourceImageView setImage:newImage];
//	[newImage release];
	
	[sourceImageView setNeedsDisplay:YES];
	[pixureImageView setNeedsDisplay:YES];

	[self didChangeValueForKey:@"rows"];
	[self didChangeValueForKey:@"columns"];
	[self didChangeValueForKey:@"numberOfPixures"];
	[self didChangeValueForKey:@"tolerance"];
}

- (void)updateDisplay
{
	NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
	if (now - lastUpdateTime > 1.0/30.0)
	{	
		[pixureImageView setNeedsDisplay:YES];
		lastUpdateTime = now;
	}
}

- (void)advanceSeveralGenerations:(unsigned int)inGenerationsToEvolve
{
//	[self willChangeValueForKey:@"generationsPassed"];
//	[self willChangeValueForKey:@"numberOfPixures"];
//	[self willChangeValueForKey:@"tolerance"];
	[[self system] advanceGenerations:inGenerationsToEvolve];
//	[self didChangeValueForKey:@"generationsPassed"];
//	[self didChangeValueForKey:@"numberOfPixures"];
//	[self didChangeValueForKey:@"tolerance"];

//	[pixureImageView setNeedsDisplay:YES];
	[self updateDisplay];
}

- (IBAction)advanceGenerations:(id)sender;
{
	unsigned int generations = [sender intValue];
	if (1 == generations || 0 == generations)
		generations = [sender tag];
	NSLog(@"will advance %d generations", generations);
	
	[self advanceSeveralGenerations:generations];
}

- (void)advanceOneGenerationThenContinue;
{
	[self advanceSeveralGenerations:1];
	
	[self performSelector:@selector(advanceOneGenerationThenContinue) withObject:nil afterDelay:0.01];
}


- (void)evolveInThread:(id)unused;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"thread started");
	[NSThread setThreadPriority:1.0];
	
	while ([self isEvolving])
	{
		[self advanceSeveralGenerations:1];
	}
	[pool release];
}


- (IBAction)startEvolving:(id)sender;
{
	[self setIsEvolving:YES];
//	[self advanceOneGenerationThenContinue];
	
	[NSThread detachNewThreadSelector:@selector(evolveInThread:) toTarget:self withObject:nil];
}

- (IBAction)stopEvolving:(id)sender;
{
	[self setIsEvolving:NO];
//	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark -
#pragma mark Convenience Accessors

// convenience accessors
- (unsigned int)generationsPassed;
{
	return [[self system] generationCount];
}

- (unsigned int)rows;
{
	return [[self system] numberOfRows];
}

- (unsigned int)columns;
{
	return [[self system] numberOfColumns];
}

- (unsigned int)newPixuresinLastGeneration;
{
#warning incomplete
	return 0;
}

- (unsigned int)numberOfPixures;
{
	return [[self system] numberOfPixures];
}

//- (float)tolerance;
//{
//	return [[self system] tolerance];
//}	

@end
