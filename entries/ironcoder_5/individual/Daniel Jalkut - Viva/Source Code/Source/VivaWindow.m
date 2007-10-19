//
//  VivaWindow.m
//  VivaApp
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "VivaWindow.h"
#import "VivaView.h"

@implementation VivaWindow

- (id) initWithContentRect:(NSRect)contentRect
{
	// Init super
	if (self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])
	{	
		// Appear on Desktop and avoid activating app
		[self setLevel:kCGDesktopWindowLevel + 1];
		[self setIgnoresMouseEvents:YES];

		// we'll need a VivaView as a our content
		NSRect viewFrame = contentRect;
		viewFrame.origin = NSZeroPoint;
		VivaView* newView = [[[VivaView alloc] initWithFrame:viewFrame isPreview:NO] autorelease];
		[self setContentView:newView];
		
		[self makeKeyAndOrderFront:self];
	}
	return self;
}

- (BOOL) isOpaque
{
	return NO;
}

//  visibleScreensaverCount 
- (int) visibleScreensaverCount
{
    return [(VivaView*)[self contentView] visibleScreensaverCount];
}

- (void) setVisibleScreensaverCount: (int) theVisibleScreensaverCount
{
	[(VivaView*)[self contentView] setVisibleScreensaverCount:theVisibleScreensaverCount];
}

//  screensaverNames 
- (NSArray *) screensaverNames
{
    return [(VivaView*)[self contentView] screensaverNames];
}

- (void) setScreensaverNames: (NSArray *) theScreensaverNames
{
	[(VivaView*)[self contentView] setScreensaverNames:theScreensaverNames];
}
@end
