//
//  VivaView.h
//  Viva
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright (c) 2007, Red Sweater Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface VivaView : ScreenSaverView 
{
	NSColor* mBackgroundColor;
	
	// Which screensavers will we tile?
	NSArray* mScreensaverNames;
	
	// which screen savers are we showing right now?
	NSMutableArray* mShownSavers;
	NSMutableArray* mShownSaverNames;
	
	BOOL mIsPreviewSaver;
	
	// How many are we tiling right now?
	unsigned int mVisibleScreensaverCount;	
}

- (NSArray *) screensaverNames;
- (void) setScreensaverNames: (NSArray *) theScreensaverNames;

- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) theBackgroundColor;

- (int) visibleScreensaverCount;
- (void) setVisibleScreensaverCount: (int) theVisibleScreensaverCount;

@end
