//
//  Life_Screen_SaverView.h
//  Life Screen Saver
//
//  Created by Mark Christian on 31/03/07.
//  Copyright (c) 2007, ShinyPlasticBag. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "MCLifeBoard.h"

const float RELOAD_TIMER_INTERVAL = 20.0;	//	Amount of time to show each pattern for

@interface Life_Screen_SaverView : ScreenSaverView 
{
	NSColor *aliveColor;
	NSBitmapImageRep *cacheImage;
	NSColor *deadColor;
	BOOL firstDraw;
	MCLifeBoard *life;
	NSDictionary *patterns;
	NSTimer *reloadTimer;
}

#pragma mark -
#pragma mark Events

- (void)reloadTimerTick;

#pragma mark -
#pragma mark Pattern functions

- (void)initPatterns;
- (void)loadPattern:(NSString *)patternName;
- (void)loadRandomPattern;
- (NSDictionary *)patterns;

@end
